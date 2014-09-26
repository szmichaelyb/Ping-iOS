//
//  GCGIFHelper.h
//  GoCandid
//
//  Created by Rishabh Tayal on 9/13/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCGIFHelper : NSObject

+(CGFloat)loopDurationForDelay:(CGFloat)delay imagesCount:(NSInteger)imagesCount;
+(NSURL*)saveGifWithImages:(NSArray*)images gifDelay:(CGFloat)delay;

@end
