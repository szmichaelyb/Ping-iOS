//
//  PGViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRDynamicSlideShow.h"

@interface PGTutorialViewController : UIViewController

@property (nonatomic, weak) IBOutlet DRDynamicSlideShow* slideShow;
@property (nonatomic, weak) IBOutlet UIPageControl* pageControl;

@end
