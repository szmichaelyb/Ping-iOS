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
    _nameLabel.text = _profileUser[kPFUser_Name];
    
    _headerView.image = [self blur:_profileIV.image];
    [self.tableView addParallelViewWithUIView:view withDisplayRadio:0.6 headerViewStyle:ZGScrollViewStyleDefault];
    
    [_followersButton setTitle:@"0 followers" forState:UIControlStateNormal];
    [_followingButton setTitle:@"0 following" forState:UIControlStateNormal];
    _postCountLabel.text = @"0 post";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
    
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

#pragma mark -

-(void)getData
{
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
    [self getData];
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
                            [self getData];
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

- (UIImage*)blur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

@end
