//
//  GVATWitterViewController.h
//  TwitterRestAPI_1.1
//
//  Created by admin on 26.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVATWitterViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) TUser *user;

@end
