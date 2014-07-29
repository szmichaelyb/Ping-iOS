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
#import "PGSendPingViewController.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

const CGFloat kDefaultGifDelay = 0.5;

@interface PGPingViewController ()

@property (strong, nonatomic) NSURL* imageURL;

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIButton* sendButton;
@property (nonatomic, strong) IBOutlet UIButton* retakeButton;
@property (nonatomic, strong) IBOutlet UISlider* delaySlider;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

-(IBAction)retakeClicked:(id)sender;
-(IBAction)delaySliderChanged:(UISlider*)sender;
-(IBAction)backbuttonClicked:(id)sender;
- (IBAction)sliderDidFinishChanging:(id)sender;

@end

@implementation PGPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageURL = [self saveGifWithImages:_images gifDelay:kDefaultGifDelay];
    
    _delaySlider.value = kDefaultGifDelay;
    
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
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

-(IBAction)delaySliderChanged:(UISlider*)sender
{
    DLog(@"Slider Value: %f", sender.value);
    CGFloat duration = [self loopDurationForDelay:sender.value imagesCount:_images.count];
    _durationLabel.text = [NSString stringWithFormat:@"%.1f sec", duration];
}

- (IBAction)sliderDidFinishChanging:(UISlider*)sender
{
    _imageURL = [self saveGifWithImages:_images gifDelay:sender.value];
    _imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
}

- (IBAction)backbuttonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)retakeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PGSendPingSegue"]) {
        PGSendPingViewController* sendPingVC = segue.destinationViewController;
        sendPingVC.delegate = _delegate;
        sendPingVC.gifUrl = _imageURL;
    }
}

//-(void)findOldestUnusedSelfieObjectExcludingReciever:(PFObject*)recieverObj completionBlock:(void (^) (PFObject* selfieObj))block
//{
//    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
//    [query whereKeyDoesNotExist:kPFSelfie_Receiver];
//    [query whereKey:kPFSelfie_Owner notEqualTo:recieverObj[kPFQueue_Owner]];
//    query.limit = 1;
//    [query includeKey:kPFSelfie_Owner];
//    [query orderByAscending:@"createdAt"];
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (objects.count) {
//            block(objects[0]);
//        } else {
//            block(nil);
//        }
//    }];
//}
//
//-(void)findRecieverBlock:(void (^)(PFObject* recieverObj))block
//{
//    PFQuery* query = [PFQuery queryWithClassName:kPFTableQueue];
//    query.limit = 1;
//    [query orderByAscending:@"createdAt"];
//    //    [query whereKey:kPFQueue_Owner notEqualTo:[PFUser currentUser]];
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        DLog(@"%@", objects);
//        if (objects.count) {
//            block(objects[0]);
//        } else {
//            block(nil);
//        }
//    }];
//}
//
//-(void)sendPushToObject:(PFObject*)object fromUser:(PFUser*)user
//{
//    PFQuery* pushQuery = [PFInstallation query];
//    [pushQuery whereKey:kPFInstallation_Owner equalTo:object[kPFQueue_Owner]];
//
//    PFPush* push = [[PFPush alloc] init];
//    [push setQuery:pushQuery];
//    //    [push setMessage:[NSString stringWithFormat:@"You have recieved a selfie from %@", [PFUser currentUser][kPFUser_Name]]];
//    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [NSString stringWithFormat:@"You have recieved a selfie from %@", user[kPFUser_Name]], @"alert",
//                          @"Increment", @"badge"
//                          , nil];
//    [push setData:data];
//    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//
//        //Remove object from queue
//        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//
//        }];
//    }];
//}


#pragma mark -

-(CGFloat)loopDurationForDelay:(CGFloat)delay imagesCount:(NSInteger)imagesCount
{
    CGFloat duration = (float)delay * imagesCount;
    
    return duration;
}

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
