//
//  GVAA3TwiiterCell.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 26.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVAA3TwitterCell.h"

@implementation GVAA3TwitterCell

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                         owner:self
                                       options:nil] lastObject];
    if (self)
    {
        [self _loadDefaultSettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _loadDefaultSettings];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    if (self)
    {
        self.frame = frame;
    }
    return self;
}

#pragma mark - define

- (void)_loadDefaultSettings
{
    CALayer *layer = self.imageView.layer;
    [layer setMasksToBounds:YES];
}

@end
