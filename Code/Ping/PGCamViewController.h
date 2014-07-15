//
//  AVCamViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGCamViewControllerDelegate;

@interface PGCamViewController : UIViewController

@property (strong, nonatomic) UIImage* overalayImage;
@property (assign, nonatomic) id<PGCamViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton* closeButton;

@end

@protocol PGCamViewControllerDelegate <NSObject>

-(void)didDismissCamViewController:(PGCamViewController*)controller;

@end
