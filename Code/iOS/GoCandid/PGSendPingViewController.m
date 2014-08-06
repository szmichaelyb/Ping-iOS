//
//  PGSendPingViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/22/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSendPingViewController.h"
#import "UIViewController+Transitions.h"
#import <Twitter/Twitter.h>
#import <BFPaperButton/BFPaperButton.h>
#import "GCZoomOutTransitionController.h"
#import "PGPingViewController.h"

@interface PGSendPingViewController ()

@property (nonatomic, strong) IBOutlet BFPaperButton* postButton;

@property (nonatomic, strong) IBOutlet UITextField* captionTF;
@property (nonatomic, strong) IBOutlet UILabel* locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;

@property (strong, nonatomic) CLLocationManager* locationManager;

- (IBAction)shareOnFacebookClicked:(UIButton*)sender;
- (IBAction)shareOnTwitterClicked:(UIButton*)sender;
- (IBAction)backButtonClicked:(id)sender;

@end

@implementation PGSendPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
    
    UITapGestureRecognizer* dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:dismissGesture];
    
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_gifUrl];
    self.postButton.cornerRadius = self.postButton.frame.size.width/2;
    self.postButton.rippleFromTapLocation = NO;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLFirstViewController
    if (fromVC == self && [toVC isKindOfClass:[PGPingViewController class]]) {
        return [[GCZoomOutTransitionController alloc] init];
    }
    else {
        return nil;
    }
}

-(void)dismissKeyboard:(UIGestureRecognizer*)reco
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 25) ? NO : YES;
}

-(IBAction)sendButtonClicked:(id)sender
{
    if (_captionTF.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Caption" message:@"Write something funny." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        PFObject* object = [PFObject objectWithClassName:kPFTableName_Selfies];
        object[kPFSelfie_Owner] = [PFUser currentUser];
        
        //TODO: Change it to
        NSData* imgData = [NSData dataWithContentsOfURL:_gifUrl];
        //        NSData* imgData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        PFFile* imageFile = [PFFile fileWithName:@"selfie.gif" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            object[kPFSelfie_Selfie] = imageFile;
            object[kPFSelfie_Caption] = _captionTF.text;
            object[kPFSelfie_Location] = _locationLabel.text;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self postOnFacebookObject:object succesful:^(bool success) {
                    if (success) {
                        
                    } else {
                        [self facebookPermissionHandle:^(bool granted) {
                            if (granted) {
                                [self postOnFacebookObject:object succesful:nil];
                            }
                        }];
                    }
                }];
                
                [self postOnTwitterObject:object];
            }];
        }];
        [_delegate didDismissCamViewController:nil];
        [self dismissModalViewController];
    }
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    DLog(@"%@", locations);
    if (locations.count) {
        [self.locationManager stopUpdatingLocation];
        CLLocation* location = (CLLocation*)[locations lastObject];
        CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            NSString* city = ([placemarks count] > 0 ? [placemarks[0] locality] : @"N/A");
            NSString* country = ([placemarks count] > 0 ? [placemarks[0] ISOcountryCode] : @"N/A");
            DLog(@"City: %@", city);
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
        }];
    }
}

- (IBAction)shareOnFacebookClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)shareOnTwitterClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Post on Facebook

-(void)facebookPermissionHandle:(void (^) (bool granted))completion
{
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        id permissions = [(NSArray*)[result data] objectAtIndex:0];
        DLog(@"%@",permissions);
        if (![permissions objectForKey:@"publish_actions"]) {
            //request permission
            [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                if ([[FBSession activeSession].permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                    [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Permission not granted. Will not upload to Facebook" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
                    completion(NO);
                } else {
                    completion(YES);
                }
            }];
        } else {
            completion(YES);
        }
    }];
}

-(void)postOnFacebookObject:(PFObject*)object succesful:(void (^) (bool success))block
{
    if (self.facebookButton.isSelected) {
        //Share
        PFFile* file = object[kPFSelfie_Selfie];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:object[kPFSelfie_Caption], @"caption",
                                       file.url, @"picture",
                                       nil];
        
        [FBRequestConnection startWithGraphPath:@"/me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            DLog(@"%@", result);
            if (!error) {
                if (block)
                    block(YES);
            } else {
                if (block)
                    block(NO);
            }
        }];
    }
}

-(void)postOnTwitterObject:(PFObject*)object
{
    if (self.twitterButton.isSelected) {
        //Share
        PFFile* file = object[kPFSelfie_Selfie];
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];
                if (accountsArray.count > 0) {
                    ACAccount* twitterAccount = [accountsArray objectAtIndex:0];
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ #GoCandidApp http://itunes.apple.com/app/id898275446", _captionTF.text], @"status", @"true", @"wrap_links", nil];

                    SLRequest* postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"] parameters:dict];
                    NSData* tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:file.url]];
                    [postRequest addMultipartData:tempData withName:@"media[]" type:@"image/gif" filename:@"image.gif"];
                    [postRequest setAccount:twitterAccount];
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString* output = [NSString stringWithFormat:@"HTTP response status: %@", [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]];
                        DLog(@"Twitter post status: %@", output);
                    }];
                }
            }
        }];
    }
}

@end
