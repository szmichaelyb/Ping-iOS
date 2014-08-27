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
