//
//  PGParseHelper.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGParseHelper.h"

@implementation PGParseHelper

+(void)followUser:(PFUser *)followUser
{
    if ([[followUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPFTableActivity];
    [followActivity setObject:[PFUser currentUser] forKey:kPFActivity_FromUser];
    [followActivity setObject:followUser forKey:kPFActivity_ToUser];
    [followActivity setObject:kPFActivity_Type_Follow forKey:kPFActivity_Type];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (completionBlock) {
//            completionBlock(succeeded, error);
//        }
    }];
}

@end
