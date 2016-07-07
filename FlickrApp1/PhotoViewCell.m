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
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@implementation PhotoViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

}

- (void)configureCellWithData:(NSDictionary *)Data{
    NSLog(@"cell data %@" , Data);
    
    //set title and border between title and tags
    self.photoTitle.text = [Data objectForKey:@"title"];
    CALayer* layer = [self.photoTitle layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor lightGrayColor].CGColor];
    [layer addSublayer:bottomBorder];    self.photoLike.image = [UIImage imageNamed:@"like-icon"];
    
    //set tags
    NSMutableString *tagString = [[NSMutableString alloc] init];
    NSArray *tags = [Data objectForKey:@"tags"];
    for(NSDictionary *tag in tags){
        [tagString appendString:@"#"];
        [tagString appendString:[tag objectForKey:@"_content"]];
        [tagString appendString:@" "];
        
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:tagString];
    for(NSDictionary *tag in tags){
        NSRange range = [tagString rangeOfString:[tag objectForKey:@"_content"]] ;
        range.location --;
        range.length ++;
        if([tags indexOfObject:tag] % 2 != 0){
            [attrString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x2ecc71) range:range];
        }
        else{
            [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
        }
    }
    self.photoTags.attributedText = attrString;

    
    //set image
    self.photoLike.accessibilityIdentifier = [Data objectForKey:@"id"];
    [self.photoView sd_setImageWithURL:[NSURL URLWithString:[Data objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"defaultl_image"]];
    self.photoLike.image = [UIImage imageNamed:@"like-icon"];
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    if(savedValue != nil){
        //photo liked earlier
        self.photoLike.image = [UIImage imageNamed:@"like-icon-filled"];

    }
    
}

- (IBAction)photoLikeButton:(id)sender {
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    if(savedValue != nil){
        //photo liked earlier
        self.photoLike.image = [UIImage imageNamed:@"like-icon"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    }
    else{
        self.photoLike.image = [UIImage imageNamed:@"like-icon-filled"];
        NSString *valueToSave = @"yes";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:[NSString stringWithString:self.photoLike.accessibilityIdentifier]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    

//    NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);
}
@end
