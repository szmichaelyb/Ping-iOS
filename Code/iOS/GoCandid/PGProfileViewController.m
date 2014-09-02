//
//  PGProfileViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGProfileViewController.h"
#import "PGFeedTableView.h"
#import <UITableView+ZGParallelView.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import "PGProgressHUD.h"
#import "GCUsersListViewController.h"
#import <IDMPhotoBrowser.h>
#import "UIImage+MyUIImage.h"
#import "PGSettingsViewController.h"
#import "GCSharePost.h"

@interface PGProfileViewController ()<PGFeedTableViewDelegate>

@property (nonatomic, strong) PGFeedTableView* tableView;

@property (nonatomic, strong) IBOutlet UIImageView* headerView;
@property (nonatomic, strong) IBOutlet UIImageView* profileIV;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UIButton* followingButton;
@property (nonatomic, strong) IBOutlet UIButton* followersButton;
@property (strong, nonatomic) IBOutlet UILabel *postCountLabel;

-(IBAction)followingButtonClicked:(id)sender;
-(IBAction)followersButtonClickedd:(id)sender;

@end

@implementation PGProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.translucent = NO;
    
    /// Setup pull to refresh
//    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.tableView = [[PGFeedTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.myDelegate = self;
    UIImageView* emptyView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    emptyView.image = [UIImage imageNamed:@"NoImageIcon"];
    emptyView.contentMode = UIViewContentModeCenter;
    self.tableView.emptyView = emptyView;
//    self.tableView.contentInset=  UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + refreshBarY, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    [self.view addSubview:self.tableView];
    
    if (!_profileUser) {
        //My profile
        _profileUser = [PFUser currentUser];
        self.tableView.feedType = FeedTypeMine;
    } else {
        //Friends Profile
        UIBarButtonItem* followButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonClicked:)];
        self.navigationItem.rightBarButtonItem = followButtonItem;
        [PGParseHelper isUserFollowingUser:_profileUser completion:^(BOOL finished, BOOL following) {
            if (following) {
                self.navigationItem.rightBarButtonItem.title = @"Following";
            } else
            self.navigationItem.rightBarButtonItem.title = @"Follow";
        }];
        self.navigationItem.leftBarButtonItem = nil;
        self.tableView.feedType = FeedTypeFriends;
    }
    
    UIView* view = [[NSBundle mainBundle] loadNibNamed:@"PGProfileHeaderView" owner:self options:nil][0];
    PFFile* file = _profileUser[kPFUser_Picture];
    if (file) {
        _profileIV.image = [UIImage imageWithData:[file getData]];
    } else {
        _profileIV.image = [UIImage imageNamed:@"NoProfilePhotoIMAGE"];
    }
    _profileIV.layer.cornerRadius = _profileIV.frame.size.width/2;
    _profileIV.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileIV.layer.borderWidth = 4;
    _profileIV.layer.masksToBounds = YES;
    _profileIV.userInteractionEnabled = YES;
    
    if ([_profileUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        //Users profile
        UITapGestureRecognizer* tapGestuere = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileIVClicked:)];
        [_profileIV addGestureRecognizer:tapGestuere];
    }
    
    _nameLabel.text = _profileUser[kPFUser_Name];
    _nameLabel.font = FONT_GEOSANSLIGHT(FONT_SIZE_MEDIUM);
    
    _headerView.image = [_profileIV.image applyLightEffect];
    [self.tableView addParallelViewWithUIView:view withDisplayRadio:0.6 headerViewStyle:ZGScrollViewStyleDefault];
    
    [_followersButton setTitle:@"0 followers" forState:UIControlStateNormal];
    _followersButton.titleLabel.font = FONT_OPENSANS_CONDBOLD(FONT_SIZE_MEDIUM);
    
    [_followingButton setTitle:@"0 following" forState:UIControlStateNormal];
    _followingButton.titleLabel.font = FONT_OPENSANS_CONDBOLD(FONT_SIZE_MEDIUM);
    
    _postCountLabel.text = @"0 post";
    _postCountLabel.font = FONT_OPENSANS_CONDBOLD(FONT_SIZE_MEDIUM);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;

    NSDate* lastRefreshDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"profileLastRefresh"];
    if (!lastRefreshDate) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"profileLastRefresh"];
        [self getDataAppend:NO];
    }
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastRefreshDate];
    int minutes = (interval - ((int)interval/3600 * 3600)) / 60;
    if (minutes >= 5 || self.tableView.numberOfRows == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"profileLastRefresh"];
        [self getDataAppend:NO];
    }

    
    PFQuery* followerCountQuery = [PFQuery queryWithClassName:kPFTableActivity];
    [followerCountQuery whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [followerCountQuery whereKey:kPFActivity_ToUser equalTo:_profileUser];
    [followerCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [_followersButton setTitle:[NSString stringWithFormat:@"%d follower", number]  forState:UIControlStateNormal];
    }];
    
    PFQuery* followingCountQuery = [PFQuery queryWithClassName:kPFTableActivity];
    [followingCountQuery whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [followingCountQuery whereKey:kPFActivity_FromUser equalTo:_profileUser];
    [followingCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [_followingButton setTitle:[NSString stringWithFormat:@"%d following", number]  forState:UIControlStateNormal];
    }];
    
    PFQuery* postsCountQuery = [PFQuery queryWithClassName:kPFTableNameSelfies];
    [postsCountQuery whereKey:kPFSelfie_Owner equalTo:_profileUser];
    [postsCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        _postCountLabel.text = [NSString stringWithFormat:@"%d posts", number];
    }];
}

-(void)followButtonClicked:(UIBarButtonItem*)sender
{
    DLog(@"%@", sender.title);
    if ([sender.title isEqualToString:@"Follow"]) {
        [PGParseHelper followUserInBackground:_profileUser completion:^(bool finished) {
            sender.title = @"Following";
        }];
    } else {
        [UIActionSheet showInView:self.view.window withTitle:_profileUser[kPFUser_Name] cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [PGParseHelper unfollowUserInBackground:_profileUser completion:^(bool finished) {
                    sender.title = @"Follow";
                }];
            }
        }];
    }
}

-(void)profileIVClicked:(id)sender
{
    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[@"View Profile Photo", @"Take Photo", @"Choose Exisiting Photo", @"Import from Facebook"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            //View
            
            IDMPhoto* photo = [IDMPhoto photoWithImage:_profileIV.image];
            IDMPhotoBrowser* photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:_profileIV];
            photoBrowser.scaleImage = _profileIV.image;
            [self presentViewController:photoBrowser animated:YES completion:nil];
            
        } else if (buttonIndex == 1) {
            //Take photo
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if (buttonIndex == 2) {
            //Choose from library
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else if (buttonIndex == 3) {
            //Import from Facebook
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", [PFUser currentUser][kPFUser_FBID]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _profileIV.image = [UIImage imageWithData:imgData];
//                    _headerView.image = [self blur:_profileIV.image];
                    _headerView.image = [_profileIV.image applyLightEffect];
                });
                
                PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
                    [[PFUser currentUser] saveInBackground];
                }];
            });
        }
    }];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        _profileIV.image = info[UIImagePickerControllerOriginalImage];
//        _headerView.image = [self blur:_profileIV.image];
        _headerView.image = [_profileIV.image applyLightEffect];
        
        NSData* imgData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.7);
        PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
            [[PFUser currentUser] saveInBackground];
        }];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

-(void)getDataAppend:(BOOL)append
{
    if (!append) {
        [self.tableView refreshDatasource];
    }
    [self.tableView getFeedForUser:_profileUser completion:^(bool finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(IBAction)followingButtonClicked:(id)sender
{
    GCUsersListViewController* users = [[GCUsersListViewController alloc] init];
    users.listType = GCListTypeFollowing;
    users.listForUser = _profileUser;
    [self.navigationController pushViewController:users animated:YES];
}

-(IBAction)followersButtonClickedd:(id)sender
{
    GCUsersListViewController* users = [[GCUsersListViewController alloc] init];
    users.listType = GCListTypeFollowers;
    users.listForUser = _profileUser;
    [self.navigationController pushViewController:users animated:YES];
}

#pragma mark - PGFeedTableView Delegate

-(void)tableScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self.tableView updateParallelViewWithOffset:scrollView.contentOffset];
    } else {
    }
}

-(void)tableView:(PGFeedTableView *)tableView willDisplayLastCell:(UITableViewCell *)cell
{
    [self getDataAppend:YES];
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnImageView:(UIImageView *)imageView
{
    
}

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath *)indexPath dataObject:(id)object
{
    
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    [sheet addButtonWithTitle:@"Share"];
    if ([[object[kPFSelfie_Owner] valueForKey:kPFObjectId] isEqualToString:[PFUser currentUser].objectId]) {
        sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"Delete"];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    
    sheet.tapBlock = ^(UIActionSheet* actionSheet, NSInteger buttonIndex){
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            //Delete
            DLog(@"Delete");
        [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Deleted" hideAfter:1.0 progressType:PGProgressHUDTypeCheck];
                    }
                    [self getDataAppend:NO];
                }];
            }
        }];
        } else if (buttonIndex == 0) {
            //Share
            DLog(@"Share");
            [UIActionSheet showInView:self.view.window withTitle:@"Share" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Facebook", @"Twitter", @"WhatsApp"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //Facebook
                    [GCSharePost postOnFacebookObject:object completion:^(bool success) {
                        if (success) {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Posted" hideAfter:1.0 progressType:PGProgressHUDTypeCheck];
                        }else {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Could not post" hideAfter:1.0 progressType:PGProgressHUDTypeError];
                        }
                    }];
                } else if (buttonIndex == 1) {
                    //Twitter
                    [GCSharePost postOnTwitterObject:object completion:^(BOOL success) {
                        if (success) {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Posted" hideAfter:1.0 progressType:PGProgressHUDTypeCheck];
                        } else {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Could not post" hideAfter:1.0 progressType:PGProgressHUDTypeError];
                        }
                    }];
                } else if (buttonIndex == 2) {
                    [GCSharePost shareViaWhatsApp:object];
                }
            }];
        }
    };

    [sheet showInView:self.view.window];
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnKeyword:(NSString *)keyword
{
    DLog(@"%@", keyword);
}

#pragma mark -

//- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url andData:(NSData*)data
//{
//    NSMutableArray *sharingItems = [NSMutableArray new];
//    
//    if (text) {
//        [sharingItems addObject:text];
//    }
//    if (image) {
//        [sharingItems addObject:image];
//    }
//    if (url) {
//        [sharingItems addObject:url];
//    }
//    if (data) {
//        [sharingItems addObject:data];
//    }
//    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
//    [self presentViewController:activityController animated:YES completion:nil];
//}

#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"blurSegue"]) {
//        UINavigationController* parentController=  segue.destinationViewController;
//        
//        PGSettingsViewController* controller = parentController.viewControllers[0];
//        UITableView* target = controller.tableView;
//        
//        CGRect windowBounds = self.view.window.bounds;
//        CGSize windowSize = windowBounds.size;
//        
//        UIGraphicsBeginImageContextWithOptions(windowSize, YES, 0.0);
//        [self.view.window drawViewHierarchyInRect:windowBounds afterScreenUpdates:NO];
//        UIImage* snapshot = UIGraphicsGetImageFromCurrentImageContext() ;
//        
//        UIGraphicsEndImageContext();
//        
//        snapshot = [snapshot applyLightEffect];
//        
//        UIImageView* bgIV = [[UIImageView alloc] initWithImage:snapshot];
//        target.backgroundView = bgIV;
    }
}

@end
