//
//  UIView+Animate.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "UIView+Animate.h"
#import <pop/POP.h>

@implementation UIView (Animate)

-(void)springAnimate
{
    CALayer *layer = self.layer;
    
    // First let's remove any existing animations
    [layer pop_removeAllAnimations];
    POPSpringAnimation  *anim1 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    
    anim1.toValue = [NSValue valueWithCGSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    anim1.springBounciness = 20;
    anim1.springSpeed = 16;
    
    anim2.toValue = [NSValue valueWithCGSize:CGSizeMake(self.frame.size.width + 10, self.frame.size.height + 10)];
    anim2.springSpeed = 16;
//    sender.tintColor = [UIColor redColor];
    
    anim2.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        NSLog(@"Animation has completed.");
        [layer pop_addAnimation:anim1 forKey:@"size"];
    };
    [layer pop_addAnimation:anim2 forKey:@"size"];

}

@end
