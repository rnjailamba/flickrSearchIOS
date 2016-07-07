//
//  PhotoViewCell.m
//  FlickrApp1
//
//  Created by Mr Ruby on 06/07/16.
//  Copyright © 2016 Rnjai Lamba. All rights reserved.
//

#import "PhotoViewCell.h"
@import WebImage;
@import AFNetworking;

@interface PhotoViewCell()

@property (weak, nonatomic) IBOutlet UILabel *photoTitle;
@property (weak, nonatomic) IBOutlet UILabel *photoTags;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoLike;
- (IBAction)photoLikeButton:(id)sender;

@end

@implementation PhotoViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}

- (void)configureCellWithData:(NSDictionary *)Data{
    NSLog(@"cell data %@" , Data);
    self.photoTitle.text = [Data objectForKey:@"title"];
    self.photoLike.image = [UIImage imageNamed:@"like-icon"];
    [self.photoView sd_setImageWithURL:[NSURL URLWithString:[Data objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"defaultl_image"]];
}

- (IBAction)photoLikeButton:(id)sender {
    self.photoLike.image = [UIImage imageNamed:@"like-icon-filled"];
    
}
@end
