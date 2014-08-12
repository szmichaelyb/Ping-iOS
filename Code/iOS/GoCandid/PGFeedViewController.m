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
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
//    _segBGBlurView.dynamic = NO;
//    _segBGBlurView.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1];
//    _segBGBlurView.contentMode = UIViewContentModeTop;
    
//    [_segBGBlurView updateAsynchronously:YES completion:^{
//    }];
    
    /// Setup pull to refresh
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
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
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

-(void)tableView:(PGFeedTableView *)tableView willDisplayLastCell:(UITableViewCell *)cell
{
    [self.tableView getFeedForUser:_feedUser completion:nil];
}

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath*)indexPath dataObject:(id)object
{
    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report inappropriate" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        DLog(@"%d", buttonIndex);
        if (buttonIndex == 0) {
            
            [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //                    DLog(@"%@", _datasource[indexPath.row]);
                    
                    //                    PFObject* object = object;
                    object[kPFSelfie_Abuse] = [NSNumber numberWithBool:YES];
                    [object saveEventually:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [[PGProgressHUD sharedInstance] showInView:self.navigationController.view withText:@"Reported" hideAfter:2];
                        }
                    }];
                }
            }];
        }
    }];
}

@end
