//
//  PGSendPingViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/22/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSendPingViewController.h"
#import "UIViewController+Transitions.h"
//#import <BFPaperButton/BFPaperButton.h>
#import "GCZoomOutTransitionController.h"
#import "PGPingViewController.h"
#import "GCSharePost.h"
#import "PGProgressHUD.h"

@interface PGSendPingViewController ()

@property (nonatomic, strong) IBOutlet UIButton* postButton;

@property (nonatomic, strong) IBOutlet UITextView* captionTV;
@property (nonatomic, strong) IBOutlet UILabel* locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;

@property (nonatomic, strong) IBOutlet UIToolbar* keyboardInputView;
@property (nonatomic, strong) IBOutlet UIButton* charRemainig;

@property (strong, nonatomic) CLLocationManager* locationManager;

- (IBAction)shareOnFacebookClicked:(UIButton*)sender;
- (IBAction)shareOnTwitterClicked:(UIButton*)sender;
- (IBAction)backButtonClicked:(id)sender;

-(IBAction)hashButtonClicked:(id)sender;

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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUDFirstPostSent] != YES) {
        self.captionTV.text = @"#firstGoCandid";
    }

    self.captionTV.inputAccessoryView = self.keyboardInputView;
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

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

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

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength <= 117) {
        [UIView setAnimationsEnabled:NO];
        [self.charRemainig setTitle:[NSString stringWithFormat:@"%d", 116 - self.captionTV.text.length] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        return YES;
    } else {
        return NO;
    }
}

-(IBAction)hashButtonClicked:(id)sender
{
    self.captionTV.text = [NSString stringWithFormat:@"%@#", self.captionTV.text];
}

-(IBAction)sendButtonClicked:(id)sender
{
    if (_captionTV.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Caption" message:@"Say something funny." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        PFObject* object = [PFObject objectWithClassName:kPFTableNameSelfies];
        object[kPFSelfie_Owner] = [PFUser currentUser];
        
        //TODO: Change it to
        NSData* imgData = [NSData dataWithContentsOfURL:_gifUrl];
        //        NSData* imgData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        PFFile* imageFile = [PFFile fileWithName:@"selfie.gif" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            object[kPFSelfie_Selfie] = imageFile;
            object[kPFSelfie_Caption] = _captionTV.text;
            object[kPFSelfie_Location] = _locationLabel.text;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"GoCandid" message:@"Error occurred while creating the post. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                }
                if (self.facebookButton.isSelected) {
                    //Share on Facebook
                    [GCSharePost postOnFacebookObject:object completion:^(bool success) {
                        if (success) {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Shared" hideAfter:1.0 progressType:PGProgressHUDTypeCheck];
                        } else {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Could not share" hideAfter:1.0 progressType:PGProgressHUDTypeError];
                        }
                    }];
                }
                
                                
                if (self.twitterButton.isSelected) {
                    [GCSharePost postOnTwitterObject:object completion:^(BOOL success) {
                        if (success) {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Shared" hideAfter:1.0 progressType:PGProgressHUDTypeCheck];
                        } else {
                            [[PGProgressHUD sharedInstance] showInView:self.view withText:@"Could not share" hideAfter:1.0 progressType:PGProgressHUDTypeError];
                        }
                    }];
                }
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUDFirstPostSent];
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
            NSString* state = ([placemarks count] > 0 ? [placemarks[0] administrativeArea] : @"N/A");
            DLog(@"City: %@", city);
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
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

@end
