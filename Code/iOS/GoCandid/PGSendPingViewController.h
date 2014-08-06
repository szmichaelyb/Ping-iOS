//
//  PGSendPingViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/22/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGCamViewController.h"

@interface PGSendPingViewController : UIViewController<CLLocationManagerDelegate>

@property (assign, nonatomic) id<PGCamViewControllerDelegate> delegate;
@property (strong, nonatomic) NSURL* gifUrl;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;

@end
