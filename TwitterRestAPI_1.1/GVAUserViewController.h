//
//  GVAUserViewController.h
//  TwitterRestAPI_1.1
//
//  Created by admin on 10.11.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Twitter.h"

@interface GVAUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TUser *user;

@end
