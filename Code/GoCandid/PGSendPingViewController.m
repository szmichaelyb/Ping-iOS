//
//  PGSendPingViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/22/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSendPingViewController.h"
#import "UIViewController+Transitions.h"

@interface PGSendPingViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* imageView;

@property (nonatomic, strong) IBOutlet UITextField* captionTF;
@property (nonatomic, strong) IBOutlet UILabel* locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;

@property (strong, nonatomic) CLLocationManager* locationManager;
- (IBAction)shareOnFacebookClicked:(UIButton*)sender;
- (IBAction)shareOnTwitterClicked:(UIButton*)sender;

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
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(UIGestureRecognizer*)reco
{
    [self.view endEditing:YES];
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
                
                [self postOnFacebookSuccesful:^(bool success) {
                    if (success) {
                        
                    } else {
                        [self facebookPermissionHandle:^(bool granted) {
                            if (granted) {
                                [self postOnFacebookSuccesful:nil];
                            }
                        }];
                    }
                }];
                
                [self postOnTwitter];
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

-(void)postOnFacebookSuccesful:(void (^) (bool success))block
{
    if (self.facebookButton.isSelected) {
        //Share
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
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

-(void)postOnTwitter
{
    if (self.twitterButton.isSelected) {
        //Share
    }
}

@end
