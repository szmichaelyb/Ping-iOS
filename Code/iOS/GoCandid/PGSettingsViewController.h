//
//  SettingsViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

typedef enum {
    ActionSheetTypeShare = 100,
    ActionSheetTypeLogout,
}ActionSheetType;

@interface PGSettingsViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//-(IBAction)logout:(id)sender;

@end
