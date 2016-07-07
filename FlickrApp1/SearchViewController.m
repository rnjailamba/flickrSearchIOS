//
//  SearchViewController.m
//  FlickrApp1
//
//  Created by Mr Ruby on 05/07/16.
//  Copyright © 2016 Rnjai Lamba. All rights reserved.
//

#import "SearchViewController.h"
#import "PhotoViewCell.h"
@import AFNetworking;

#define flickrApiKey @"52dfc2093a3351192be67d2de936e83b"
@interface SearchViewController ()
//@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *queryString;
@property  UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *resultDisplay;
@property (weak, nonatomic) IBOutlet UICollectionView *photosView;
@property (nonatomic, strong) NSMutableArray *collectionData;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.photosView.dataSource = self;
    self.photosView.delegate = self;
    
    self.mySearchBar.delegate = self;
    self.mySearchBar.showsCancelButton = YES;
    
    [self.photosView registerNib:[UINib nibWithNibName:@"PhotoViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PhotoViewCell"];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    float cellWidth = screenWidth / 2.2; //Replace the divisor with the column count requirement. Make sure to have it in float.
    float cellHt = screenHeight / 2.2; //Replace the divisor with the column count requirement. Make sure to have it in float.
    CGSize size = CGSizeMake(cellWidth, cellHt);
    return size;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}




// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10,10,10,10);  // top, left, bottom, right
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_collectionData count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoViewCell *cell = (PhotoViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoViewCell" forIndexPath:indexPath];
    [cell layoutIfNeeded];
    NSDictionary *photoDict =  [self.collectionData objectAtIndex:indexPath.row];
    [cell configureCellWithData:photoDict];
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//user tapped on the cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder];
}

//search button was tapped
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}


//do our search on the remote server using HTTP request
- (void)handleSearch:(UISearchBar *)searchBar {
    
    //check what was passed as the query String and get rid of the keyboard
    NSLog(@"User searched for %@", searchBar.text);
    self.queryString = searchBar.text;
    [searchBar resignFirstResponder];
    
//     api.flickr.com/services/rest/?method=flickr.photos.search&api_key=52dfc2093a3351192be67d2de936e83b&tags=rnjai&format=json&nojsoncallback=1&auth_token=72157667908644954-36bfea8fa0551c03&api_sig=e46668b6d684f42e510c5eb8d6a1f290
    [self.photosView addSubview:self.spinner];
    [self.spinner startAnimating];

    NSDictionary *parameters = @{@"method":@"flickr.photos.search",
                                 @"api_key":flickrApiKey,
                                 @"tags":searchBar.text,
                                 @"format":@"json",
                                 @"nojsoncallback":@"1"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://api.flickr.com/services/rest"
      parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
          _collectionData = [[NSMutableArray alloc] init];
          [_photosView reloadData];
          
          id photos =[responseObject objectForKey:@"photos"];
          NSMutableArray *photosArray =[photos objectForKey:@"photo"];
          [self parseTagSearchData:photosArray];
          self.resultDisplay.text = [NSString stringWithFormat:@"%i %@ %@",[photosArray count],@" results found for",searchBar.text];

          
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}

//parse data
- (void)parseTagSearchData:(NSMutableArray *)photosArray {
    
    for (NSDictionary *photo in photosArray) {
        NSMutableDictionary * temp = [[NSMutableDictionary alloc]init];
        NSString* photoId = [photo  objectForKey:@"id"];
        NSString* photoTitle = [photo  objectForKey:@"title"];
        temp[@"id"] = photoId;
        temp[@"title"] = photoTitle;

        //api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=52dfc2093a3351192be67d2de936e83b&photo_id=28048179706&format=json&nojsoncallback=1
        
        NSDictionary *parameters = @{@"method":@"flickr.photos.getInfo",
                                     @"api_key":flickrApiKey,
                                     @"photo_id":photoId,
                                     @"format":@"json",
                                     @"nojsoncallback":@"1"};
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:@"https://api.flickr.com/services/rest"
          parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
              id photos =[responseObject objectForKey:@"photo"];
              id tagsObject =[photos objectForKey:@"tags"];
              NSMutableArray *tagsArray =[tagsObject objectForKey:@"tag"];
              temp[@"tags"] = tagsArray;
              //api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=52dfc2093a3351192be67d2de936e83b&photo_id=28048179706&format=json&nojsoncallback=1
              NSDictionary *parameters1 = @{@"method":@"flickr.photos.getSizes",
                             @"api_key":flickrApiKey,
                             @"photo_id":photoId,
                             @"format":@"json",
                             @"nojsoncallback":@"1"};
              
              [manager GET:@"https://api.flickr.com/services/rest"
                parameters:parameters1 progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                    id sizes =[responseObject objectForKey:@"sizes"];
                    NSMutableArray *sizeArray =[sizes objectForKey:@"size"];
                    for(NSDictionary *uniqueSize in sizeArray){
                        if([[uniqueSize objectForKey:@"label"]  isEqual: @"Small"]){
                            temp[@"image"] = [uniqueSize objectForKey:@"source" ];

                        }
                    }
                    [_collectionData addObject:temp];
                    if([_collectionData count] == [photosArray count]){
                        NSLog(@"collection data  complete");
                        [_photosView reloadData];
                        [self.spinner stopAnimating];     
                    }

                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
          } failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
        

    }
}


@end
