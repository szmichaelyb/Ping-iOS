//
//  PGViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGTutorialViewController.h"
#import "PGAppDelegate.h"
#import "PGTabViewController.h"
#import "PGProgressHUD.h"

@interface PGTutorialViewController ()

-(IBAction)loginWithFacebook:(id)sender;

@end

@implementation PGTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([PFUser currentUser] != NULL) {
        [self setMainView];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setMainView
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];

    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PGTabViewController* mainVC = [sb instantiateViewControllerWithIdentifier:@"PGTabViewController"];
    
    PGAppDelegate* appDelegate = (PGAppDelegate*) [UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = mainVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithFacebook:(id)sender
{
    NSArray* permissions = @[@"email", @"user_friends"];
    
    //    [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Logging in"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        //        [ActivityView hide];
        if (!user) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:@"To use you Facebook account with this app, open Settings > Facebook and make sure this app is turned on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            //            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
            //                DLog(@"%@", result);
            //            }];
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error) {
                    
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
                    
                    [self setMainView];
                    
                    //                    [[PFUser currentUser] setObject:result[@""] forKey:kPFUser_Username];
                    [[PFUser currentUser] setObject:result[@"name"] forKey:kPFUser_Name];
                    if ([[PFUser currentUser] objectForKey:kPFUser_FBID] == NULL) {
                        DLog(@"First Time");
                        [self notifyFriendsViaPushThatIJoined];
                        //                        [self notifyFriendsViaEmailThatIJoined];
                    }
                    [[PFUser currentUser] setObject:result[@"id"] forKey:kPFUser_FBID];
                    if (result[@"email"] != NULL) {
                        [[PFUser currentUser] setObject:result[@"email"] forKey:kPFUser_Email];
                    }
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            //                            [GAI trackEventWithCategory:@"pf_user" action:@"save_in_background" label:error.description value:result[@"id"]];
                        }
                    }];
                    
                    //If there is no picture for user, download it from Facebook
                    if (![PFUser currentUser][kPFUser_Picture]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", result[@"id"]]]];
                            
                            PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
                            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
                                [[PFUser currentUser] saveInBackground];
                            }];
                        });
                    }
                    
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPFInstallation_Owner];
                    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        DLog(@"%@", error);
                    }];
                }
            }];
        }
    }];
}

-(void)notifyFriendsViaPushThatIJoined
{
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/friends" parameters:@{@"fields":@"name,first_name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray* friendsUsingApp = [NSMutableArray arrayWithArray:result[@"data"]];
        
        NSArray* recipients = [friendsUsingApp valueForKey:@"id"];
        
        if (recipients.count != 0) {
            
            PFQuery* userQuery = [PFUser query];
            [userQuery whereKey:kPFUser_FBID containedIn:recipients];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFQuery* installationQuery = [PFInstallation query];
                [installationQuery whereKey:@"owner" containedIn:objects];
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:installationQuery];
                [push setMessage:[NSString stringWithFormat:@"Your friend %@ just joined GoCandid!", [PFUser currentUser][kPFUser_Name]]];
                [push sendPushInBackground];
                
            }];            
        }
    }];
}

@end
