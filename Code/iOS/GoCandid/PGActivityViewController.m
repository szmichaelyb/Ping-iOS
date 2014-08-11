//
//  PGActivityViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGActivityViewController.h"
#import "PGActivityTableViewCell.h"
#import <TTTTimeIntervalFormatter.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>
#import "PGProfileViewController.h"

@interface PGActivityViewController ()

//@property (nonatomic, strong) IBOutlet UITableView* tableView;
//@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
//@property (nonatomic, strong) NSDate *lastRefresh;
//@property (nonatomic, strong) UIView *blankTimelineView;

@end

@implementation PGActivityViewController

#pragma mark - Initialization

- (void)dealloc {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = kPFTableActivity;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    //    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    //    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    //    self.tableView.backgroundView = texturedBackgroundView;
    //
    //    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    self.tableView.nxEV_hideSeparatorLinesWheyShowingEmptyView = YES;
    UILabel* label = [[UILabel alloc] initWithFrame:self.view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"No activity yet.";
    label.textColor = [UIColor lightGrayColor];
    self.tableView.nxEV_emptyView = label;
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    
    //    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    //    [button setFrame:CGRectMake(24.0f, 113.0f, 271.0f, 140.0f)];
    //    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.blankTimelineView addSubview:button];
    
    //    _lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [PGActivityViewController stringForActivityType:(NSString*)[object objectForKey:kPFActivity_Type]];
        
        PFUser *user = (PFUser*)[object objectForKey:kPFActivity_FromUser];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kPFUser_Name] && [[user objectForKey:kPFUser_Name] length] > 0) {
            nameString = [user objectForKey:kPFUser_Name];
        }
        return 60;
        //        return [PAPActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 60.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kPFActivity_Selfie]) {
            //            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey]];
            //            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPFActivity_FromUser]) {
            
            PGProfileViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PGProfileViewController"];
            profileVC.profileUser = activity[kPFActivity_FromUser];
            [self.navigationController pushViewController:profileVC animated:YES];
            
            //            PAPAccountViewController *detailViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            //            [detailViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            //            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPFActivity_ToUser equalTo:[PFUser currentUser]];
    [query whereKey:kPFActivity_FromUser notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kPFActivity_FromUser];
    [query includeKey:kPFActivity_FromUser];
    [query includeKey:kPFActivity_Selfie];
    [query orderByDescending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    //    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
    //        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    //    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    //    lastRefresh = [NSDate date];
    //    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        
        //        if (!self.blankTimelineView.superview) {
        //            self.blankTimelineView.alpha = 0.0f;
        //            self.tableView.tableHeaderView = self.blankTimelineView;
        //
        //            [UIView animateWithDuration:0.200f animations:^{
        //                self.blankTimelineView.alpha = 1.0f;
        //            }];
        //        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        //        for (PFObject *activity in self.objects) {
        //            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
        //                unreadCount++;
        //            }
        //        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";
    PGActivityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath object:object];
    
    return cell;
}

-(void)configureCell:(PGActivityTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath object:(PFObject*)object
{
    DLog(@"%@", object);
    
    if ([object[kPFActivity_Type] isEqualToString:kPFActivity_Type_Like]) {
        cell.activityLabel.text = [NSString stringWithFormat:@"%@ liked your post", object[kPFActivity_FromUser][kPFUser_Name]];
    } else if ([object[kPFActivity_Type] isEqualToString:kPFActivity_Type_Follow]) {
        cell.activityLabel.text = [NSString stringWithFormat:@"%@ followed you." , object[kPFActivity_FromUser][kPFUser_Name]];
    }
    
    TTTTimeIntervalFormatter* tif = [[TTTTimeIntervalFormatter alloc] init];
    NSString* str = [tif stringForTimeInterval:[object.updatedAt timeIntervalSinceNow]];
    cell.activityDate.text = str;
    
    [PGParseHelper profilePhotoUser:object[kPFActivity_FromUser] completion:^(UIImage *image) {
        cell.thumbIV.image = image;
    }];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
//
////    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
////    if (!cell) {
////        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
////        cell.selectionStyle = UITableViewCellSelectionStyleGray;
////        cell.hideSeparatorBottom = YES;
////        cell.mainView.backgroundColor = [UIColor clearColor];
////    }
////    return cell;
//    return nil;
//}


#pragma mark - PAPActivityCellDelegate Methods

//- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
//    // Get image associated with the activity
//    PFObject *photo = [activity objectForKey:kPAPActivityPhotoKey];
//
//    // Push single photo view controller
//    PAPPhotoDetailsViewController *photoViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
//    [self.navigationController pushViewController:photoViewController animated:YES];
//}
//
//- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
//    // Push account view controller
//    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
//    [accountViewController setUser:user];
//    [self.navigationController pushViewController:accountViewController animated:YES];
//}

#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPFActivity_Type_Like]) {
        return NSLocalizedString(@"liked your photo", nil);
    } else if ([activityType isEqualToString:kPFActivity_Type_Follow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kPFActivity_Type_Comment]) {
        return NSLocalizedString(@"commented on your photo", nil);
    } else if ([activityType isEqualToString:kPFActivity_Type_Joined]) {
        return NSLocalizedString(@"joined GoCandid", nil);
    } else {
        return nil;
    }
}

#pragma mark - ()

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note
{
    [self loadObjects];
}

@end
