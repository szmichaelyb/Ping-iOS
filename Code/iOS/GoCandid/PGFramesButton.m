//
//  PGFramesButton.m
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFramesButton.h"

@implementation PGFramesButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.buttonState = PGFramesButtonState9Frame;
        [self setTitle:@"9" forState:UIControlStateNormal];
    }
    return self;
}

-(void)buttonTapped:(id)sender
{
    DLog(@"tapped");
    if (_buttonState == PGFramesButtonState2Frame) {
        _buttonState = PGFramesButtonState4Frame;
    } else if (_buttonState == PGFramesButtonState4Frame) {
        _buttonState = PGFramesButtonState9Frame;
    } else if (_buttonState == PGFramesButtonState9Frame) {
        _buttonState = PGFramesButtonState16Frame;
    } else {
        _buttonState = PGFramesButtonState2Frame;
    }
    
    [self setTitle:[NSString stringWithFormat:@"%d", _buttonState] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
