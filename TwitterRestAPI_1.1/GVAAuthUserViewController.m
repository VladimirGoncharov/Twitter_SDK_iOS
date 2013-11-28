//
//  GVATwitterViewController.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 25.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVAAuthUserViewController.h"

#import "GVAUserViewController.h"

@interface GVAAuthUserViewController () 

@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;

@end

@implementation GVAAuthUserViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"auth_user"];
    if (self)
    {

    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - action

- (IBAction)auth:(UIButton *)sender
{
    __weak GVAAuthUserViewController *wself = self;
    
    __weak TUserMain *wMainUser = [TUserMain shared];
    [wMainUser autorize:^(TUserMainAuthResult result, NSError *error)
    {
        __strong TUserMain *sMainUser = wMainUser;
        if (!sMainUser)
        {
            return;
        }
        
        switch (result)
        {
            case TUserMainAuthResultComplete:
            {
                if (wself.rememberMeButton.selected)
                {
                    [sMainUser cachUser];
                }
                else
                {
                    [sMainUser clearCachUser];
                }
                
                GVAUserViewController *viewController = [GVAUserViewController new];
                viewController.user = sMainUser;
                [wself.navigationController setViewControllers:@[viewController] animated:YES];
            }; break;
                
            case TUserMainAuthResultError:
            {
                [[[UIAlertView alloc] initWithTitle:@"Error!"
                                            message:[error domain]
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }; break;
                
            default:
                break;
        }
    } presentViewController:self];
}

- (IBAction)rememberMe:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

#pragma mark - text field delegate

- (void)viewDidUnload
{
    [self setAuthButton:nil];
    [super viewDidUnload];
}
@end
