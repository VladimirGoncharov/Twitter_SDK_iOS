//
//  GVATwitterCell.h
//  TwitterRestAPI_1.1
//
//  Created by admin on 27.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVATwitterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *textLabelScreenName;
@property (weak, nonatomic) IBOutlet UILabel *textLabelLocation;

@end
