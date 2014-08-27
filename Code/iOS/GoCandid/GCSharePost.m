//
//  GCSharePost.m
//  GoCandid
//
//  Created by Rishabh Tayal on 8/27/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCSharePost.h"
#import <Twitter/Twitter.h>

@implementation GCSharePost

+(void)postOnFacebookObject:(PFObject*)object completion:(void (^) (bool success))completion
{
    [GCSharePost callGraphForPostWithObject:object completion:^(bool success) {
        if (success) {
            if (completion)
                completion(YES);
        } else {
            [GCSharePost facebookPermissionHandle:^(bool granted) {
                if (granted) {
                    [GCSharePost callGraphForPostWithObject:object completion:^(bool success) {
                        if (success) {
                            if (completion)
                                completion(YES);
                        } else {
                            if (completion)
                                completion(NO);
                        }
                    }];
                } else {
                    if (completion)
                        completion(NO);
                }
            }];
        }
    }];
}

#pragma mark - Facebook Helper

+(void)callGraphForPostWithObject:(PFObject*)object completion:(void (^) (bool success))block
{
    //Share
    PFFile* file = object[kPFSelfie_Selfie];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:object[kPFSelfie_Caption], @"name",
                                   file.url, @"link",
                                   nil];
    
    [FBRequestConnection startWithGraphPath:@"/me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@", result);
        if (!error) {
            if (block)
                block(YES);
        } else {
            if (block)
                block(NO);
        }
    }];
}

+(void)facebookPermissionHandle:(void (^) (bool granted))completion
{
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        id permissions = [(NSArray*)[result data] objectAtIndex:0];
        DLog(@"%@",permissions);
        if (![permissions objectForKey:@"publish_actions"]) {
            //request permission
            [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                if ([[FBSession activeSession].permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                    [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Permission not granted. Will not upload to Facebook" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
                    if (completion)
                        completion(NO);
                } else {
                    if (completion)
                        completion(YES);
                }
            }];
        } else {
            if (completion)
                completion(YES);
        }
    }];
}

#pragma mark - Post on Twitter

+(void)postOnTwitterObject:(PFObject*)object completion:(void (^) (BOOL success))completion
{
    PFFile* file = object[kPFSelfie_Selfie];
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];
            if (accountsArray.count > 0) {
                ACAccount* twitterAccount = [accountsArray objectAtIndex:0];
                
                NSString* status;
                NSString* caption = object[kPFSelfie_Caption];
                if (caption.length <= 104) {
                    status = [NSString stringWithFormat:@"%@ #GoCandidApp", caption];
                } else {
                    status = caption;
                }
                
                DLog(@"Status Length: %d", status.length);
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:status, @"status", @"true", @"wrap_links", nil];
                
                SLRequest* postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"] parameters:dict];
                NSData* tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]];
                [postRequest addMultipartData:tempData withName:@"media[]" type:@"image/gif" filename:@"image.gif"];
                [postRequest setAccount:twitterAccount];
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString* output = [NSString stringWithFormat:@"HTTP response status: %@", [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (completion) {
                            if (error || urlResponse.statusCode != 200) {
                                completion(NO);
                            } else {
                                completion(YES);
                            }
                        }
                    });
                    DLog(@"Twitter post status: %@", output);
                }];
            }
        }
    }];
}

@end
