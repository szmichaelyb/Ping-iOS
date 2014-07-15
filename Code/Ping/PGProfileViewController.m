//
//  PGProfileViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGProfileViewController.h"
#import "PGFeedTableView.h"

@interface PGProfileViewController ()<PGFeedTableViewDelegate>

@end

@implementation PGProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PGFeedTableView* tableView = [[PGFeedTableView alloc] initWithFrame:self.view.frame];
    tableView.myDelegate = self;
    tableView.feedType = FeedTypeMine;
    [tableView getObjectsFromParseCompletion:^(bool finished) {
        
    }];
    [self.view addSubview:tableView];
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
