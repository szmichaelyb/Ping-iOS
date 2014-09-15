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
//#import <BFPaperButton/BFPaperButton.h>
#import "GCZoomInTrasitionController.h"
#import "GCGIFHelper.h"

@interface PGPingViewController ()

@property (strong, nonatomic) NSURL* imageURL;

@property (nonatomic, strong) IBOutlet UIButton* sendButton;
@property (nonatomic, strong) IBOutlet UIButton* retakeButton;
@property (nonatomic, strong) IBOutlet UISlider* durationSlider;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

-(IBAction)retakeClicked:(id)sender;
-(IBAction)durationSliderChanged:(UISlider*)sender;
-(IBAction)sliderDidFinishChanging:(id)sender;
-(IBAction)nextButtonClicked:(id)sender;

@end

@implementation PGPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
//    _imageURL = [self saveGifWithImages:_images gifDelay:kDefaultGifDelay];
    _imageURL = [GCGIFHelper saveGifWithImages:_images gifDelay:kDefaultGifDelay];
    
    _durationSlider.value = kDefaultGifDelay;
    [_durationSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self durationSliderChanged:_durationSlider];
    
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
//    self.sendButton.cornerRadius = self.sendButton.frame.size.width/2;
//    self.sendButton.rippleFromTapLocation = NO;
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

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (fromVC == self && [toVC isKindOfClass:[PGSendPingViewController class]]) {
        return [[GCZoomInTrasitionController alloc] init];
    }
    return nil;
}

-(IBAction)durationSliderChanged:(UISlider *)sender
{
    DLog(@"Slider Value: %f", sender.value);
//    CGFloat duration = [self loopDurationForDelay:sender.value imagesCount:_images.count];
    CGFloat duration = [GCGIFHelper loopDurationForDelay:sender.value imagesCount:_images.count];
    _durationLabel.text = [NSString stringWithFormat:@"%.1f sec", duration];
}

- (IBAction)sliderDidFinishChanging:(UISlider*)sender
{
//    _imageURL = [self saveGifWithImages:_images gifDelay:sender.value];
    _imageURL = [GCGIFHelper saveGifWithImages:_images gifDelay:sender.value];
    _imageView.image = [UIImage animatedImageWithAnimatedGIFURL:_imageURL];
}


-(IBAction)retakeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextButtonClicked:(id)sender
{
    PGSendPingViewController* sendPingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PGSendPingViewController"];
    sendPingVC.delegate = _delegate;
    sendPingVC.gifUrl = _imageURL;
    [self.navigationController pushViewController:sendPingVC animated:YES];
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



@end
