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
    self.photoLike.accessibilityIdentifier = [Data objectForKey:@"id"];
    
    [self.photoView sd_setImageWithURL:[NSURL URLWithString:[Data objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"defaultl_image"]];
    
    self.photoLike.image = [UIImage imageNamed:@"like-icon"];
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    if(savedValue != nil){
        //photo like earlier
        self.photoLike.image = [UIImage imageNamed:@"like-icon-filled"];

    }
    
}

- (IBAction)photoLikeButton:(id)sender {
    self.photoLike.image = [UIImage imageNamed:@"like-icon-filled"];
    
    NSString *valueToSave = @"yes";
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);

    

    
}
@end
