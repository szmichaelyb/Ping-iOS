//
//  PGFeedTableView.h
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGFeedTableViewCell.h"

typedef enum {
    FeedTypeOther = 0,
    FeedTypeMine,
    FeedTypeFriends
}FeedType;

@protocol PGFeedTableViewDelegate;

@interface PGFeedTableView : UITableView<UITableViewDataSource, UITableViewDelegate, PGFeedTableViewCellDelegate>

@property (assign, nonatomic) FeedType feedType;
@property (assign, nonatomic) id<PGFeedTableViewDelegate> myDelegate;
@property (strong, nonatomic) UIView* emptyView;

-(void)refreshDatasource;
-(void)getFeedForUser:(PFUser*)user completion:(void (^) (bool finished))block;

@end

@protocol PGFeedTableViewDelegate<NSObject>

-(void)tableView:(PGFeedTableView*)tableView willDisplayLastCell:(UITableViewCell*)cell;
-(void)tableView:(PGFeedTableView*)tableView didTapOnImageView:(UIImageView*)imageView;
-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath*)indexPath dataObject:(id)object;

@optional
-(void)tableScrollViewDidScroll:(UIScrollView*)scrollView;
-(void)tablescrollViewDidScrollToTop:(UIScrollView*)scrollView;

@end