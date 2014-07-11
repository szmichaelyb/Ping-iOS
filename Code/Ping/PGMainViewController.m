//
//  PGMainViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGMainViewController.h"
#import <XHTwitterPaggingViewer/XHTwitterPaggingViewer.h>
#import "PGFeedViewController.h"

@interface PGMainViewController ()

@end

@implementation PGMainViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
