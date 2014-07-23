//
//  PGFramesButton.h
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    PGFramesButtonState1Frame = 1,
    PGFramesButtonState4Frame = 4,
    PGFramesButtonState9Frame = 9,
    PGFramesButtonState16Frame = 16
}PGFramesButtonState;
@interface PGFramesButton : UIButton

@property (assign, nonatomic) PGFramesButtonState buttonState;

@end
