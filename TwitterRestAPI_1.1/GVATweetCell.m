//
//  GVATweetCell.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 10.11.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVATweetCell.h"

@interface GVATweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *retweetedImageView;


@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelRetweetedName;

@end

@implementation GVATweetCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    CALayer *layer  = self.imageViewAvatar.layer;
    
    [layer setCornerRadius:10.0f];
    
    [layer setBorderColor:[UIColor blackColor].CGColor];
    [layer setBorderWidth:1.0f];
    
    [layer setMasksToBounds:YES];
    
    UIView *backgroundView                    = [UIView new];
    backgroundView.backgroundColor  = [UIColor whiteColor];
    self.backgroundView     = backgroundView;
    
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - accessory

- (void)setTweet:(TTweet *)tweet
{
    _tweet      = tweet;
    
    BOOL isRetweet      = (tweet.retweeted_status != nil);
    
    if (!isRetweet)
    {
        [self.imageViewAvatar setImageWithURL:tweet.user.profile_image_url];
        self.labelName.text         = [NSString stringWithFormat:@"%@ (%@)", tweet.user.name, tweet.user.screen_name];
        self.labelText.text         = tweet.text;
        self.labelRetweetedName.text    = nil;
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *date_str          = [dateFormatter stringFromDate:tweet.created_at];
        self.labelDate.text         = date_str;
    }
    else
    {
        [self.imageViewAvatar setImageWithURL:tweet.retweeted_status.user.profile_image_url];
        self.labelName.text         = [NSString stringWithFormat:@"%@ (%@)", tweet.retweeted_status.user.name, tweet.retweeted_status.user.screen_name];
        self.labelText.text         = tweet.retweeted_status.text;
        
        self.labelRetweetedName.text = [NSString stringWithFormat:@"%@ (%@)", tweet.user.name, tweet.user.screen_name];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *date_str          = [dateFormatter stringFromDate:tweet.created_at];
        self.labelDate.text         = date_str;
    }
    
    self.retweetedImageView.hidden  = !isRetweet;
}

@end
