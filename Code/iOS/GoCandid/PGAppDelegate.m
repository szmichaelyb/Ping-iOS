//
//  PGAppDelegate.m
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGAppDelegate.h"
#import "InAppNotificationTapListener.h"
#import "InAppNotificationView.h"
#import "PGFeedViewController.h"
#import <iRate/iRate.h>
#import <Crashlytics/Crashlytics.h>

@implementation PGAppDelegate

+(void)initialize
{
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    [iRate sharedInstance].eventsUntilPrompt = 5;
    
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].remindPeriod = 0;
    [iRate sharedInstance].previewMode = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"RjjejatHY8BsqER68vg48jtr9nRv0FVAfKqryjja" clientKey:@"hTwjS9Ng9azIQoOfpQ6xeYX3Ah8mesiCWGt0gz3b"];
    
    [PFFacebookUtils initializeFacebook];
 
    [Crashlytics startWithAPIKey:@"02d3f7db22ac1a3e538528547a694d5230eb8278"];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,FONT_OPENSANS_CONDBOLD(22), NSFontAttributeName, nil]];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation* currentInstallation  = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setChannels:@[@"channel"]];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:kPFInstallation_Owner];
    }
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        if (error) {
            //            DLog(@"Push Registration Error: %@", error);
            //            [GAI trackEventWithCategory:@"pf_installation" action:@"registration_error" label:error.description value:nil];
        }
    }];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DLog(@"%@", self.window.rootViewController);
    UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
    NSString* badge = [NSString stringWithFormat:@"%@", [userInfo[@"aps"] objectForKey:@"badge"]];
    [tab.tabBar.items[0] setBadgeValue:badge];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [PFPush handlePush:userInfo];
        [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
    } else {
        [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];
//        UIViewController* currentVC = ((UINavigationController*)((UITabBarController*)self.window.rootViewController).selectedViewController).visibleViewController;
//        
//        if (![currentVC isKindOfClass:[PGFeedViewController class]]) {
//            
//            //                if (userInfo[kNotificationSender]) {
//            [[InAppNotificationView sharedInstance] notifyWithUserInfo:userInfo andTouchBlock:^(InAppNotificationView *view) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
//            }];
//            //                }
//        }
        
    }
    //    [self.window.rootViewController.tabBarController.tabBar.items[0] setBadgeValue:@"2"];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
        if ([UIApplication sharedApplication].applicationIconBadgeNumber == 0) {
            [tab.tabBar.items[0] setBadgeValue:nil];
        } else {
            [tab.tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%d", [UIApplication sharedApplication].applicationIconBadgeNumber]];
        }
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
