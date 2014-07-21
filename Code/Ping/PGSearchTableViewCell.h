//
//  PGSearchTableViewCell.h
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

@protocol PGSearchTableViewCellDelegate;

@interface PGSearchTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbIV;

@property (assign, nonatomic) id<PGSearchTableViewCellDelegate> delegate;

-(FollowButtonStatus)followButtonStatus;
-(void)setFollowButtonStatus:(FollowButtonStatus)status;

@end

@protocol PGSearchTableViewCellDelegate <NSObject>

-(void)buttonTappedOnCell:(PGSearchTableViewCell*)cell;

@end