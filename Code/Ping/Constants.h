//
//  Constants.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#ifndef Ping_Constants_h
#define Ping_Constants_h

#ifdef DEBUG
#define DEBUGMODE YES
#else
#define DEBUGMODE NO
#endif

#ifndef DLog
#ifdef DEBUG
#define DLog(_format_, ...) NSLog(_format_, ## __VA_ARGS__)
#else
#define DLog(_format_, ...)
#endif
#endif

//PFUser currentUser Keys
#define kPFUser_Name @"name"
#define kPFUser_Email @"email"
#define kPFUser_FBID @"fbID"
#define kPFUser_Picture @"picture"
#define kPFUser_Invited @"invited"
#define kPFUser_Location @"location"

//Setting UserDefaults
#define kUDInAppVibrate @"inAppVibrate"
#define kUDInAppSound @"inAppSound"

//Parse Table Names
#define kPFTableName_Selfies @"Selfies"
#define kPFTableUser @"User"
#define kPFTableQueue @"Queue"

#endif
