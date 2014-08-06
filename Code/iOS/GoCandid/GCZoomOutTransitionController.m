//
//  GCZoomOutTransitionController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 8/6/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCZoomOutTransitionController.h"
#import "PGSendPingViewController.h"
#import "PGPingViewController.h"

@implementation GCZoomOutTransitionController


-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    PGSendPingViewController *fromViewController = (PGSendPingViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PGPingViewController *toViewController = (PGPingViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // Get a snapshot of the image view
    UIView *imageSnapshot = [fromViewController.imageView snapshotViewAfterScreenUpdates:NO];
    imageSnapshot.frame = [containerView convertRect:fromViewController.imageView.frame fromView:fromViewController.imageView.superview];
    fromViewController.imageView.hidden = YES;
    
    // Get the cell we'll animate to
//    DSLThingCell *cell = [toViewController collectionViewCellForThing:fromViewController.thing];
    toViewController.imageView.hidden = YES;
    
    // Setup the initial view states
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    [containerView addSubview:imageSnapshot];
    
    [UIView animateWithDuration:duration animations:^{
        // Fade out the source view controller
        fromViewController.view.alpha = 0.0;
        
        // Move the image view
        imageSnapshot.frame = [containerView convertRect:toViewController.imageView.frame fromView:toViewController.imageView.superview];
    } completion:^(BOOL finished) {
        // Clean up
        [imageSnapshot removeFromSuperview];
        fromViewController.imageView.hidden = NO;
        toViewController.imageView.hidden = NO;
        
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
