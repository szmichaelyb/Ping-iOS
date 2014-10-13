//
//  PGProgressHUD.m
//  Ping
//
//  Created by Rishabh Tayal on 7/16/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGProgressHUD.h"

@interface PGProgressHUD()

@property (nonatomic, strong) MBProgressHUD* HUD;

@end

@implementation PGProgressHUD

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static PGProgressHUD *instance = nil;
    dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
    return instance;
}

-(void)showInView:(UIView *)view withText:(NSString *)text hideAfter:(CGFloat)delay progressType:(PGProgressHUDType)progressType
{
    _HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:_HUD];
    
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    if (progressType != PGProgressHUDTypeDefault) {
        if (progressType == PGProgressHUDTypeCheck)
            _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        else if (progressType == PGProgressHUDTypeError)
            _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
        
        // Set custom view mode
        _HUD.mode = MBProgressHUDModeCustomView;
    }
    
    _HUD.delegate = self;
    _HUD.labelText = text;
    
    [_HUD show:YES];
    if (delay != 0) {
        [_HUD hide:YES afterDelay:delay];
    }
}

-(void)showInView:(UIView *)view withText:(NSString *)text progressType:(PGProgressHUDType)progressType
{
    [self showInView:view withText:text hideAfter:0 progressType:progressType];
}

-(void)hide:(BOOL)animated
{
    [super hide:animated];
    [_HUD hide:animated];
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

@end
