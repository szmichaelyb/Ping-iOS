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

@interface PGProfileViewController ()<PGFeedTableViewDelegate>

@property (nonatomic, strong) PGFeedTableView* tableView;

@property (nonatomic, strong) IBOutlet UIImageView* headerView;
@property (nonatomic, strong) IBOutlet UIImageView* profileIV;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* followingLabel;
@property (nonatomic, strong) IBOutlet UILabel* followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *postCountLabel;

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
    self.tableView.feedType = FeedTypeMine;
    UILabel* emptyView = [[UILabel alloc] initWithFrame:self.tableView.frame];
    emptyView.text = @"No Ping yet. Create one now.";
    emptyView.textAlignment = NSTextAlignmentCenter;
    emptyView.textColor = [UIColor lightGrayColor];
    self.tableView.emptyView = emptyView;
    self.tableView.contentInset=  UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + refreshBarY, 0);
    [self.view addSubview:self.tableView];
    
    UIView* view = [[NSBundle mainBundle] loadNibNamed:@"PGProfileHeaderView" owner:self options:nil][0];
    PFFile* file = [PFUser currentUser][kPFUser_Picture];
    _profileIV.image = [UIImage imageWithData:[file getData]];
    _profileIV.layer.cornerRadius = _profileIV.frame.size.width/2;
    _profileIV.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileIV.layer.borderWidth = 4;
    _profileIV.layer.masksToBounds = YES;
    _nameLabel.text = [PFUser currentUser][kPFUser_Name];
 
    _headerView.image = [self blur:_profileIV.image];
    [self.tableView addParallelViewWithUIView:view withDisplayRadio:0.6 headerViewStyle:ZGScrollViewStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getData];
    
    PFQuery* followerCountQuery = [PFQuery queryWithClassName:kPFTableActivity];
    [followerCountQuery whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [followerCountQuery whereKey:kPFActivity_ToUser equalTo:[PFUser currentUser]];
    
    _followersLabel.text = [NSString stringWithFormat:@"%d follower", [followerCountQuery countObjects]];
    
    PFQuery* followingCountQuery = [PFQuery queryWithClassName:kPFTableActivity];
    [followingCountQuery whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [followingCountQuery whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    
    _followingLabel.text = [NSString stringWithFormat:@"%d following", [followingCountQuery countObjects]];
    
    PFQuery* postsCountQuery = [PFQuery queryWithClassName:kPFTableName_Selfies];
    [postsCountQuery whereKey:kPFSelfie_Owner equalTo:[PFUser currentUser]];
    _postCountLabel.text = [NSString stringWithFormat:@"%d posts", [postsCountQuery countObjects]];
}

-(void)tableScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self.tableView updateParallelViewWithOffset:scrollView.contentOffset];
    } else {
    }
    
}

-(void)getData
{
    [self.tableView getObjectsFromParseCompletion:^(bool finished) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PGFeedTableView Delegate

-(void)tableView:(PGFeedTableView *)tableView didTapOnImageView:(UIImageView *)imageView
{
    
}

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath *)indexPath dataObject:(id)object
{
    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        DLog(@"tapped");
        if (buttonIndex == 0) {
            //Delete
            [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //Yes
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [[PGProgressHUD sharedInstance] showInView:self.navigationController.view withText:@"Deleted"];
                        }
                        [self getData];
                    }];
                }
            }];
        }
    }];
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
