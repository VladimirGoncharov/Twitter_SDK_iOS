//
//  GVATwitterCell.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 27.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVATwitterCell.h"

@implementation GVATwitterCell

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                         owner:self
                                       options:nil] lastObject];
    if (self)
    {
        self.textLabelLocation.textColor = [UIColor blueColor];
        self.textLabelLocation.font = [UIFont systemFontOfSize:12.0f];
        
        self.textLabelScreenName.textColor = [UIColor blackColor];
        self.textLabelScreenName.font = [UIFont systemFontOfSize:10.0f];
    }
    return self;
}

@end
