//
//  SettingsViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "PGSettingsViewController.h"
#import "PGAppDelegate.h"
#import <Parse/Parse.h>
#import <IDMPhotoBrowser.h>
#import "WebViewController.h"
#import <iRate/iRate.h>
#import "UIDevice-Hardware.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@interface PGSettingsViewController ()

@property (strong) IBOutlet UIButton* facebookButton;
@property (strong) IBOutlet UIButton* twitterButton;
@property (strong) IBOutlet UIButton* appstoreButton;

@property (strong) IBOutlet UILabel* appVersionLabel;

-(IBAction)likeOnFacebook:(id)sender;
-(IBAction)followOnTwitter:(id)sender;
-(IBAction)reviewOnAppStore:(id)sender;

@end

@implementation PGSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
   
    //Add tap gesture to Parallax View
    //    UITapGestureRecognizer* tapGestuere = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parallaxHeaderTapped:)];
    //    [self.tableView.parallaxView addGestureRecognizer:tapGestuere];
    
    self.title = NSLocalizedString(@"Settings", nil);
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [GAI trackWithScreenName:kScreenNameSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)parallaxHeaderTapped:(UIGestureRecognizer*)reco
//{
//    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"View Profile Photo", nil), NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Exisiting Photo", nil), NSLocalizedString(@"Import from Facebook", nil), nil];
//    sheet.tag = ActionSheetTypeHeaderPhoto;
//    [sheet showInView:self.view.window];
//}

#pragma mark - Facebook, Twitter, App Store Review

-(IBAction)likeOnFacebook:(id)sender
{
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/735947206471497"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/gocandidapp"]];
    }
}

-(IBAction)followOnTwitter:(id)sender
{
    DLog(@"follow");
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"gocandidapp"]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            // Stop trying after the first URL that succeeds
            return;
        }
    }
}

-(IBAction)reviewOnAppStore:(id)sender
{
    DLog(@"review on app store");
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [tableView numberOfSections] - 1) {
        //Get the height from SettingsShareView.Xib
        return 140;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == [tableView numberOfSections] - 1) {
        UIView* view = [[[NSBundle mainBundle] loadNibNamed:@"SettingsShareView" owner:self options:nil] objectAtIndex:0];
        
        [_facebookButton.layer setCornerRadius:4];
        [_facebookButton.layer setMasksToBounds:YES];
        
        [_twitterButton.layer setCornerRadius:4];
        [_twitterButton.layer setMasksToBounds:YES];
        
        [_appstoreButton.layer setCornerRadius:4];
        [_appstoreButton.layer setMasksToBounds:YES];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        if (DEBUGMODE) {
            _appVersionLabel.text = [NSString stringWithFormat:@"Version %@ (%@) DB", majorVersion, minorVersion];
        } else {
            _appVersionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", majorVersion, minorVersion];
        }
        
        return view;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //Tell a friend
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Message", nil), NSLocalizedString(@"Mail", nil), NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Twitter", nil), nil];
            sheet.tag = ActionSheetTypeShare;
            [sheet showInView:self.view.window];
        } else if (indexPath.row == 1) {
            MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
            mailVC.mailComposeDelegate = self;
//            mailVC.view.tintColor = [UIColor whiteColor];
            [mailVC setSubject:@"GoCandid App Support"];
            [mailVC setToRecipients:@[@"helpme@appikon.com"]];
            
            NSString* info = [NSString stringWithFormat:@"Email: %@\n App Version: %@\nDevice: %@\n OS Version: %@", [PFUser currentUser][kPFUser_Email], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [UIDevice currentDevice].platformString, [UIDevice currentDevice].systemVersion];
            [mailVC setMessageBody:[NSString stringWithFormat:@"Please describe the issue you're having here.\n\n//Device Info\n%@", info] isHTML:NO];
            [self presentViewController:mailVC animated:YES completion:nil];
        } else if(indexPath.row == 2) {
            //Report an abuse
            MFMailComposeViewController* issueVC = [[MFMailComposeViewController alloc] init];
            issueVC.mailComposeDelegate = self;
//            issueVC.view.tintColor = [UIColor whiteColor];
            [issueVC setSubject:@"Reporting abuse content from GoCandid"];
            [issueVC setToRecipients:@[@"reportabuse@appikon.com"]];
            [self presentViewController:issueVC animated:YES completion:nil];
        }
    }
    if (indexPath.section == 1) {
        MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
//        mailVC.view.tintColor = [UIColor whiteColor];
        [mailVC setSubject:@"Feedback for GoCandid App."];
        [mailVC setToRecipients:@[@"feedback@appikon.com"]];
        [self presentViewController:mailVC animated:YES completion:nil];
    }
    if (indexPath.section == 3) {
        [UIActionSheet showInView:self.view.window withTitle:@"Logout" cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self performLogout];
            }
        }];
    }
}

#pragma mark - UIAction Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ActionSheetTypeShare) {
        if (buttonIndex == 0) {
            //Mail
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController* messageVC = [[MFMessageComposeViewController alloc] init];
                messageVC.messageComposeDelegate = self;
//                messageVC.view.tintColor = [UIColor whiteColor];
                messageVC.body = @"Download GoCandid app on AppStore and take beautiful animated photos. https://itunes.apple.com/app/id898275446";
                [self presentViewController:messageVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 1) {
            //Message
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
//                mailVC.view.tintColor = [UIColor whiteColor];
                [mailVC setSubject:@"GoCandid Chat App for iPhone"];
#warning change text
                [mailVC setMessageBody:@"Hey, \n\nI just downloaded vCinity Chat on my iPhone. \n\nIt is a chat app which lets me chat with people around me. Even if there is no Internet connection. The signup is very easy and simple. You don't have to remember anything. \n\nDownload it now on the AppStore to start chatting. https://itunes.apple.com/app/id898275446" isHTML:NO];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 2) {
            //Facebook
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [sheet setInitialText:@"Download GoCandid app on AppStore and take beautiful animated photos. https://itunes.apple.com/app/id898275446"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        } else if (buttonIndex == 3) {
            //Twitter
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [sheet setInitialText:@"Download GoCandid app on AppStore and take beautiful animated photos. https://itunes.apple.com/app/id898275446"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        }
    } else if (actionSheet.tag == ActionSheetTypeHeaderPhoto) {
        //        if (buttonIndex == 0) {
        //            //View
        //
        //            IDMPhoto* photo = [IDMPhoto photoWithImage:self.tableView.parallaxView.imageView.image];
        //            IDMPhotoBrowser* photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:self.tableView.parallaxView];
        //            photoBrowser.scaleImage = self.tableView.parallaxView.imageView.image;
        //            [self presentViewController:photoBrowser animated:YES completion:nil];
        //
        //        } else if (buttonIndex == 1) {
        //            //Take photo
        //            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        //            imagePicker.delegate = self;
        //            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        //            [self presentViewController:imagePicker animated:YES completion:nil];
        //
        //        } else if (buttonIndex == 2) {
        //            //Choose from library
        //            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        //            imagePicker.delegate = self;
        //            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        //            [self presentViewController:imagePicker animated:YES completion:nil];
        //        } else if (buttonIndex == 3) {
        //            //Import from Facebook
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //                NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", [PFUser currentUser][kPFUser_FBID]]]];
        //
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    self.tableView.parallaxView.imageView.image = [UIImage imageWithData:imgData];
        //                });
        //
        //                PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
        //                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //
        //                    [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
        //                    [[PFUser currentUser] saveInBackground];
        //                }];
        //            });
        //        }
    }
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        self.tableView.parallaxView.imageView.image = info[UIImagePickerControllerOriginalImage];
    //
    //        NSData* imgData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.7);
    //        PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
    //        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //
    //            [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
    //            [[PFUser currentUser] saveInBackground];
    //        }];
    //    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"termsSegue"]) {
        WebViewController* webViewContr = segue.destinationViewController;
        webViewContr.title = @"Terms of Use";
        webViewContr.url = [NSURL URLWithString:@"http://appikon.com/GoCandid/ToS.html"];
    }
}

-(void)performLogout
{
    [PFUser logOut];
    
    PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    appDelegate.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"PGTutorialViewController"];
}

@end
