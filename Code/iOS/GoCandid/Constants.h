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

/**
*
*/

//Setting UserDefaults

//Parse Table Names
#define kPFTableNameSelfies @"Selfies"
#define kPFTableUser @"User"
#define kPFTableActivity @"Activity"

#endif
