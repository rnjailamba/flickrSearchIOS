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

#define flickrApiKey @"c4c3a34c214e57691421cc95fb223013"
@interface SearchViewController ()
//@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *queryString;
@property  UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *resultDisplay;
@property (weak, nonatomic) IBOutlet UICollectionView *photosView;
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *parentViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchHeight;
@property (weak, nonatomic) IBOutlet UITextView *textViewIpad;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect =[[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    size.width = size.width/2;
    self.parentView.frame = [[UIScreen mainScreen] bounds];
    
    NSLog(@"%ld",(long)[[UIDevice currentDevice] orientation]);
    self.photosView.dataSource = self;
    self.photosView.delegate = self;
    
    self.mySearchBar.delegate = self;
    self.mySearchBar.showsCancelButton = YES;
    
    [self.photosView registerNib:[UINib nibWithNibName:@"PhotoViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PhotoViewCell"];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    
}






- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if([self checkIpad]){
        for (UIView *subview in [self.view subviews]) {
            if (subview.tag == 7) {
                [subview removeFromSuperview];
            }
        }
        // do something before rotation
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"SideView"
                                                          owner:self
                                                        options:nil];
        UIView *view = [nibViews objectAtIndex:0];
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            _parentViewTrailing.constant = 300;
            [_photosView reloadData];
            CGRect rect =[[UIScreen mainScreen] bounds];
            CGPoint point = rect.origin;
            point.x = rect.size.width - 300;
            CGSize size = rect.size;
            size.width = 300;
            view.frame = CGRectMake(point.x, point.y, 300, size.height);
            self.textViewIpad.text = [self.textViewIpad.text stringByAppendingString:@"dfdf"];

            [self.view addSubview:view];
            
        }
        
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
        {
            // code for Portrait orientation
            _parentViewTrailing.constant = 0;
            [_photosView reloadData];
        }

    }
  }
- (BOOL)checkIpad {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return YES; /* Device is iPad */
    }
    return NO; /* Device is not iPad */

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentWidth = scrollView.frame.size.width;
    NSLog(@"offset X %.0f", offsetY);
    if(offsetY >100){
        self.searchHeight.constant = 0;

    }
    
    if(offsetY == 0){
        self.searchHeight.constant = 44;
        
    }
    

}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {


    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        screenWidth = screenRect.size.width - 300;
        
    }
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
    [self.view addSubview:self.spinner];
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
          self.resultDisplay.text = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)[photosArray count],@" results found for",searchBar.text];

          
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
                    [_photosView reloadData];
                    [self.spinner stopAnimating];

//                    if([_collectionData count] == [photosArray count]){
//                        NSLog(@"collection data  complete");
//                        [_photosView reloadData];
//                        [self.spinner stopAnimating];
//                    }

                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
          } failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
        

    }
}


@end
