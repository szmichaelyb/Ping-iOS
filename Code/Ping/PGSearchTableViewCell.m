//
//  PGSearchTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSearchTableViewCell.h"

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

@end
