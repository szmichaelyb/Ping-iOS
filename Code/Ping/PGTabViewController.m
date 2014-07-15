//
//  PGMainViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGTabViewController.h"
#import "PGFeedViewController.h"

@interface PGTabViewController ()

@end

@implementation PGTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
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
