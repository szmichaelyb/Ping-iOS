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

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

const CGFloat kDefaultGifDelay = 0.7;

@interface PGPingViewController ()

@property (strong, nonatomic) NSURL* imageURL;

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIButton* sendButton;
@property (nonatomic, strong) IBOutlet UIButton* retakeButton;
@property (nonatomic, strong) IBOutlet UITextField* captionTF;
@property (nonatomic, strong) IBOutlet UILabel* locationLabel;
@property (nonatomic, strong) IBOutlet UISlider* delaySlider;

@property (strong, nonatomic) CLLocationManager* locationManager;

-(IBAction)sendButtonClicked:(id)sender;
-(IBAction)retakeClicked:(id)sender;
-(IBAction)delaySliderChanged:(UISlider*)sender;

@end

@implementation PGPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    UIImage* gifImage = [UIImage animatedImageWithAnimatedGIFURL:fileURL];
    _imageURL = [self saveGifWithImages:_images gifDelay:kDefaultGifDelay];
    
    _delaySlider.value = kDefaultGifDelay;
    
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
    
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

-(IBAction)delaySliderChanged:(UISlider*)sender
{
    _imageURL = [self saveGifWithImages:_images gifDelay:sender.value];
    _imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
}

-(IBAction)sendButtonClicked:(id)sender
{
    if (_captionTF.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Caption" message:@"Write something funny." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [sender springAnimate];
        
        PFObject* object = [PFObject objectWithClassName:kPFTableName_Selfies];
        object[kPFSelfie_Owner] = [PFUser currentUser];
        
        //TODO: Change it to
        NSData* imgData = [NSData dataWithContentsOfURL:_imageURL];
        //        NSData* imgData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        PFFile* imageFile = [PFFile fileWithName:@"selfie.gif" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            object[kPFSelfie_Selfie] = imageFile;
            object[kPFSelfie_Caption] = _captionTF.text;
            object[kPFSelfie_Location] = _locationLabel.text;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self findRecieverBlock:^(PFObject *recieverObj) {
                    
                    if (recieverObj) {
                        [self findOldestUnusedSelfieObjectExcludingReciever:recieverObj completionBlock:^(PFObject *selfieObj) {
                            
                            if (selfieObj) {
                                
                                selfieObj[kPFSelfie_Receiver] = recieverObj[kPFQueue_Owner];
                                [selfieObj saveEventually];
                                
                                [self sendPushToObject:recieverObj fromUser:selfieObj[kPFSelfie_Owner]];
                            }
                        }];
                    }
                    
                    PFObject* queueObject = [PFObject objectWithClassName:kPFTableQueue];
                    queueObject[kPFQueue_Owner] = [PFUser currentUser];
                    [queueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                    }];
                }];
            }];
        }];
        [_delegate didDismissCamViewController:nil];
        [self dismissModalViewController];
    }
}

-(IBAction)retakeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)findOldestUnusedSelfieObjectExcludingReciever:(PFObject*)recieverObj completionBlock:(void (^) (PFObject* selfieObj))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
    [query whereKeyDoesNotExist:kPFSelfie_Receiver];
    [query whereKey:kPFSelfie_Owner notEqualTo:recieverObj[kPFQueue_Owner]];
    query.limit = 1;
    [query includeKey:kPFSelfie_Owner];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count) {
            block(objects[0]);
        } else {
            block(nil);
        }
    }];
}

-(void)findRecieverBlock:(void (^)(PFObject* recieverObj))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableQueue];
    query.limit = 1;
    [query orderByAscending:@"createdAt"];
    //    [query whereKey:kPFQueue_Owner notEqualTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        if (objects.count) {
            block(objects[0]);
        } else {
            block(nil);
        }
    }];
}

-(void)sendPushToObject:(PFObject*)object fromUser:(PFUser*)user
{
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:kPFInstallation_Owner equalTo:object[kPFQueue_Owner]];
    
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    //    [push setMessage:[NSString stringWithFormat:@"You have recieved a selfie from %@", [PFUser currentUser][kPFUser_Name]]];
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"You have recieved a selfie from %@", user[kPFUser_Name]], @"alert",
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

#pragma mark -

-(NSURL*)saveGifWithImages:(NSArray*)images gifDelay:(CGFloat)delay
{
    NSUInteger kFrameCount = images.count;
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    
    if (delay == 0)
        delay = 0.7f;
    
    NSDictionary* frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(delay), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage* image = images[i];
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    return fileURL;
    DLog(@"url=%@", fileURL);
}

@end
