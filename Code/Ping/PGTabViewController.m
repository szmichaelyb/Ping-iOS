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
    //    [self setSelectedIndex:1];
    //    [self tabBar:self.tabBar didSelectItem:self.tabBar.selectedItem];
    // Do any additional setup after loading the view.
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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:pingVC] animated:YES completion:nil];
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
        [self showCreatePingViewController];
    }
    if ([[tabBar items] indexOfObject:item] == 2) {
        lastSelectedIndex = 2;
    }
}

@end
