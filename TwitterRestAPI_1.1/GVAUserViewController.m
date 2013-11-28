//
//  GVAUserViewController.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 10.11.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVAAuthUserViewController.h"
#import "GVAUserViewController.h"
#import "GVATweetCell.h"

#import "UIScrollView+AH3DPullRefresh.h"

@interface GVAUserViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GVAUserViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"user"];
    if (self)
    {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.title                          = self.user.screen_name;
       
    __weak typeof(self)      wself      = self;
    
    [self.tableView setPullToRefreshHandler:^{
        
        BOOL isEmpty        = (self.user.timelines.count == 0);
        
        [wself needUpdateNewTimelenes:^{
            if (isEmpty)
            {
                double delayInSeconds = 0.2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [wself.tableView setPullToLoadMoreHandler:^{
                        
                        [wself needUpdateTimelenes:nil];
                    }];
                });
            }
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.user.timelines.count == 0)
    {
        [self.tableView pullToRefresh];
    }
}

#pragma mark - helper

- (void)needUpdateTimelenes:(void(^)())finish
{
    __weak typeof(self)      wself      = self;
    
    [self.user updateTimelinesAsync:^(NSArray *tweets, NSError *error) {
        
        [wself.tableView loadMoreFinished];
        
        NSUInteger iniRowsCount = [wself.user.timelines count] - tweets.count;
        
        NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[tweets count]];
        for (NSUInteger i = iniRowsCount; i < [wself.user.timelines count]; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        if (finish)
        {
            finish();
        }
    } count:30];
}

- (void)needUpdateNewTimelenes:(void(^)())finish
{
    __weak typeof(self)      wself      = self;
    
    [self.user updateNewTimelinesAsync:^(NSArray *tweets, NSError *error) {
        
        [wself.tableView refreshFinished];
        
        NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[tweets count]];
        for (NSUInteger i = 0; i < [tweets count]; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        if (finish)
        {
            finish();
        }
    } count:30];
}

#pragma mark - action

- (IBAction)logout:(UIBarButtonItem *)sender
{
    [[TUserMain shared] logout];
    
    GVAAuthUserViewController *viewControllerAuth = [GVAAuthUserViewController new];
    [self.navigationController setViewControllers:@[viewControllerAuth] animated:YES];
}

#pragma mark - table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellTableViewCell = @"__tweet_cell__";
    GVATweetCell *cell = (GVATweetCell *)[tableView dequeueReusableCellWithIdentifier:kCellTableViewCell];
    
    TTweet *tweet = [self.user.timelines objectAtIndex:indexPath.row];
    
    cell.tweet      = tweet;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTweet *tweet = [self.user.timelines objectAtIndex:indexPath.row];
    if (tweet.retweeted_status != nil)
    {
        tweet     = tweet.retweeted_status;
    }
    
    NSString *cellText      = tweet.text;
    UIFont *cellFont        = [UIFont fontWithName:@"Helvetica" size:14.0f];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    CGSize labelSize = [cellText sizeWithFont:cellFont
                            constrainedToSize:constraintSize];
    
    return labelSize.height + 115.0f;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.user.timelines.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTweet *tweet = [self.user.timelines objectAtIndex:indexPath.row];
    if (tweet.retweeted_status != nil)
    {
        tweet     = tweet.retweeted_status;
    }
    
    TUser *user         = tweet.user;
    
    if ([user.user_id longLongValue] != [self.user.user_id longLongValue])
    {
        GVAUserViewController *viewController = [GVAUserViewController new];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
