//
//  PGProfileViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGProfileViewController.h"
#import "PGFeedTableView.h"
#import <STZPullToRefresh/STZPullToRefresh.h>

@interface PGProfileViewController ()<PGFeedTableViewDelegate, STZPullToRefreshDelegate>

@property (nonatomic, strong) STZPullToRefresh *pullToRefresh;
@property (nonatomic, strong) PGFeedTableView* tableView;

@end

@implementation PGProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[PGFeedTableView alloc] initWithFrame:self.view.frame];
    self.tableView.myDelegate = self;
    self.tableView.feedType = FeedTypeMine;
    [self.view addSubview:self.tableView];
    
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;

    STZPullToRefreshView *refreshView = [[STZPullToRefreshView alloc] initWithFrame:CGRectMake(0, refreshBarY, self.view.frame.size.width, 3)];
    [self.view addSubview:refreshView];
    
    self.pullToRefresh = [[STZPullToRefresh alloc] initWithTableView:self.tableView refreshView:refreshView tableViewDelegate:self.tableView];
    self.tableView.delegate = self.pullToRefresh;
    self.pullToRefresh.delegate = self;
    
    [self.pullToRefresh startRefresh];
}

-(void)pullToRefreshDidStart
{
    [self.tableView getObjectsFromParseCompletion:^(bool finished) {
        [self.pullToRefresh finishRefresh];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(PGFeedTableView *)tableView didTapOnImageView:(UIImageView *)imageView
{
    
}

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath *)indexPath
{
    
}

@end
