//
//  PGParseHelper.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGParseHelper.h"

@implementation PGParseHelper

+(void)followUserInBackground:(PFUser *)followUser completion:(void (^) (bool finished))block
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
        if (block) {
            block(succeeded);
        }
//        if (completionBlock) {
//            completionBlock(succeeded, error);
//        }
    }];
}

+(void)unfollowUserInBackground:(PFUser *)user completion:(void (^)(bool))block
{
    PFQuery *query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    [query whereKey:kPFActivity_ToUser equalTo:user];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (block) {
                        block(succeeded);
                    }
                }];
            }
        }
    }];
}

#pragma mark -

+(void)getLikeActivityForSelfies:(NSArray *)selfies fromUser:(PFUser *)user completion:(void (^)(BOOL, NSArray *))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Like];
    [query whereKey:kPFActivity_FromUser equalTo:user];
    [query whereKey:kPFActivity_Selfie containedIn:selfies];
    [query includeKey:kPFActivity_Selfie];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(YES, objects);
    }];
}

+(void)likeSelfie:(PFObject *)selfie fromUser:(PFUser *)user completion:(void (^)(BOOL))block
{
    PFObject* likeActivity = [PFObject objectWithClassName:kPFTableActivity];
    [likeActivity setObject:user forKey:kPFActivity_FromUser];
    [likeActivity setObject:selfie forKey:kPFActivity_Selfie];
    [likeActivity setObject:kPFActivity_Type_Like forKey:kPFActivity_Type];
    
    PFACL* likeACL = [PFACL ACLWithUser:user];
    [likeACL setPublicReadAccess:YES];
    likeActivity.ACL = likeACL;
    
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(succeeded);
    }];
}

+(void)unlikeSelfie:(PFObject *)selfie compltion:(void (^)(BOOL))block
{
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPFTableActivity];
    [queryExistingLikes whereKey:kPFActivity_Selfie equalTo:selfie];
    [queryExistingLikes whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Like];
    [queryExistingLikes whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (block) {
                block(YES);
            }
            
            // refresh cache
//            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                if (!error) {
//                    
//                    NSMutableArray *likers = [NSMutableArray array];
//                    NSMutableArray *commenters = [NSMutableArray array];
//                    
//                    BOOL isLikedByCurrentUser = NO;
//                    
//                    for (PFObject *activity in objects) {
//                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
//                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
//                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
//                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
//                        }
//                        
//                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
//                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
//                                isLikedByCurrentUser = YES;
//                            }
//                        }
//                    }
//                    
//                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
//                }
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
//            }];
//            
        } else {
            if (block) {
                block(NO);
            }
        }
    }];
}

@end
