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
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "WebViewController.h"

@interface PGTutorialViewController ()

//Page 1
@property (nonatomic, strong) IBOutlet UILabel* page1Label1;
@property (nonatomic, strong) IBOutlet UIImageView* page1IV1;

//Page 2
@property (nonatomic, strong) IBOutlet UILabel* page2Label1;
@property (nonatomic, strong) IBOutlet UIImageView* page2IV1;

//Page 3
@property (nonatomic, strong) IBOutlet UILabel* page3Label1;
@property (nonatomic, strong) IBOutlet UILabel* page3Label2;
@property (nonatomic, strong) IBOutlet UILabel* page3Label3;
@property (nonatomic, strong) IBOutlet UIImageView* page3IV1;

//Page 4
@property (nonatomic, strong) IBOutlet UIImageView* iv1;
@property (nonatomic, strong) IBOutlet UIImageView* iv2;
@property (nonatomic, strong) IBOutlet UIImageView* iv3;

//Page 5
@property (nonatomic, strong) IBOutlet UILabel* page5Label1;

//Last Page
@property (nonatomic, strong) IBOutlet UILabel* createPostLabel;
@property (nonatomic, strong) IBOutlet UIButton* facebookLoginButton;

-(IBAction)loginWithFacebook:(id)sender;

@end

@implementation PGTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slideShow.alpha = 0;
    
    self.slideShow.contentSize = CGSizeMake(1600, self.slideShow.frame.size.height);
    self.pageControl.numberOfPages = self.slideShow.contentSize.width / self.slideShow.frame.size.width;
    [self setupFonts];
    [self setupSlideShowSubviewsAndAnimations];
    
    [self.slideShow setDidReachPageBlock:^(NSInteger reachedPage) {
        //        DLog(@"Current page: %d", reachedPage);
        self.pageControl.currentPage = reachedPage;
        if (reachedPage == 3) {
            NSArray* array = @[self.iv1.image, self.iv2.image, self.iv3.image];
            self.iv3.animationImages = array;
            self.iv3.animationDuration = 1;
            [self.iv3 startAnimating];
        }
    }];
    
    [self.slideShow setDidScrollBlock:^(CGPoint point) {
        DLog(@"%@", NSStringFromCGPoint(point));
        if (point.x < 960) {
            [self.iv3 stopAnimating];
        }
    }];
    
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

-(void)setupFonts
{
    UIFont* font = FONT_GEOSANSLIGHT(FONT_SIZE_MEDIUM);
    self.page1Label1.font = font;
    self.page2Label1.font = font;
    self.page3Label1.font = font;
    self.page3Label2.font = font;
    self.page3Label3.font = font;
    self.page5Label1.font = font;
    self.createPostLabel.font = font;
    
    self.facebookLoginButton.titleLabel.font = font;
}

- (void)setupSlideShowSubviewsAndAnimations {
#pragma mark Page 0
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1Label1 page:0 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page1Label1.center.x + self.slideShow.frame.size.width, self.page1Label1.center.y - self.slideShow.frame.size.height)] delay:0]];
    
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1IV1 page:0 keyPath:@"alpha" toValue:@0 delay:0]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page1IV1 page:0 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page1IV1.center.x+self.slideShow.frame.size.width, self.page1IV1.center.y+self.slideShow.frame.size.height*2)] delay:0]];
    
#pragma mark Page 1
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page2IV1 page:0 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.75]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3IV1 page:0 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.75]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page2IV1 page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page2IV1.center.x + self.slideShow.frame.size.width, self.page2IV1.center.y)] delay:0]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page2Label1 page:1 keyPath:@"transform" fromValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(-0.9)] toValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(0)] delay:0]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page2Label1 page:2 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page2Label1.center.x + self.slideShow.frame.size.width, 300)] delay:0]];
    
#pragma mark Page 2
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3IV1 page:0 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.5]];
    //    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3IV1 page:0 keyPath:@"center" fromValue:[NSValue valueWithCGPoint:CGPointMake(self.page2IV1.center.x - self.slideShow.frame.size.width, self.page3IV1.center.y)] toValue:[NSValue valueWithCGPoint:CGPointMake(self.page2IV1.center.x, self.page3IV1.center.y)] delay:0]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label1 page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page3Label1.center.x + 500, self.page3Label1.center.y)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label1 page:1 keyPath:@"alpha" toValue:@0 delay:0.7]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label2 page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page3Label2.center.x + 500, self.page3Label2.center.y)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label2 page:1 keyPath:@"alpha" toValue:@0 delay:0.7]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label3 page:1 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.page3Label3.center.x + 500, self.page3Label3.center.y)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.page3Label3 page:1 keyPath:@"alpha" toValue:@0 delay:0.7]];
    
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv1 page:1 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.5]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv2 page:1 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.7]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv3 page:1 keyPath:@"alpha" fromValue:@0 toValue:@1 delay:0.9]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv1 page:2 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.iv1.center.x + 320 + self.iv1.frame.size.width + 3, 130)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv2 page:2 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.iv2.center.x + 320, 130)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv3 page:2 keyPath:@"center" toValue:[NSValue valueWithCGPoint:CGPointMake(self.iv3.center.x + 320 - self.iv3.frame.size.width - 3, 130)] delay:0]];
    
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv1 page:2 keyPath:@"size" toValue:[NSValue valueWithCGSize:CGSizeMake(150, 150)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv2 page:2 keyPath:@"size" toValue:[NSValue valueWithCGSize:CGSizeMake(150, 150)] delay:0]];
    [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:self.iv3 page:2 keyPath:@"size" toValue:[NSValue valueWithCGSize:CGSizeMake(150, 150)] delay:0]];
}

-(void)setMainView
{
    //Register for Push Notifications, if running iOS 8
#warning Test push notification for iOS 8 actions. Specially follow button.
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIMutableUserNotificationAction* followBackAction = [[UIMutableUserNotificationAction alloc] init];
        followBackAction.identifier = @"follow_back";
        followBackAction.title = @"Follow";
        
        followBackAction.activationMode = UIUserNotificationActivationModeBackground;
        
        followBackAction.destructive = NO;
        
        followBackAction.authenticationRequired = NO;
        
        UIMutableUserNotificationCategory* followCat = [[UIMutableUserNotificationCategory alloc] init];
        followCat.identifier = @"follow";
        [followCat setActions:@[followBackAction] forContext:UIUserNotificationActionContextDefault];
        
        NSSet* cate = [NSSet setWithObjects:followCat, nil];
        
        UIUserNotificationSettings* mySettings = [UIUserNotificationSettings settingsForTypes:types categories:cate];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {
        //Register for Push Notificatios before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
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
    [UIAlertView showWithTitle:@"GoCandid" message:@"We will never post anything on Facebook without your permission. By clicking 'I Agree', you agree to GoCandid's terms." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"I Agree", @"Read Terms"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            //Agree
            NSArray* permissions = @[@"email", @"user_friends"];
            
            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Logging in..." progressType:PGProgressHUDTypeDefault];
            [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
                [[PGProgressHUD sharedInstance] hide:YES];
                if (!user) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:@"To use you Facebook account with this app, open Settings > Facebook and make sure this app is turned on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    
                    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        
                        if (!error) {
                            
                            [self setMainView];
                            
                            if (user.isNew) {
                                DLog(@"New");
                                if (result[@"email"] != NULL) {
                                    [self sendWelcomeEmail:result[@"email"] name:result[@"name"]];
                                    [self subscribeToListEmail:result[@"email"]];
                                }
                                [self notifyFriendsViaPushThatIJoined];
                            }
                            
                            [[PFUser currentUser] setObject:result[@"name"] forKey:kPFUser_Name];
                            [[PFUser currentUser] setObject:result[@"id"] forKey:kPFUser_FBID];
                            if (result[@"email"] != NULL) {
                                [[PFUser currentUser] setObject:result[@"email"] forKey:kPFUser_Email];
                            }
                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    [GAI trackEventWithCategory:@"pf_user" action:@"save_in_background" label:error.localizedDescription value:result[@"id"]];
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
                        }
                    }];
                }
            }];
        } else if (buttonIndex == 2) {
            //Read Terms
            
            WebViewController* webViewContr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebViewController"];
            webViewContr.title = @"Terms of Use";
            webViewContr.url = [NSURL URLWithString:@"http://appikon.com/GoCandid/ToS.html"];
            webViewContr.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTermsView)];
            UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:webViewContr];
            [self presentViewController:navC animated:YES completion:nil];
        }
    }];
}

-(void)dismissTermsView
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
                
                NSString* pushMessage = [NSString stringWithFormat:@"Your friend %@ just joined GoCandid!", [PFUser currentUser][kPFUser_Name]];
                [PGParseHelper sendPushToUsers:objects pushText:pushMessage];
            }];
        }
    }];
}

-(void)sendWelcomeEmail:(NSString*)email name:(NSString*)name
{
    NSDictionary* params = @{@"name":name, @"toEmail":email};
    [PFCloud callFunctionInBackground:@"sendWelcomeEmail" withParameters:params block:^(id object, NSError *error) {
        DLog(@"Sent welcome Email");
        if (error) {
            [GAI trackEventWithCategory:@"welcomeEmail" action:@"error" label:error.localizedDescription value:nil];
        }
    }];
}

-(void)subscribeToListEmail:(NSString*)email
{
    DLog(@"subscribing");
    NSDictionary* params = @{@"email":email};
    [PFCloud callFunctionInBackground:@"subscribeToList" withParameters:params block:^(id object, NSError *error) {
        DLog(@"%@", object);
        if (error) {
            [GAI trackEventWithCategory:@"subscibeToList" action:@"errorOccured" label:error.localizedDescription value:nil];
        }
    }];
}

@end
