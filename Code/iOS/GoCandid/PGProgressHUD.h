//
//  PGProgressHUD.h
//  Ping
//
//  Created by Rishabh Tayal on 7/16/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "MBProgressHUD.h"

typedef enum {
    PGProgressHUDTypeDefault,
    PGProgressHUDTypeCheck,
    PGProgressHUDTypeError
}PGProgressHUDType;

@interface PGProgressHUD : MBProgressHUD<MBProgressHUDDelegate>

+ (instancetype)sharedInstance;
-(void)showInView:(UIView *)view withText:(NSString *)text progressType:(PGProgressHUDType)progressType;
//-(void)showInView:(UIView*)view withText:(NSString*)text hideAfter:(CGFloat)delay;
-(void)showInView:(UIView *)view withText:(NSString *)text hideAfter:(CGFloat)delay progressType:(PGProgressHUDType)progressType;

@end
