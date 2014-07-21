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
    FollowButtonStateFollowing
}FollowButtonStatus;

@interface PGFindFriendsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

-(FollowButtonStatus)followButtonStatus;
-(void)setFollowButtonStatus:(FollowButtonStatus)status;

@end
