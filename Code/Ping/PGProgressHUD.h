//
//  PGProgressHUD.h
//  Ping
//
//  Created by Rishabh Tayal on 7/16/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "MBProgressHUD.h"

@interface PGProgressHUD : MBProgressHUD<MBProgressHUDDelegate>

+ (instancetype)sharedInstance;
-(void)showInView:(UIView*)view withText:(NSString*)text;

@end
