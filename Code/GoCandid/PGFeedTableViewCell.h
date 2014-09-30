//
//  PGFeedTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTweetLabel/STTweetLabel.h>

@protocol PGFeedTableViewCellDelegate;

@interface PGFeedTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView* blurBgIV;
@property (strong, nonatomic) IBOutlet UIImageView* mainIV;
@property (strong, nonatomic) IBOutlet STTweetLabel* captionLabel;
//@property (strong, nonatomic) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UIButton* nameButton;
@property (strong, nonatomic) IBOutlet UILabel* timeAndlocationLabel;
@property (strong, nonatomic) IBOutlet UIImageView* thumbIV;
//@property (nonatomic, strong) IBOutlet UIButton* thumbButton;
@property (nonatomic, strong) IBOutlet UIView* featuredView;

@property (nonatomic, strong) IBOutlet UILabel* totalLikes;
@property (nonatomic, strong) IBOutlet UIButton* commentButton;

@property (assign, nonatomic) id<PGFeedTableViewCellDelegate> delegate;

-(void)setLikeButtonState:(BOOL)liked;
-(BOOL)likeButtonState;

@end

@protocol PGFeedTableViewCellDelegate <NSObject>

//-(void)cellDidStartTap:(PGFeedTableViewCell*)cell;
//-(void)cellDidStopTap:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnNameButton:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnThumbButton:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnLikeButton:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnCommentButton:(PGFeedTableViewCell*)cell;
-(void)cellDidTapOnMoreButton:(PGFeedTableViewCell*)cell;
@end