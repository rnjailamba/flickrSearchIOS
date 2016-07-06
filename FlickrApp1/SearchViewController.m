//
//  SearchViewController.m
//  FlickrApp1
//
//  Created by Mr Ruby on 05/07/16.
//  Copyright © 2016 Rnjai Lamba. All rights reserved.
//

#import "SearchViewController.h"
#import "PhotoViewCell.h"

@interface SearchViewController ()
//@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, strong) NSString *queryString;
@property (weak, nonatomic) IBOutlet UILabel *resultDisplay;
@property (weak, nonatomic) IBOutlet UICollectionView *photosView;

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

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"SETTING SIZE FOR ITEM AT INDEX %d", indexPath.row);
//    CGSize mElementSize = CGSizeMake(145, 150);
//    return mElementSize;

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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(10,10,10,10);  // top, left, bottom, right
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 10;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoViewCell *cell = (PhotoViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoViewCell" forIndexPath:indexPath];
    [cell layoutIfNeeded];
    
//    cell.testLabel.text = @"test";
//    [cell setBackgroundColor:[UIColor lightGrayColor]];
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
    NSMutableString *prefixString = @"Lot of results found for ";
//    NSMutableString *finalString =[prefixString appendString:@"fdfd"];
    self.resultDisplay.text = @"Lot of results found for";
    [searchBar resignFirstResponder];
    
    //setup the remote server URI
    NSString *hostServer = @"http://demo.mysamplecode.com/Servlets_JSP/";
    NSString *myUrlString = [NSString stringWithFormat:@"%@CountrySearch",hostServer];
    
    //pass the query String in the body of the HTTP post
    NSString *body;
    if(self.queryString){
        body =  [NSString stringWithFormat:@"queryString=%@", self.queryString];
    }
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    //make the HTTP request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data;
//    [self parseResponse:data];
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //    [NSURLConnection
    //     sendAsynchronousRequest:urlRequest
    //     queue:queue
    //     completionHandler:^(NSURLResponse *response,
    //                         NSData *data,
    //                         NSError *error) {
    //         //we got something in reponse to our request lets go ahead and process this
    //         if ([data length] >0 && error == nil){
    //
    //
    //         }
    //         else if ([data length] == 0 && error == nil){
    //             NSLog(@"Empty Response, not sure why?");
    //         }
    //         else if (error != nil){
    //             NSLog(@"Not again, what is the error = %@", error);
    //         }
    //     }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
