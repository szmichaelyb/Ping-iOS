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

- (IBAction)actionButtonClicked:(UIButton *)sender;

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

//-(FollowButtonStatus)followButtonStatus
//{
//    if ([[_actionButton titleForState:UIControlStateNormal] isEqualToString:@"Follow"]) {
//        return FollowButtonStateNotFollowing;
//    } else if ([[_actionButton titleForState:UIControlStateNormal] i])
//    return FollowButtonStateFollowing;
//}

-(void)setFollowButtonStatus:(FollowButtonStatus)status
{
    if (status == FollowButtonStateFollowing) {
        [_actionButton setTitle:@"Following" forState:UIControlStateNormal];
        _actionButton.enabled = true;
    } else if (status == FollowButtonStateNotFollowing) {
        [_actionButton setTitle:@"Follow" forState:UIControlStateNormal];
        _actionButton.enabled = true;
    } else if (status == FollowButtonStateInvite) {
        [_actionButton setTitle:@"Invite" forState:UIControlStateNormal];
        _actionButton.enabled = true;
    } else {
        [_actionButton setTitle:@"Invited" forState:UIControlStateNormal];
        _actionButton.enabled = false;
    }
    _followButtonStatus = status;
}

- (IBAction)actionButtonClicked:(UIButton *)sender {
    if (_delegate) {
        [_delegate cell:self didClickOnButton:sender];
    }
}

@end
