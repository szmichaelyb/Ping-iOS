//
//  PGPingViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGCamViewController.h"

@interface PGPingViewController : UIViewController<UINavigationControllerDelegate>

@property (assign, nonatomic) id<PGCamViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray* images;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;

@end