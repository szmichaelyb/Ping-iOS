//
//  UIImage+MyUIImage.m
//  Ping
//
//  Created by Rishabh Tayal on 7/18/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "UIImage+MyUIImage.h"
//#import <GPUImage/GPUImage.h>
//#import <RDGPUImage/GPUImage.h>

@import Accelerate;
#import <float.h>

@implementation UIImage (MyUIImage)

-(UIImage *)imageWithOverlayColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = self.scale;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)applyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    UIImage* img = [self applyBlurWithRadius:40 tintColor:tintColor saturationDeltaFactor:0 maskImage:nil];
    return img;
}


- (UIImage *)applyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    int componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blur tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    /*void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
     vImage_Buffer outBuffer2;
     outBuffer2.data = pixelBuffer2;
     outBuffer2.width = CGImageGetWidth(img);
     outBuffer2.height = CGImageGetHeight(img);
     outBuffer2.rowBytes = CGImageGetBytesPerRow(img);*/
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(ctx);
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor);
        CGRect rect = { CGPointZero, self.size};
        CGContextFillRect(ctx, rect);
        CGContextRestoreGState(ctx);
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    //free(pixelBuffer2);
    
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    
    
    return returnImage;
}

//- (UIImage*) reOrientIfNeeded {
//    
//    UIImage* theImage = self;
//    if (theImage.imageOrientation != UIImageOrientationUp) {
//        
//        CGAffineTransform reOrient = CGAffineTransformIdentity;
//        switch (theImage.imageOrientation) {
//            case UIImageOrientationDown:
//            case UIImageOrientationDownMirrored:
//                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, theImage.size.height);
//                reOrient = CGAffineTransformRotate(reOrient, M_PI);
//                break;
//            case UIImageOrientationLeft:
//            case UIImageOrientationLeftMirrored:
//                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
//                reOrient = CGAffineTransformRotate(reOrient, M_PI_2);
//                break;
//            case UIImageOrientationRight:
//            case UIImageOrientationRightMirrored:
//                reOrient = CGAffineTransformTranslate(reOrient, 0, theImage.size.height);
//                reOrient = CGAffineTransformRotate(reOrient, -M_PI_2);
//                break;
//            case UIImageOrientationUp:
//            case UIImageOrientationUpMirrored:
//                break;
//        }
//        
//        switch (theImage.imageOrientation) {
//            case UIImageOrientationUpMirrored:
//            case UIImageOrientationDownMirrored:
//                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
//                reOrient = CGAffineTransformScale(reOrient, -1, 1);
//                break;
//            case UIImageOrientationLeftMirrored:
//            case UIImageOrientationRightMirrored:
//                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.height, 0);
//                reOrient = CGAffineTransformScale(reOrient, -1, 1);
//                break;
//            case UIImageOrientationUp:
//            case UIImageOrientationDown:
//            case UIImageOrientationLeft:
//            case UIImageOrientationRight:
//                break;
//        }
//        
//        CGContextRef myContext = CGBitmapContextCreate(NULL, theImage.size.width, theImage.size.height, CGImageGetBitsPerComponent(theImage.CGImage), 0, CGImageGetColorSpace(theImage.CGImage), CGImageGetBitmapInfo(theImage.CGImage));
//        
//        CGContextConcatCTM(myContext, reOrient);
//        
//        switch (theImage.imageOrientation) {
//            case UIImageOrientationLeft:
//            case UIImageOrientationLeftMirrored:
//            case UIImageOrientationRight:
//            case UIImageOrientationRightMirrored:
//                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.height,theImage.size.width), theImage.CGImage);
//                break;
//                
//            default:
//                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.width,theImage.size.height), theImage.CGImage);
//                break;
//        }
//        
//        CGImageRef CGImg = CGBitmapContextCreateImage(myContext);
//        theImage = [UIImage imageWithCGImage:CGImg];
//        
//        CGImageRelease(CGImg);
//        CGContextRelease(myContext);
//    }
//    
//    return theImage;
//}

@end
