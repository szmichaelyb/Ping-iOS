//
//  PGSearchTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSearchTableViewCell.h"

@interface PGSearchTableViewCell()

@property (strong, nonatomic) IBOutlet UIButton *followButton;

@end

@implementation PGSearchTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)inviteTapped:(id)sender {
    if (_delegate) {
        [_delegate buttonTappedOnCell:self];
    }
}

-(FollowButtonStatus)followButtonStatus
{
    if ([[_followButton titleForState:UIControlStateNormal] isEqualToString:@"Follow"]) {
        return FollowButtonStateNotFollowing;
    }
    return FollowButtonStateFollowing;
}

-(void)setFollowButtonStatus:(FollowButtonStatus)status
{
    if (status == FollowButtonStateFollowing) {
        [_followButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

@end