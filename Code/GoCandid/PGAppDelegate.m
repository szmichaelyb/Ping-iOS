//
//  PGAppDelegate.m
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGAppDelegate.h"
#import "PGTabViewController.h"
#import "InAppNotificationTapListener.h"
#import "InAppNotificationView.h"
#import "PGFeedViewController.h"
#import "PGFeedTableView.h"
#import <iRate/iRate.h>
#include <unistd.h>
#include<netdb.h>
#import <AviarySDK/AviarySDK.h>
#import "GAI.h"
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
    if (DEBUGMODE) {
        [Parse setApplicationId:@"RjjejatHY8BsqER68vg48jtr9nRv0FVAfKqryjja" clientKey:@"hTwjS9Ng9azIQoOfpQ6xeYX3Ah8mesiCWGt0gz3b"];
    } else {
        [Parse setApplicationId:@"oLAYrU2fvZm5MTwA8z7kdtyVsJC4rSY4NiAh6yAp" clientKey:@"GMc6VRe3Op6SllEFXwm0hrDear99ptg7WuFZfiC7"];
    }
    
    [PFFacebookUtils initializeFacebook];
 
    [Crashlytics startWithAPIKey:@"02d3f7db22ac1a3e538528547a694d5230eb8278"];
    
    //Exceptions handled by crashlytics
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    [GAI sharedInstance].dispatchInterval = 20;
    
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-40631521-10"];
    
    [AFPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    [[AFPhotoEditorController inAppPurchaseManager] startObservingTransactions];
    if (DEBUGMODE) {
        [AFPhotoEditorCustomization usePCNStagingEnvironment:YES];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,FONT_OPENSANS_CONDBOLD(FONT_SIZE_LARGE), NSFontAttributeName, nil]];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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
    [currentInstallation setObject:[PFUser currentUser] forKey:kPFInstallation_Owner];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        if (error) {
            //            DLog(@"Push Registration Error: %@", error);
            [GAI trackEventWithCategory:@"pf_installation" action:@"registration_error" label:error.localizedDescription value:nil];
        }
    }];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [PFPush handlePush:userInfo];
        [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
    } else {
        [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];

        DLog(@"%@", userInfo);
        
        [[InAppNotificationView sharedInstance] notifyWithUserInfo:userInfo andTouchBlock:^(InAppNotificationView *view) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
        }];
    }
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    DLog(@"Identifier: %@", identifier);
    
//TODO: Implement Notification Action Handler
    
    [GAI trackEventWithCategory:@"notification" action:@"action" label:identifier value:nil];
    
    completionHandler();
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DLog(@"URL: %@", [url scheme]);
    if ([[url scheme] rangeOfString:@"fb"].location != NSNotFound) {
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
        
        return wasHandled;
    } else {
        //Opened app context from web browser
        url = [NSURL URLWithString:[[url absoluteString] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
        DLog(@"%@", [url path]);
        if ([[url path] rangeOfString:@"/posts"].location != NSNotFound) {
            //Post
            DLog(@"Post");
            PGTabViewController* tab = (PGTabViewController*)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
            [tab setSelectedIndex:0];
            UINavigationController* feedNavC = tab.viewControllers[0];

            UIViewController* controller = [[UIViewController alloc] init];
            
            PGFeedTableView* table = [[PGFeedTableView alloc] initWithFrame:controller.view.bounds];
            
            PFQuery* query = [PFQuery queryWithClassName:kPFTableNameSelfies];
            [query whereKey:kPFObjectId equalTo:url.pathComponents[2]];
            [query includeKey:kPFSelfie_Owner];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                table.datasource = [[NSMutableArray alloc] initWithObjects:object, nil];
                [controller.view addSubview:table];
                [feedNavC pushViewController:controller animated:YES];
            }];
        }
    }
    return true;
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
    
    // Register App Install on Facebook Ads Manager
    [FBAppEvents activateApp];
    
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

+(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}

@end
