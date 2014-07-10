//
//  UIViewController+Transitions.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "UIViewController+Transitions.h"
#import <pop/POP.h>

@implementation UIViewController (Transitions)

-(void)dismissModalViewController
{
//    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
//    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CALayer *layer = self.view.layer;
    [layer pop_removeAllAnimations];
    
    NSLog(@"Layer frame X: %f", layer.frame.origin.x);
    NSLog(@"Layer frame width: %f", layer.frame.size.width);
    
    POPSpringAnimation *yAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    POPSpringAnimation *sizeAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
    
    yAnim.toValue = @(-620);
    yAnim.springBounciness = 16;
    yAnim.springSpeed = 10;
    
    // About 20% of it's normal size
//    sizeAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(100, 400)];
    
    yAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        NSLog(@"Animation has completed.");
        NSLog(@"Layer frame X: %f", layer.frame.origin.x);
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    
    [layer pop_addAnimation:yAnim forKey:@"position"];
    [layer pop_addAnimation:sizeAnim forKey:@"size"];
    
//    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
}

@end
