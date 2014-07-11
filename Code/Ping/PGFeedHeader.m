//
//  PGFeedHeader.m
//  Ping
//
//  Created by Rishabh Tayal on 7/11/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedHeader.h"

@implementation PGFeedHeader

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    _thumbIV.layer.cornerRadius = _thumbIV.frame.size.width/2;
    _thumbIV.layer.masksToBounds = YES;
}

@end
