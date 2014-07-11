//
//  PGMainViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGTabViewController.h"
#import <XHTwitterPaggingViewer/XHTwitterPaggingViewer.h>
#import "PGFeedViewController.h"

@interface PGTabViewController ()

@end

@implementation PGTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PGFeedViewController* feed1 = [sb instantiateViewControllerWithIdentifier:@"PGFeedViewController"];
    feed1.feedType = FeedTypeOther;
    feed1.title = @"Other";
    
    PGFeedViewController* feed2 = [sb instantiateViewControllerWithIdentifier:@"PGFeedViewController"];
    feed2.feedType = FeedTypeMine;
    feed2.title = @"Mine";
    
    UINavigationController* navC = self.viewControllers[0];
    XHTwitterPaggingViewer* paggingViewer = navC.viewControllers[0];
    paggingViewer.navigationController.navigationBar.translucent = NO;
    paggingViewer.viewControllers = @[feed1, feed2];
    
    [self setSelectedIndex:1];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    DLog(@"selected");
    
    if ([[tabBar items] indexOfObject:item] == 0) {
        item.badgeValue = nil;
        PFInstallation* installation = [PFInstallation currentInstallation];
//        if (installation.badge != 0) {
            installation.badge = 0;
            [installation saveEventually];
//        }
    }
}

@end
