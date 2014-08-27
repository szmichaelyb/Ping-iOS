//
//  PGFeedViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedViewController.h"
#import "PGFeedTableViewCell.h"
#import <pop/POP.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import "PGFeedHeader.h"
#import "PGFeedTableView.h"
#import "PGProgressHUD.h"
#import <GTScrollNavigationBar/GTScrollNavigationBar.h>
#import "UIView+HidingView.h"
#import "PGProfileViewController.h"
#import "GCSharePost.h"

@interface PGFeedViewController ()<PGFeedTableViewDelegate>
{
    CGRect originalFrame;
}

@property (strong, nonatomic) IBOutlet PGFeedTableView* tableView;
@property (nonatomic, strong) IBOutlet  UIView* segBGBlurView;

//@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, strong) STZPullToRefresh *pullToRefresh;
@property (nonatomic, strong) PFUser* feedUser;

-(IBAction)segChanged:(UISegmentedControl*)sender;

@end

@implementation PGFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grandhotel"]];
    //    _segBGBlurView.dynamic = NO;
//    _segBGBlurView.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1];
//    _segBGBlurView.contentMode = UIViewContentModeTop;
    
//    [_segBGBlurView updateAsynchronously:YES completion:^{
//    }];
    
    /// Setup pull to refresh
//    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    //    self.tableView = [[PGFeedTableView alloc] initWithFrame:self.view.bounds];
    [self.tableView setup];
    self.tableView.myDelegate = self;
    self.tableView.feedType = FeedTypeOther;
    DLog(@"%f", self.tabBarController.tabBar.frame.size.height);
//    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + refreshBarY, 0);
//    [self.view addSubview:self.tableView];
    
    STZPullToRefreshView *refreshView = [[STZPullToRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    [self.view addSubview:refreshView];
    
    self.pullToRefresh = [[STZPullToRefresh alloc] initWithTableView:self.tableView refreshView:refreshView tableViewDelegate:self.tableView];
    self.tableView.delegate = self.pullToRefresh;
    self.pullToRefresh.delegate = self;
    
    [self.pullToRefresh startRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.scrollNavigationBar.scrollView = self.tableView;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    originalFrame = self.tabBarController.tabBar.frame;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.scrollNavigationBar.scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pullToRefreshDidStart
{
    [self.tableView refreshDatasource];
    [self.tableView getFeedForUser:_feedUser completion:^(bool finished) {
        [self.pullToRefresh finishRefresh];
    }];
}

-(void)segChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.tableView.feedType = FeedTypeOther;
    } else {
        self.tableView.feedType = FeedTypeRecent;
    }
    [self.tableView refreshDatasource];
    [self.tableView getFeedForUser:_feedUser completion:^(bool finished) {
        
    }];
}

#pragma mark - PGFeedTableView Delegate

-(void)tableScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.segBGBlurView scrollViewWillBeginDragging:scrollView];
}

-(void)tableScrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.segBGBlurView scrollViewDidScroll:scrollView];
}

-(void)tablescrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:YES];
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnNameButton:(NSIndexPath *)indexPath dataObject:(id)object
{
    PGProfileViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PGProfileViewController"];
    DLog(@"%@", object);
    profileVC.profileUser = object[kPFSelfie_Owner];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnThumbButton:(NSIndexPath *)indexPath dataObject:(id)object
{
    PGProfileViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PGProfileViewController"];
    DLog(@"%@", object);
    profileVC.profileUser = object[kPFSelfie_Owner];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)tableView:(PGFeedTableView *)tableView willDisplayLastCell:(UITableViewCell *)cell
{
    [self.tableView getFeedForUser:_feedUser completion:nil];
}

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath*)indexPath dataObject:(id)object
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];

    [sheet addButtonWithTitle:@"Share"];
    sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"Report Inappropriate"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    
    sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            
            [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    object[kPFSelfie_Abuse] = [NSNumber numberWithInt:[object[kPFSelfie_Abuse] intValue] + 1];
                    
                    //                    object[kPFSelfie_Abuse] = [NSNumber numberWithBool:YES];
                    [object saveEventually:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [[PGProgressHUD sharedInstance] showInView:self.navigationController.view withText:@"Reported" hideAfter:2 progressType:PGProgressHUDTypeCheck];
                        }
                    }];
                }
            }];
        }
        
        if (buttonIndex == 0) {
            //Share
            [UIActionSheet showInView:self.view.window withTitle:@"Share" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Facebook", @"Twitter"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //Facebook
                } else if (buttonIndex == 1) {
                    //Twitter
                    [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Posting..." hideAfter:1.0 progressType:PGProgressHUDTypeDefault];
                    [GCSharePost postOnTwitterObject:object completion:^(BOOL success) {
//                        [[PGProgressHUD sharedInstance] hide:YES];
                        if (success) {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Success" hideAfter:2 progressType:PGProgressHUDTypeCheck];
                        } else {
#warning Change to error sign
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Could not post" hideAfter:2 progressType:PGProgressHUDTypeError];
                        }
                    }];
                }
            }];
        }
    };
    
    [sheet showInView:self.view.window];
//    
//    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report inappropriate" otherButtonTitles:@[@"Share"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
//        DLog(@"%d", buttonIndex);
//      
//    }];
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnKeyword:(NSString *)keyword
{
    DLog(@"Tapped on: %@", keyword);
//#warning create and push proper view controller
    UIViewController* controller = [[UIViewController alloc] init];
    controller.title = keyword;
    PGFeedTableView* table = [[PGFeedTableView alloc] initWithFrame:controller.view.bounds];
    [table getFeedForHashTag:keyword completion:nil];
    [controller.view addSubview:table];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
