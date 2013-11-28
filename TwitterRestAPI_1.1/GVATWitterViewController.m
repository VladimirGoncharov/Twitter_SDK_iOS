//
//  GVATWitterViewController.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 26.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "GVATWitterViewController.h"

#import "A3GridTableView.h"
#import "GVAA3TwitterCell.h"

#import "GVATwitterCell.h"

@interface GVATWitterViewController () <A3GridTableViewDataSource, A3GridTableViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textViewStatus;

@property (weak, nonatomic) IBOutlet A3GridTableView *gridTableImages;

@property (weak, nonatomic) IBOutlet UITableView *tableFollowers;

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation GVATWitterViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"twitter"];
    if (self)
    {
        
    }
    return self;
}

- (void)loadView
{
    self.images = [NSMutableArray new];
    
    [super loadView];
    
    CALayer *layerTextViewStatus = self.textViewStatus.layer;
    [layerTextViewStatus setBorderWidth:1.0f];
    [layerTextViewStatus setCornerRadius:5.0f];
    
    self.gridTableImages.delegate = self;
    self.gridTableImages.dataSource = self;
    CALayer *layerGridTableImages = self.gridTableImages.layer;
    [layerGridTableImages setMasksToBounds:YES];
    [self.gridTableImages setBounces:NO];
    self.gridTableImages.backgroundColor = [UIColor colorWithRed:0.01f green:0.1f blue:0.1f alpha:0.5f];
    
    self.tableFollowers.delegate = self;
    self.tableFollowers.dataSource = self;
    
    self.title = self.user.screen_name;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.user.followers count] == 0)
    {
        [self _updateNewFollowers:nil];
    }
}

- (void)viewDidUnload
{
    [self setTextViewStatus:nil];
    [self setGridTableImages:nil];
    [self setTableFollowers:nil];
    [super viewDidUnload];
}

- (void)_updateNewFollowers:(void(^)())finish
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak GVATWitterViewController *wself = self;
    
    [self.user updateFollowersAsync:^(NSError *error) {
        __strong GVATWitterViewController *sself = wself;
        if (!sself)
        {
            return;
        }
        
        [wself.tableFollowers reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (finish)
        {
            finish();
        }
    } count:20];
}

#pragma mark - action

- (IBAction)post:(UIButton *)sender
{
    NSString *status = self.textViewStatus.text;
    NSError *error = nil;
    
    if ([[TUserMain shared] postTweetWithStatusSync:status
                                     media:self.images
                                     error:&error])
    {
        [[[UIAlertView alloc] initWithTitle:@"Отправлено!"
                                    message:@"Твит успешно добавлен!"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"Не удалось добавить твит! Причина: %@", [error domain]];
        [[[UIAlertView alloc] initWithTitle:@"Ошибка!"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - a3grid data source

- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)gridTableView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellGridTableViewCell = @"__a3cell__";
    A3GridTableViewCell *cell = [gridTableView dequeueReusableCellWithIdentifier:kCellGridTableViewCell];
    if (!cell)
    {
        cell = [[A3GridTableViewCell alloc] initWithReuseIdentifier:kCellGridTableViewCell];
        
        GVAA3TwitterCell *contentView = [GVAA3TwitterCell new];
        
        cell.contentView = contentView;
    }
    
    GVAA3TwitterCell *contentView = (GVAA3TwitterCell *)cell.contentView;
    
    if (indexPath.section < self.images.count)
    {
        UIImage *image = [self.images objectAtIndex:indexPath.section];
        contentView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        contentView.imageView.image = image;
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"i_plus.png"];
        contentView.imageView.contentMode = UIViewContentModeCenter;
        contentView.imageView.image = image;
    }
    
    return cell;
}

- (CGFloat)A3GridTableView:(A3GridTableView *)gridTableView
          heightForHeaders:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)A3GridTableView:(A3GridTableView *)gridTableView
           widthForSection:(NSInteger)section
{
    return 60.0f;
}

- (CGFloat)A3GridTableView:(A3GridTableView *)gridTableView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)A3GridTableView:(A3GridTableView *)tableView
       numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInA3GridTableView:(A3GridTableView *)gridTableView
{
    return [self.images count] + 1;
}

#pragma mark - a3grid delegate

- (void)A3GridTableView:(A3GridTableView *)gridTableView
didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (indexPath.section < self.images.count)
    {
        [self.images removeObjectAtIndex:indexPath.section];
        [self.gridTableImages reloadData];
    }
    else
    {
        if (self.images.count == 0)
        {
            UIImagePickerController *picker = [UIImagePickerController new];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            
            [self presentViewController:picker
                               animated:YES
                             completion:nil];
        }
    }
    [gridTableView deselectCellAtIndexPath:indexPath
                                  animated:NO];
}

#pragma mark - image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.images addObject:image];
    [self.gridTableImages reloadData];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellTableViewCell = @"__follower_cell__";
    GVATwitterCell *cell = (GVATwitterCell *)[tableView dequeueReusableCellWithIdentifier:kCellTableViewCell];
        
    __block TUser *user = [self.user.followers objectAtIndex:indexPath.row];
    __weak GVATwitterCell *wCell = cell;
    
    void (^updateCellWithUser)() =
    ^{
        __strong GVATwitterCell *sCell = wCell;
        if (!sCell)
        {
            return;
        }
        [cell.imageViewAvatar setImageWithURL:user.profile_image_url];
        cell.textLabelScreenName.text = user.screen_name;
        cell.textLabelLocation.text = user.location;
    };
    
    if (!user.profile_image_url)
    {
        [user updateDataAsync:^(NSError *error) {
            if (!error)
            {
                updateCellWithUser();
            }
            else
            {
                cell.textLabelLocation.text = @"Error update!";
            }
        }];
    }
    else
    {
        updateCellWithUser();
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.user.followers.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (((indexPath.section + 1) * (indexPath.row + 1)) == self.user.followers.count)
    {
        if (self.user.isAvailableUpdateNextPartFollowers)
        {
            [self _updateNewFollowers:nil];
        }
    }
}

#pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    
    return YES;
}

@end
