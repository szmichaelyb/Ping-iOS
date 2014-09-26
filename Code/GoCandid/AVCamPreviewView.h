//
//  AVCamViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface AVCamPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
