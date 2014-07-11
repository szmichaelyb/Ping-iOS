//
//  PGFeedViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STZPullToRefresh/STZPullToRefresh.h>

typedef enum {
    FeedTypeMine = 0,
    FeedTypeOther
}FeedType;

@interface PGFeedViewController : UIViewController<UITableViewDataSource, STZPullToRefreshDelegate, UITableViewDelegate>

@property (assign, nonatomic) FeedType feedType;

@end
