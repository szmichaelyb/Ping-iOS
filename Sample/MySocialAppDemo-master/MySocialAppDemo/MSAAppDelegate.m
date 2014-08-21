//
//  MSAAppDelegate.m
//  MySocialAppDemo
//
//  Created by Anthony Blatner on 5/6/14.
//  Copyright (c) 2014 Jackrabbit Mobile. All rights reserved.
//

#import "MSAAppDelegate.h"
#import <Parse/Parse.h>

@implementation MSAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#warning This links to my Parse app -- you'll need to replace these keys with your own to leverage Parse for push notifications
    [Parse setApplicationId:@"lAOi5LRdeYTPIxXF9N0AQqC4kEx5700XaNfkp0NK" clientKey:@"xr7olEFG1ljdwbMkYxyZad5DPAUUZBxm1UIA1GVD"];
    
#warning Push notifications will only work when run on a physical device (not the simulator)
    // Register for notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
#warning you'll also need to set the bundle identifier to your Push Certificate and Provisioning Profiles identifier
    
    return YES;
}

// Callback method invoked when notifications are registered for
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Save our device token to Parse -- this can later be used to segment users and devices for specific push notifications
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    
    // We're expecting the push notification's payload to contain an "action" property
    // Here's the payload used in the demo
    //    {
    //        "aps": {
    //            "alert": "Hey, don’t forget to complete your profile!",
    //            "badge": 9
    //        },
    //        "action": "completeProfile"
    //    }
    
    NSString *action = [userInfo valueForKey:@"action"];
    
    // If the push notifications action is completeProfile, use a local push notification
    // to alert anywhere in our app that may be interested in completeProfile (MSAViewController)
    if ([action isEqualToString:@"completeProfile"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfileNotification" object:nil userInfo:userInfo];
    }
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
