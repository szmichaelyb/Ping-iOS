//
//  GCReviewViewController.h
//  GoCandid
//
//  Created by Rishabh Tayal on 9/13/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGCamViewController.h"

@interface GCReviewViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign, nonatomic) id<PGCamViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* images;


@end
