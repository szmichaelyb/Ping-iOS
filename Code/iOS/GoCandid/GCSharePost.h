//
//  GCSharePost.h
//  GoCandid
//
//  Created by Rishabh Tayal on 8/27/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCSharePost : NSObject

+(void)postOnFacebookObject:(PFObject*)object completion:(void (^) (bool success))completion;
+(void)postOnTwitterObject:(PFObject*)object completion:(void (^) (BOOL success))completion;
+(void)shareViaWhatsApp:(PFObject*)object;

@end
