//
//  PGFeedTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedTableViewCell.h"

@implementation PGFeedTableViewCell

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
    self.thumbIV.layer.cornerRadius = self.thumbIV.frame.size.width/2;
    self.thumbIV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(self.iv.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = self.iv.frame;
    imageRect.origin.y = -(difference/2)+move;
    self.iv.frame = imageRect;
}

@end
