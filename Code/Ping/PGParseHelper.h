//
//  PGParseHelper.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGParseHelper : NSObject

+(void)followUser:(PFUser*)followUser;
+(void)getLikeActivityForSelfies:(NSArray*)selfies fromUser:(PFUser*)user completion:(void (^) (BOOL finished, NSArray* objects))block;
+(void)likeSelfie:(PFObject*)selfie fromUser:(PFUser*)user completion:(void (^) (BOOL finished))block;

@end
