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
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    /// Setup pull to refresh
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.tableView = [[PGFeedTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.myDelegate = self;
    UILabel* emptyView = [[UILabel alloc] initWithFrame:self.tableView.frame];
    emptyView.text = @"No Ping yet.";
    emptyView.textAlignment = NSTextAlignmentCenter;
    emptyView.textColor = [UIColor lightGrayColor];
    self.tableView.emptyView = emptyView;
    self.tableView.contentInset=  UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + refreshBarY, 0);
    [self.view addSubview:self.tableView];
    
    if (!_profileUser) {
        //My profile
        _profileUser = [PFUser currentUser];
        self.tableView.feedType = FeedTypeMine;
    } else {
        //Friends Profile
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.tableView.feedType = FeedTypeFriends;
    }
    
    UIView* view = [[NSBundle mainBundle] loadNibNamed:@"PGProfileHeaderView" owner:self options:nil][0];
    PFFile* file = _profileUser[kPFUser_Picture];
    if (file) {
        _profileIV.image = [UIImage imageWithData:[file getData]];
    } else {
#warning chagne the placeholder image
        _profileIV.image = [UIImage imageNamed:@"example"];
    }
    _profileIV.layer.cornerRadius = _profileIV.frame.size.width/2;
    _profileIV.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileIV.layer.borderWidth = 4;
    _profileIV.layer.masksToBounds = YES;
    _profileIV.userInteractionEnabled = YES;
    
    if ([_profileUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        UITapGestureRecognizer* tapGestuere = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileIVClicked:)];
        [_profileIV addGestureRecognizer:tapGestuere];
    }
    
    _nameLabel.text = _profileUser[kPFUser_Name];
    
    _headerView.image = [_profileIV.image applyLightEffect];
    [self.tableView addParallelViewWithUIView:view withDisplayRadio:0.6 headerViewStyle:ZGScrollViewStyleDefault];
    
    [_followersButton setTitle:@"0 followers" forState:UIControlStateNormal];
    [_followingButton setTitle:@"0 following" forState:UIControlStateNormal];
    _postCountLabel.text = @"0 post";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataAppend:NO];
    
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
    
    PFQuery* postsCountQuery = [PFQuery queryWithClassName:kPFTableName_Selfies];
    [postsCountQuery whereKey:kPFSelfie_Owner equalTo:_profileUser];
    [postsCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        _postCountLabel.text = [NSString stringWithFormat:@"%d posts", number];
    }];
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
    if ([[object[kPFSelfie_Owner] valueForKey:kPFObjectId] isEqualToString:[PFUser currentUser].objectId]) {
        
        [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@[@"Share"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            DLog(@"tapped");
            if (buttonIndex == 0) {
                //Delete
                [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        //Yes
                        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                [[PGProgressHUD sharedInstance] showInView:self.navigationController.view withText:@"Deleted" hideAfter:2];
                            }
                            [self getDataAppend:NO];
                        }];
                    }
                }];
            }
            if (buttonIndex == 1) {
                //Share
                PFObject* pfObject = (PFObject*)object;
                PFFile* file = pfObject[kPFSelfie_Selfie];
                DLog(@"%@",file.url);
                [self shareText:pfObject[kPFSelfie_Caption] andImage:nil andUrl:nil andData:[file getData]];
            }
        }];
    } else {
        [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Share"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                PFFile* file = object[kPFSelfie_Selfie];
                [self shareText:object[kPFSelfie_Caption] andImage:nil andUrl:nil andData:[file getData]];
            }
        }];
    }
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url andData:(NSData*)data
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    if (data) {
        [sharingItems addObject:data];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"blurSegue"]) {
        UINavigationController* parentController=  segue.destinationViewController;
        
        PGSettingsViewController* controller = parentController.viewControllers[0];
        UITableView* target = controller.tableView;
        
        CGRect windowBounds = self.view.window.bounds;
        CGSize windowSize = windowBounds.size;
        
        UIGraphicsBeginImageContextWithOptions(windowSize, YES, 0.0);
        [self.view.window drawViewHierarchyInRect:windowBounds afterScreenUpdates:NO];
        UIImage* snapshot = UIGraphicsGetImageFromCurrentImageContext() ;
        
        UIGraphicsEndImageContext();
        
        snapshot = [snapshot applyLightEffect];
        
        UIImageView* bgIV = [[UIImageView alloc] initWithImage:snapshot];
        target.backgroundView = bgIV;
    }
}

@end
