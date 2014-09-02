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
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface PGSettingsViewController ()

@property (nonatomic, strong) IBOutlet UILabel* tellAFriendLbl;
@property (nonatomic, strong) IBOutlet UILabel* helpLbl;
@property (nonatomic, strong) IBOutlet UILabel* reportAbuseLbl;
@property (nonatomic, strong) IBOutlet UILabel* getFeaturedLbl;

@property (nonatomic, strong) IBOutlet UILabel* sendFeedbackLbl;
@property (nonatomic, strong) IBOutlet UILabel* termsLbl;
@property (nonatomic, strong) IBOutlet UILabel* logoutLbl;

@property (strong) IBOutlet UIButton* facebookButton;
@property (strong) IBOutlet UIButton* twitterButton;
@property (strong) IBOutlet UIButton* appstoreButton;

@property (strong) IBOutlet UILabel* madeWithLbl;

@property (nonatomic, strong) MFMailComposeViewController* getFeaturedMailVC;

-(IBAction)likeOnFacebook:(id)sender;
-(IBAction)followOnTwitter:(id)sender;
-(IBAction)reviewOnAppStore:(id)sender;

@end

@implementation PGSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = NSLocalizedString(@"Settings", nil);
    
    _tellAFriendLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    _helpLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    _reportAbuseLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    _getFeaturedLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    
    _sendFeedbackLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    _termsLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
    _logoutLbl.font = FONT_GEOSANSLIGHT(FONT_SIZE_SMALL);
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
        return 120;
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
            _madeWithLbl.text = [NSString stringWithFormat:@"Made with love by Appikon Mobile: V %@ (%@) DB",majorVersion, minorVersion];
        } else {
            _madeWithLbl.text = [NSString stringWithFormat:@"Made with love by Appikon Mobile: V %@ (%@)", majorVersion, minorVersion];
        }
        
        _madeWithLbl.font = FONT_OPENSANS_CONDLIGHT(FONT_SIZE_SMALL);
        
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
            //Help
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
        } else if (indexPath.row == 3) {
            //Get featured
            [UIAlertView showWithTitle:@"Featured" message:@"We pick the best posts to show up as featured. If you like to get your post featured for a nominal charge, contact us." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Contact"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                DLog(@"%d", buttonIndex);
                if (buttonIndex == 0) {

                } else if (buttonIndex == 1) {
                    _getFeaturedMailVC = [[MFMailComposeViewController alloc]init];
                    _getFeaturedMailVC.mailComposeDelegate = self;
                    [_getFeaturedMailVC setSubject:@"Getting Featured Request from GoCandid"];
                    [_getFeaturedMailVC setToRecipients:@[@"getfeatured@appikon.com"]];
                    [self presentViewController:_getFeaturedMailVC animated:YES completion:nil];
                }
            }];
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
                messageVC.body = @"Download GoCandid app on App Store and take beautiful animated photos. https://itunes.apple.com/app/id898275446";
                [self presentViewController:messageVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 1) {
            //Message
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
                //                mailVC.view.tintColor = [UIColor whiteColor];
                [mailVC setSubject:@"GoCandid Chat App for iPhone"];
                [mailVC setMessageBody:@"Hey, \n\nI just downloaded GoCandid app on my iPhone. \n\nIt is a photo app which lets me create amazing stop motion animations and share it with others. The signup is very easy and simple. You don't have to remember anything. \n\nDownload it now on the App Store to start chatting. https://itunes.apple.com/app/id898275446" isHTML:NO];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 2) {
            //Facebook
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [sheet setInitialText:@"Download GoCandid app on App Store and take beautiful animated photos. https://itunes.apple.com/app/id898275446"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        } else if (buttonIndex == 3) {
            //Twitter
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [sheet setInitialText:@"Download GoCandid app on App Store and take beautiful animated photos. https://itunes.apple.com/app/id898275446"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        }
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
    if (controller == _getFeaturedMailVC) {
        if (result == MFMailComposeResultSent) {
            [UIAlertView showWithTitle:@"Sent" message:@"Thanks for contacting us regarding getting your post featured. We will contact you very soon." cancelButtonTitle:nil otherButtonTitles:@[@"Ok"] tapBlock:nil];
        }
    }
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
