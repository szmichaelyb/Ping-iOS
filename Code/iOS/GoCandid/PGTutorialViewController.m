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

#define NUMBER_OF_PAGES 4

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

@interface PGTutorialViewController ()

//Page 1

@property (nonatomic, strong) IBOutlet UILabel* page1Label1;
@property (nonatomic, strong) IBOutlet UIImageView* page1IV1;

//Page 2
@property (nonatomic, strong) IBOutlet UIButton* facebookLoginButton;

-(IBAction)loginWithFacebook:(id)sender;

@end

@implementation PGTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slideShow.alpha = 0;
    
    self.slideShow.contentSize = CGSizeMake(640, self.slideShow.frame.size.height);
    
    [self setupSlideShowSubviewsAndAnimations];
    
    [self.slideShow setDidReachPageBlock:^(NSInteger reachedPage) {
        DLog(@"Current page: %d", reachedPage);
    }];
    
    self.facebookLoginButton.titleLabel.font = FONT_OPENSANS_CONDLIGHT(FONT_SIZE_MEDIUM);
    
    if ([PFUser currentUser] != NULL) {
        [self setMainView];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.slideShow.alpha = 1;
    }];
}

- (void)setupSlideShowSubviewsAndAnimations {
#pragma mark Page 0
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1Label1 page:0 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page1Label1.center.x + self.slideShow.frame.size.width, self.page1Label1.center.y - self.slideShow.frame.size.height)] delay:0]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1IV1 page:0 keyPath:@"alpha" toValue:@0 delay:0]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1IV1 page:0 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page1IV1.center.x+self.slideShow.frame.size.width, self.page1IV1.center.y+self.slideShow.frame.size.height*2)] delay:0]];
    
#pragma mark Page 1
    
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.magicStickImageView page:0 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.75]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.magicStickImageView page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.magicStickImageView.center.x + self.slideShow.frame.size.width, self.magicStickImageView.center.y - self.slideShow.frame.size.height)] delay:0]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.magicStickDescriptionTextView page:0 keyPath:@"transform" fromValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(-0.9)] toValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(0)] delay:0]];
    
#pragma mark Page 2
    
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.codeBracketsLabel page:1 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.75]];
    //
    //    [self.codingDescriptionTextView setCenter:CGPointMake(self.codingDescriptionTextView.center.x-self.slideShow.frame.size.width, self.codingDescriptionTextView.center.y+self.slideShow.frame.size.height)];
    //
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.codingDescriptionTextView page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.codingDescriptionTextView.center.x+self.slideShow.frame.size.width, self.codingDescriptionTextView.center.y-self.slideShow.frame.size.height)] delay:0]];
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
    
    [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Logging in"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [[PGProgressHUD sharedInstance] hide:YES];
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
