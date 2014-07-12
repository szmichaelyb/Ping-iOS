//
//  PGPingViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGPingViewController.h"
#import "UIViewController+Transitions.h"
#import "UIView+Animate.h"

@interface PGPingViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIButton* sendButton;
@property (nonatomic, strong) IBOutlet UIButton* retakeButton;
@property (nonatomic, strong) IBOutlet UITextField* captionTF;
@property (nonatomic, strong) IBOutlet UILabel* locationLabel;

@property (strong, nonatomic) CLLocationManager* locationManager;

-(IBAction)sendButtonClicked:(id)sender;
-(IBAction)retakeClicked:(id)sender;

@end

@implementation PGPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
    
    UITapGestureRecognizer* dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:dismissGesture];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
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
    //    if (_captionTF.text.length == 0) {
    //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Enter a caption" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        [alert show];
    //    } else {
    [sender springAnimateCompletion:^(POPAnimation *anim, BOOL finished) {
        
        PFObject* object = [PFObject objectWithClassName:kPFTableName_Selfies];
        object[@"owner"] = [PFUser currentUser];
        
        //TODO: Change it to
        NSData* imgData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        PFFile* imageFile = [PFFile fileWithName:@"selfie.png" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            object[@"selfie"] = imageFile;
            object[@"caption"] = _captionTF.text;
            object[@"location"] = _locationLabel.text;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self findRecieverBlock:^(PFObject *recieverObj) {
                    
                    object[@"reciever"] = recieverObj[@"owner"];
                    [object saveEventually];
                    
                    [self sendPushToObject:recieverObj];
                    
                    PFObject* queueObject = [PFObject objectWithClassName:kPFTableQueue];
                    queueObject[@"owner"] = [PFUser currentUser];
                    [queueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                    }];
                    
                }];
            }];
        }];    [self dismissModalViewController];

    }];
}

-(IBAction)retakeClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)findRecieverBlock:(void (^)(PFObject* recieverObj))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableQueue];
    query.limit = 1;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"owner" notEqualTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        if (objects.count) {
            block(objects[0]);
        }
    }];
}

-(void)sendPushToObject:(PFObject*)object
{
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" equalTo:object[@"owner"]];
    
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
//    [push setMessage:[NSString stringWithFormat:@"You have recieved a selfie from %@", [PFUser currentUser][kPFUser_Name]]];
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"You have recieved a selfie from %@", [PFUser currentUser][kPFUser_Name]], @"alert",
                          @"Increment", @"badge"
                          , nil];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //Remove object from queue
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }];
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

@end
