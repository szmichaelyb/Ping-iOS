//
//  NotificationTapListener.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "InAppNotificationTapListener.h"
//#import "FriendsListViewController.h"
//#import "FriendsChatViewController.h"
#import "PGAppDelegate.h"
//#import "MenuViewController.h"
//#import "UIImage+Utility.h"

@implementation InAppNotificationTapListener

+(id)sharedInAppNotificationTapListener
{
    static dispatch_once_t once;
    static InAppNotificationTapListener* sharedObserver = nil;
    
    dispatch_once(&once, ^{
        sharedObserver = [[self alloc] init];
    });
    return sharedObserver;
}

-(void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"notificationTapped" object:nil];
}

-(void)pushNotificationRecieved:(NSNotification*)notification
{
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    MFSideMenuContainerViewController* currentVC = ((MFSideMenuContainerViewController*)appDelegate.window.rootViewController);
//    UINavigationController* navC = (UINavigationController*)currentVC.leftMenuViewController;
//    MenuViewController* menuVC = (MenuViewController*)navC.topViewController;
//    [menuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
//    [menuVC tableView:menuVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    
//    FriendsListViewController* friendsList = (FriendsListViewController*)((UINavigationController*)currentVC.centerViewController).topViewController;
//    
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
//    
//    [UIImage imageForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200", notification.userInfo[kNotificationSender][@"id"]]] imageDownloadBlock:^(UIImage *image, NSError *error) {
//        chatVC.friendsImage = image;
//    }];
//
//    NSDictionary* notificationPayload = notification.userInfo[kNotificationPayload];
//    if ([notificationPayload[kNotificationPayloadIsGroupChat] boolValue] == TRUE) {
//        //Group Chat Notificationr
//        Group* group = [[Group MR_findByAttribute:@"groupId" withValue:notificationPayload[kNotificationPayloadGroupId]] firstObject];
//        chatVC.isGroupChat = YES;
//        chatVC.groupObj = group;
//        chatVC.title = group.name;
//    } else {
//        //Friend Chat Notification
//        Friend* friend = [[Friend MR_findByAttribute:@"fbId" withValue:notification.userInfo[kNotificationSender][@"id"]] firstObject];
//        chatVC.isGroupChat = NO;
//        chatVC.friendObj = friend;
//        chatVC.title = notification.userInfo[kNotificationSender][@"name"];
//    }
//
//    [friendsList.navigationController pushViewController:chatVC animated:YES];
}

@end
