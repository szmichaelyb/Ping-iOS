//
//  GAI+MyGAITracker.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/23/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "GAI.h"

#define kGAICategoryButton @"ui_button"
#define kGAIActionMessageSent @"message_sent"

typedef enum
{
    kScreenNameFeedScreen,
    kScreenNameSearchScreen,
    kScreenNameCreatePostScreen,
    kScreenNameActivityScreen,
    kScreenNameProfileScreen,
    kScreenNameSettingsScreen,
    kScreenNameFindFriendsScreen,
} ScreenName;

#define ScreenNameString(enum) [@[@"Feed Screen",@"Search Screen",@"Create Post Screen", @"Activity Screen", @"Profile Screen", @"Settings Screen", @"Find Friends Screen"] objectAtIndex:enum]

@interface GAI (MyGAITracker)

+(void)trackWithScreenName:(ScreenName)screenName;
+(void)trackEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber*)value;

@end
