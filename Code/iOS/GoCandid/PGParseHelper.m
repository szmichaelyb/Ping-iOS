//
//  PGParseHelper.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGParseHelper.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "PGAppDelegate.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@implementation PGParseHelper

+(void)followUserInBackground:(PFUser *)followUser completion:(void (^) (bool finished))block
{
    if ([[followUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }

    [PGParseHelper isUserFollowingUser:followUser completion:^(BOOL finished, BOOL following) {
        if (following) {
            return ;
        } else {
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
                [PGParseHelper sendPushToUsers:@[followUser] pushText:[NSString stringWithFormat:@"%@ is now following you.", [PFUser currentUser][kPFUser_Name]]];
            }];
        }
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

+(void)getFollowingListForUser:(PFUser*)user completion:(void (^) (BOOL, NSArray*))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_FromUser equalTo:user];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query includeKey:kPFActivity_ToUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (block) {
            block(YES, objects);
        }
    }];
}

+(NSArray*)getFollowingListForUser:(PFUser*)user
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_FromUser equalTo:user];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query includeKey:kPFActivity_ToUser];
    NSArray* result = nil;
    if ([PGAppDelegate isNetworkAvailable]) {
        result = [query findObjects];
    }
    return result;
}

+(void)isUserFollowingUser:(PFUser *)user completion:(void (^)(BOOL, BOOL))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    [query whereKey:kPFActivity_ToUser equalTo:user];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            block(YES, NO);
        } else {
            block(YES, YES);
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
        if (block) {
            block(YES, objects);
        }
    }];
}

+(void)likeSelfie:(PFObject *)selfie completion:(void (^)(BOOL))block
{
    PFObject* likeActivity = [PFObject objectWithClassName:kPFTableActivity];
    [likeActivity setObject:kPFActivity_Type_Like forKey:kPFActivity_Type];
    [likeActivity setObject:[PFUser currentUser] forKey:kPFActivity_FromUser];
    [likeActivity setObject:selfie[kPFSelfie_Owner] forKey:kPFActivity_ToUser];
    [likeActivity setObject:selfie forKey:kPFActivity_Selfie];
    
    PFACL* likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [likeACL setPublicReadAccess:YES];
    [likeACL setWriteAccess:YES forUser:selfie[kPFSelfie_Owner]];
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

+(void)getTotalLikeForSelfie:(PFObject*)selfie completion:(void (^)(BOOL, int))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Like];
    [query whereKey:kPFActivity_Selfie equalTo:selfie];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (block) {
            block(YES, number);
        }
    }];
}

#pragma mark -

+(void)profilePhotoUser:(PFUser *)user completion:(void (^)(UIImage *))block
{
    PFFile* thumbFile = user[kPFUser_Picture];
    if (thumbFile) {
        [thumbFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage* img = [UIImage imageWithData:data];
            block(img);
            //        [cell.thumbIV setImage:[UIImage imageWithData:data]];
        }];
    } else {
        block([UIImage imageNamed:@"NoProfilePhotoIMAGE"]);
    }
}

#pragma mark - PFPush Helpers

+(void)sendPushToUsers:(NSArray *)users pushText:(NSString *)text
{
    PFQuery* installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"owner" containedIn:users];

    PFPush *push = [[PFPush alloc] init];
    [push setQuery:installationQuery];
    [push setMessage:text];
    [push sendPushInBackground];
}

@end
