//
//  PGFeedTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGFeedTableViewCellDelegate;

@interface PGFeedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* iv;
@property (strong, nonatomic) IBOutlet UILabel* captionLabel;
@property (strong, nonatomic) IBOutlet UILabel* nameLabel;
@property (strong, nonatomic) IBOutlet UILabel* timeAndlocationLabel;
@property (strong, nonatomic) IBOutlet UIImageView* thumbIV;
@property (strong, nonatomic) IBOutlet UILabel* featuredLabel;

@property (assign, nonatomic) id<PGFeedTableViewCellDelegate> delegate;

-(void)setLikeButtonState:(BOOL)liked;
-(BOOL)likeButtonState;

@end

@protocol PGFeedTableViewCellDelegate <NSObject>

-(void)cellDidTapOnLikeButton:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnMoreButton:(PGFeedTableViewCell*)cell;

@end