//
//  PGFindFriendsTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    FollowButtonStateNotFollowing,
    FollowButtonStateFollowing,
    FollowButtonStateInvite,
    FollowButtonStateInvited
}FollowButtonStatus;

@protocol PGFindFriendsCellDelegate;

@interface PGFindFriendsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign, readonly) FollowButtonStatus followButtonStatus;
@property (nonatomic, strong) id<PGFindFriendsCellDelegate> delegate;

//-(FollowButtonStatus)followButtonStatus;
-(void)setFollowButtonStatus:(FollowButtonStatus)status;

@end

@protocol PGFindFriendsCellDelegate <NSObject>

-(void)cell:(PGFindFriendsTableViewCell*)cell didClickOnButton:(UIButton*)button;

@end