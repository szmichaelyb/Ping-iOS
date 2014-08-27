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
                
#warning resize gif to < 3MB. Twitter limit.
                
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

+(NSData*)resizeData:(NSData*)data
{
    //IMPORTANT!!! THIS CODE WAS CREATED WITH "ARC" IN MIND... DO NOT USE WITHOUT ARC UNLESS YOU ALTER THIS CODE TO MANAGE MEMORY
    
    
    float compressionVal = 1.0;
    float maxVal = 3.0;//MB
    
    UIImage *compressedImage = [UIImage imageWithData:data];
    
    int iterations = 0;
    int totalIterations = 0;
    
    float initialCompressionVal = 0.00000000f;
    
    while (((((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)) > maxVal) && (totalIterations < 1024)) {
        
        NSLog(@"Image is %f MB", (float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal)).length)/(1048576.000000f)));//converts bytes to MB
        
        compressionVal = (((compressionVal)+((compressionVal)*((float)(((float)maxVal)/((float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)))))))/(2));
        compressionVal *= 0.97;//subtracts 3% of it's current value just incase above algorithm limits at just above MaxVal and while loop becomes infinite.
        
        if (initialCompressionVal == 0.00000000f) {
            initialCompressionVal = compressionVal;
        }
        
        iterations ++;
        
        if ((iterations >= 3) || (compressionVal < 0.1)) {
            iterations = 0;
            NSLog(@"%f", compressionVal);
            
            compressionVal = 1.0f;
            
            
            compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(compressedImage, compressionVal)];
            
            
            
            float resizeAmount = 1.0f;
            resizeAmount = (resizeAmount+initialCompressionVal)/(2);//percentage
            resizeAmount *= 0.97;//3% boost just incase image compression algorithm reaches a limit.
            resizeAmount = 1/(resizeAmount);//value
            initialCompressionVal = 0.00000000f;
            
            
            UIView *imageHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,(int)floorf((float)(compressedImage.size.width/(resizeAmount))), (int)floorf((float)(compressedImage.size.height/(resizeAmount))))];//round down to ensure frame isnt larger than image itself
            
            UIImageView *theResizedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,(int)ceilf((float)(compressedImage.size.width/(resizeAmount))), (int)ceilf((float)(compressedImage.size.height/(resizeAmount))))];//round up to ensure image fits
            theResizedImage.image = compressedImage;
            
            
            [imageHolder addSubview:theResizedImage];
            
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageHolder.frame.size.width, imageHolder.frame.size.height), YES, 1.0f);
            CGContextRef resize_context = UIGraphicsGetCurrentContext();
            [imageHolder.layer renderInContext:resize_context];
            compressedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            //after 3 compressions, if we still haven't shrunk down to maxVal size, apply the maximum compression we can, then resize the image (90%?), then re-start the process, this time compressing the compressed version of the image we were checking.
            
            NSLog(@"resize");
        }
        
        totalIterations ++;
        
    }
    
    if (totalIterations >= 1024) {
        NSLog(@"Image was too big, gave up on trying to re-size");//too many iterations failsafe. Gave up on trying to resize.
        return nil;
    } else {
        
        NSData *imageData = UIImageJPEGRepresentation(compressedImage, compressionVal);
        NSLog(@"FINAL Image is %f MB ... iterations: %i", (float)(((float)imageData.length)/(1048576.000000f)), totalIterations);//converts bytes to MB
        return imageData;
//        theUploadedImage.image = [UIImage imageWithData:imageData];//save new image to UIImageView.
        
    }
}

@end
