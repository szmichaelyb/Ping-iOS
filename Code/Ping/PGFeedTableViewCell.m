//
//  PGFeedTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedTableViewCell.h"

@interface PGFeedTableViewCell()

- (IBAction)moreButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;

@end

@implementation PGFeedTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.thumbIV.layer.cornerRadius = self.thumbIV.frame.size.width/2;
    self.thumbIV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreButtonClicked:(id)sender {
    if (_delegate) {
        [_delegate cellDidTapOnMoreButton:self];
    }
}

- (IBAction)likeButtonClicked:(id)sender {
    if (_delegate) {
        [_delegate cellDidTapOnLikeButton:self];
    }
}

@end
