//
//  PGSearchUserTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    FollowButtonStateNotFollowing,
    FollowButtonStateFollowing
}FollowButtonStatus;

@protocol PGSearchUserTableViewCellDelegate;

@interface PGSearchUserTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbIV;

@property (assign, nonatomic) id<PGSearchUserTableViewCellDelegate> delegate;

-(FollowButtonStatus)followButtonStatus;
-(void)setFollowButtonStatus:(FollowButtonStatus)status;

@end

@protocol PGSearchUserTableViewCellDelegate <NSObject>

-(void)buttonTappedOnCell:(PGSearchUserTableViewCell*)cell;

@end