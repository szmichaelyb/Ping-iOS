//
//  GCGIFHelper.m
//  GoCandid
//
//  Created by Rishabh Tayal on 9/13/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCGIFHelper.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GCGIFHelper

#pragma mark -

+(CGFloat)loopDurationForDelay:(CGFloat)delay imagesCount:(NSInteger)imagesCount
{
    CGFloat duration = (float)delay * imagesCount;
    
    return duration;
}

+(NSURL*)saveGifWithImages:(NSArray*)images gifDelay:(CGFloat)delay
{
    NSUInteger kFrameCount = images.count;
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    
    if (delay == 0)
        delay = 0.7f;
    
    NSDictionary* frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(delay), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage* image = images[i];
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    return fileURL;
    DLog(@"url=%@", fileURL);
}

@end
