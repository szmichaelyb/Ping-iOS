//
//  PGMainViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGTabViewController.h"
#import "PGFeedViewController.h"
#import "PGCamViewController.h"

@interface PGTabViewController ()<PGCamViewControllerDelegate>
{
    NSUInteger lastSelectedIndex;
}

@end

@implementation PGTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    
    //Remove 1px line from top
    self.tabBar.clipsToBounds = YES;
    
    //Remove Grey Tint
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_selection"]];
    
    //Image in center
    for (UITabBarItem* item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    
    //unselected Images
    [self.tabBar.items[0] setImage:[[UIImage imageNamed:@"tab1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[1] setImage:[[UIImage imageNamed:@"tab2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage* buttonImage = [UIImage imageNamed:@"tab3-1"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(showCreatePingViewController) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference / 2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    
//    [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"tab3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[3] setImage:[[UIImage imageNamed:@"tab4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[4] setImage:[[UIImage imageNamed:@"tab5"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    //Selected Images
    [self.tabBar.items[0] setSelectedImage:[[UIImage imageNamed:@"tab1_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[1] setSelectedImage:[[UIImage imageNamed:@"tab2_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    [self.tabBar.items[2] setSelectedImage:[[UIImage imageNamed:@"tab3_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[3] setSelectedImage:[[UIImage imageNamed:@"tab4_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[4] setSelectedImage:[[UIImage imageNamed:@"tab5_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//-(void)setSelectedIndex:(NSUInteger)selectedIndex
//{
//    [super setSelectedIndex:selectedIndex];
//    if (selectedIndex == 1) {
//        [self showCreatePingViewController];
//    }
//}

-(void)showCreatePingViewController
{
    PGCamViewController* pingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PGCamViewController"];
    pingVC.delegate = self;
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:pingVC];
    [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_black"] forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)didDismissCamViewController:(PGCamViewController *)controller
{
    self.selectedIndex = lastSelectedIndex;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    DLog(@"selecte");
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    DLog(@"selected");
    
    if ([[tabBar items] indexOfObject:item] == 0) {
        lastSelectedIndex = 0;
        item.badgeValue = nil;
        PFInstallation* installation = [PFInstallation currentInstallation];
        //        if (installation.badge != 0) {
        installation.badge = 0;
        [installation saveEventually];
        //        }
    }
    if ([[tabBar items] indexOfObject:item] == 1) {
        lastSelectedIndex = 1;
    }
    if ([[tabBar items] indexOfObject:item] == 2) {
        [self showCreatePingViewController];
    }
    if ([[tabBar items] indexOfObject:item] == 3) {
        lastSelectedIndex = 3;
    }
    if ([[tabBar items] indexOfObject:item] == 4) {
        lastSelectedIndex = 4;
    }
}

@end
