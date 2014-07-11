//
//  UIView+Animate.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

@interface UIView (Animate)

-(void)springAnimateCompletion:(void (^)(POPAnimation* anim, BOOL finished))block;

@end
