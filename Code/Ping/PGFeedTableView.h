//
//  PGFeedTableView.h
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    FeedTypeOther = 0,
    FeedTypeMine,
    FeedTypeFeatured
}FeedType;

@protocol PGFeedTableViewDelegate;

@interface PGFeedTableView : UITableView<UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) FeedType feedType;
@property (assign, nonatomic) id<PGFeedTableViewDelegate> myDelegate;
@property (strong, nonatomic) UIView* emptyView;

-(void)getObjectsFromParseCompletion:(void (^) (bool finished))block;

@end

@protocol PGFeedTableViewDelegate<NSObject>

-(void)tableView:(PGFeedTableView*)tableView didTapOnImageView:(UIImageView*)imageView;
-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath*)indexPath dataObject:(id)object;

@optional
-(void)tableScrollViewDidScroll:(UIScrollView*)scrollView;

@end