//
//  PGFindFriendsTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFindFriendsTableViewCell.h"

@interface PGFindFriendsTableViewCell()

@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation PGFindFriendsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(FollowButtonStatus)followButtonStatus
{
    if ([[_actionButton titleForState:UIControlStateNormal] isEqualToString:@"Follow"]) {
        return FollowButtonStateNotFollowing;
    }
    return FollowButtonStateFollowing;
}

-(void)setFollowButtonStatus:(FollowButtonStatus)status
{
    if (status == FollowButtonStateFollowing) {
        [_actionButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [_actionButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

@end
