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

@end

@implementation PhotoViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)configureCellWithData:(NSDictionary *)Data{
    NSLog(@"cell data %@" , Data);
    self.photoTitle.text = [Data objectForKey:@"title"];
    [self.photoView sd_setImageWithURL:[NSURL URLWithString:[Data objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"defaultl_image"]];
}

@end
