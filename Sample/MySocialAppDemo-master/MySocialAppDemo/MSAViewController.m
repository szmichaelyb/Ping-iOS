//
//  MSAViewController.m
//  MySocialAppDemo
//
//  Created by Anthony Blatner on 5/6/14.
//  Copyright (c) 2014 Jackrabbit Mobile. All rights reserved.
//

#import "MSAViewController.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "MSACompleteProfileVC.h"

@interface MSAViewController () <UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@end

@implementation MSAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Register this View Controller to listen for complete profile notifications, when detected, invoke the complete profile method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeProfile:) name:@"completeProfileNotification" object:nil];
}

// Get and instantiate the Complete Profile View Controller from our Main Storyboard, and present it to the UI
- (void)completeProfile:(id)userInfo{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // The identifier is set in the "Storyboard ID" of the Main Storyboard
    MSACompleteProfileVC *completeProfileVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MSACompleteProfileVC"];
    
    [self presentViewController:completeProfileVC animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Invoked by the Share button from the UI
- (IBAction)shareClicked:(id)sender {
    
    // Display share options for SMS, Email, Facebook SDK, and Facebook iOS
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"SMS",@"Email",@"Facebook SDK",@"Facebook iOS", nil];
    
    [shareActionSheet showInView:self.view];
    
}

// Callback method invoked when the user selects a share option
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Get the name of the option selected (this is for simplicity & readability, best practices would be to use enums here instead)
    NSString *selectedString = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    // Determine which option was selected
    if ([selectedString isEqualToString:@"SMS"]) {
        
#warning the SMS composer will only work on a physical iOS device (the simulator will crash)
        // SMS
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = @"Download our app at http://www.jackrabbitmobile.com";
        
        [self presentViewController:messageComposer animated:YES completion:nil];
        
        
    }else if([selectedString isEqualToString:@"Email"]){
        
        // Email
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:@"Download our app!"];
        [mailComposer setMessageBody:@"Download our app at http://www.jackrabbitmobile.com" isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
        
    }else if([selectedString isEqualToString:@"Facebook SDK"]){
        
#warning The Facebook SDK is configured for my test app "MySocialApp", to use this for your own, create a new app ON Facebook and update the properties found in MySocialAppDemo-Info.plist for "FacebookAppID", "FacebookDisplayName", and "URL Schemes"
        // Facebook SDK
        [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:@"http://www.jackrabbitmobile.com"]
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        }];
        
    }else if([selectedString isEqualToString:@"Facebook iOS"]){
        
        // Facebook iOS
        SLComposeViewController *iOSFacebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [iOSFacebookComposer addURL:[NSURL URLWithString:@"http://www.jackrabbitmobile.com"]];
        
        [self presentViewController:iOSFacebookComposer animated:YES completion:nil];
    }
}

// Callback method invoked when done displaying the native email composer
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Callback method invoked when done displaying the native SMS composer
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
