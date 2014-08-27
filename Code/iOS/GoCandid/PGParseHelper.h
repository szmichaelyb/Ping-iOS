//
//  PGParseHelper.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGParseHelper : NSObject

+(void)followUserInBackground:(PFUser *)followUser completion:(void (^) (bool finished))block;
+(void)unfollowUserInBackground:(PFUser*)user completion:(void (^) (bool finished))block;
+(void)getFollowingListForUser:(PFUser*)user completion:(void (^) (BOOL finished, NSArray* followingUsers))block;
+(NSArray*)getFollowingListForUser:(PFUser*)user;
+(void)isUserFollowingUser:(PFUser*)user completion:(void (^) (BOOL finished, BOOL following))block;

+(void)getLikeActivityForSelfies:(NSArray*)selfies fromUser:(PFUser*)user completion:(void (^) (BOOL finished, NSArray* objects))block;
+(void)likeSelfie:(PFObject*)selfie completion:(void (^) (BOOL finished))block;
+(void)unlikeSelfie:(PFObject*)selfie compltion:(void (^) (BOOL finished))block;
+(void)getTotalLikeForSelfie:(PFObject*)selfie completion:(void (^)(BOOL finished, int number))block;

+(void)profilePhotoUser:(PFUser*)user completion:(void (^) (UIImage* image))block;

+(void)sendPushToUsers:(NSArray*)users pushText:(NSString*)text;

@end
