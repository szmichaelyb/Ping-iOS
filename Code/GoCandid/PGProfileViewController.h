//
//  PGProfileViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGProfileViewController : UIViewController< UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) PFUser* profileUser;

@end
