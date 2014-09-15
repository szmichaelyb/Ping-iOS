//
//  GCCombineTransitionController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 9/15/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCCombineTransitionController.h"
#import "PGPingViewController.h"
#import "GCReviewViewController.h"
#import "GCReviewCell.h"

@implementation GCCombineTransitionController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    GCReviewViewController* fromViewController = (GCReviewViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PGPingViewController* toViewController = (PGPingViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView* containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UICollectionView* collectionView = fromViewController.collectionView;
    
    /**
     *  Setup initial config
     */
    NSMutableArray* cells = [NSMutableArray new];
    
    for (GCReviewCell* cell  in [collectionView visibleCells]) {
        UIView* cellSnapshot = [cell.imageView snapshotViewAfterScreenUpdates:NO];
        //        cellSnapshot.frame = [containerView convertRect:fromViewController. fromView:]
        CGRect frame = [collectionView layoutAttributesForItemAtIndexPath:[collectionView indexPathForCell:cell]].frame;
        cellSnapshot.frame = frame;
        cell.imageView.hidden = YES;
        [cells addObject:cellSnapshot];
    }
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    toViewController.imageView.hidden = YES;
    
    [containerView addSubview:toViewController.view];
    for (UIView* cell in cells) {
        [containerView addSubview:cell];
    }
    
    //Perform animation
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.alpha = 1;
        
        CGRect frame = [containerView convertRect:toViewController.imageView.frame fromView:toViewController.view];
        for (UIView* cell in cells) {
            cell.frame = frame;
        }
    } completion:^(BOOL finished) {
        toViewController.imageView.hidden = NO;
        
        for (UIView* cel in cells) {
            [cel removeFromSuperview];
        }
        
        for (int i = 0; i < [collectionView numberOfItemsInSection:0]; i++) {
            GCReviewCell* cell = (GCReviewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            cell.imageView.hidden = NO;
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
