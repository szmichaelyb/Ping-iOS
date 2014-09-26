//
//  GCCaptureProgressView.m
//  GoCandid
//
//  Created by Rishabh Tayal on 9/18/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCCaptureProgressView.h"

@interface GCCaptureProgressView()

//@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) UIView* progressView;

@property (nonatomic, assign) int times;
@property (nonatomic, assign) int runtimes;

@end

@implementation GCCaptureProgressView

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static GCCaptureProgressView *instance = nil;
    dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 15);
        self.backgroundColor = [UIColor clearColor];

        self.progressView = [[UIView alloc] initWithFrame:self.frame];
        self.progressView.backgroundColor = [UIColor orangeColor];
        
        [self addSubview:self.progressView];
    }
    return self;
}

-(void)startAnimatingInView:(UIView *)view withDuration:(float)duration times:(int)times
{
#warning FIX VIEW ANIMATION TIMiNG
    [view addSubview:self];
    DLog(@"Duration: %f", duration);
    _times = times;
    _runtimes = 0;
    [self performSelector:@selector(startTimerForDuration:) withObject:[NSNumber numberWithFloat:duration]];
//    [self performSelector:@selector(startTimerForDuration:) withObject:[NSNumber numberWithFloat:duration] afterDelay:delay];
}

-(void)startTimerForDuration:(NSNumber*)duration
{
    _runtimes ++;
    CGRect frame = self.progressView.frame;
    frame.origin.x = -320;
    self.progressView.frame = frame;
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        CGRect frame = self.progressView.frame;
        frame.origin.x = 0;
        self.progressView.frame = frame;
    } completion:^(BOOL finished) {
        if (_times != _runtimes) {
            [self startTimerForDuration:duration];
        }
    }];
}

@end
