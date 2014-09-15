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

/**
*  Parse Table Columns
*/

#define kPFObjectId @"objectId"

#define kPFInstallation_Owner @"owner"

#define kPFUser_Username @"username"
#define kPFUser_Name @"name"
#define kPFUser_Email @"email"
#define kPFUser_FBID @"fbID"
#define kPFUser_Picture @"picture"
#define kPFUser_Invited @"invited"
#define kPFUser_Location @"location"
#define kPFUser_FollowersCount @"followersCount"
//#define kPFUser_Follow @"follow"

#define kPFSelfie_Owner @"owner"
#define kPFSelfie_Receiver @"reciever"
#define kPFSelfie_Selfie @"selfie"
#define kPFSelfie_Caption @"caption"
#define kPFSelfie_Location @"location"
#define kPFSelfie_Abuse @"abuse"
#define kPFSelfie_Featured @"featured"
#define kPFSelfie_HashTags @"hashtags"

#define kPFActivity_Type @"type"
#define kPFActivity_FromUser @"fromUser"
#define kPFActivity_ToUser @"toUser"
#define kPFActivity_Content @"content"
#define kPFActivity_Selfie @"selfie"

#define kPFActivity_Type_Like @"like"
#define kPFActivity_Type_Follow @"follow"
#define kPFActivity_Type_Comment @"comment"
#define kPFActivity_Type_Joined @"joined"
#define kPGActivity_Type_Invited @"invited"

#define kPFCloudFunctionNameEditUser @"editUser"

#define kPFCloudEditUser_UserId @"userId"
#define kPFCloudEditUser_ColumnName @"colName"
#define kPFCloudEditUser_ColumnText @"colText"

/**
*
*/

//Setting UserDefaults
#define kUDFirstPostSent @"firstPostSent"
#define kUDIntructionShown @"instructionShown"

//Parse Table Names
#define kPFTableNameSelfies @"Selfies"
#define kPFTableUser @"User"
#define kPFTableActivity @"Activity"

//Fonts
#define FONT_OPENSANS_CONDLIGHT(s) [UIFont fontWithName:@"OpenSans-CondensedLight" size:s]
#define FONT_OPENSANS_CONDBOLD(s) [UIFont fontWithName:@"OpenSans-CondensedBold" size:s]
#define FONT_GEOSANSLIGHT(s) [UIFont fontWithName:@"GeosansLight" size:s]

#define FONT_SIZE_XS 15
#define FONT_SIZE_SMALL 18
#define FONT_SIZE_MEDIUM 20
#define FONT_SIZE_LARGE 22

#define kDefaultGifDelay 0.5

#define kAFAviaryAPIKey @"a2095a01a8bde2f7"
#define kAFAviarySecret @"a50ce6288a3d78f1"

#endif
