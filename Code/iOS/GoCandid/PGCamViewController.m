//
//  AVCamViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/9/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AVCamPreviewView.h"

#import "PGPingViewController.h"
#import "UIView+Animate.h"
#import <DZNPhotoPickerController.h>
#import "UIImagePickerControllerExtended.h"

#import "PGFramesButton.h"
#import <BFPaperButton/BFPaperButton.h>

static void * CapturingStillImageContext = &CapturingStillImageContext;
//static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

static float kDefaultCaptureDelay = 0.7f;

@interface PGCamViewController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;

@property (nonatomic, strong) NSMutableArray* images;

@property (nonatomic, strong) IBOutlet BFPaperButton* captureButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;
@property (nonatomic, strong) IBOutlet UIButton* manualButton;
@property (strong, nonatomic) IBOutlet UIScrollView *thumbScrollView;
@property (strong, nonatomic) IBOutlet PGFramesButton *framesButton;
@property (nonatomic, strong) IBOutlet UISlider* delaySlider;

//- (IBAction)toggleMovieRecording:(id)sender;
-(IBAction)changeCamera:(id)sender;
-(IBAction)captureButtonClicked:(id)sender;
-(IBAction)pickFromLibary:(id)sender;
-(IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)dismissButtonClicked:(id)sender;
-(IBAction)manualButtonClicked:(id)sender;
-(IBAction)delaySliderChanged:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
//@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation PGCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
//    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    
    //    if (_overalayImage) {
    //        self.overlayImageView.image = _overalayImage;
    //    } else {
    //        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clocseClicked:)];
    //    }
    
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
    
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [PGCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
		if (error)
		{
			DLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
                [(AVCaptureVideoPreviewLayer*) [[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			});
		}
        //
        //		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        //		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        //
        //		if (error)
        //		{
        //			DLog(@"%@", error);
        //		}
        //
        //		if ([session canAddInput:audioDeviceInput])
        //		{
        //			[session addInput:audioDeviceInput];
        //		}
        //
        //		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        //		if ([session canAddOutput:movieFileOutput])
        //		{
        //			[session addOutput:movieFileOutput];
        //			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //			if ([connection isVideoStabilizationSupported])
        //				[connection setEnablesVideoStabilizationWhenAvailable:YES];
        //			[self setMovieFileOutput:movieFileOutput];
        //		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
    
    _images = [NSMutableArray new];
    [self changeCamera:nil];
    self.delaySlider.value = kDefaultCaptureDelay;
    [self.delaySlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    self.captureButton.cornerRadius = self.captureButton.frame.size.width/2;
    self.captureButton.rippleFromTapLocation = NO;
    self.manualButton.titleLabel.font = FONT_OPENSANS_CONDLIGHT(FONT_SIZE_SMALL);
}

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        //		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak PGCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			PGCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
                //				[[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
			});
		}]];
		[[self session] startRunning];
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        //		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
    //	else if (context == RecordingContext)
    //	{
    //		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
    //
    //		dispatch_async(dispatch_get_main_queue(), ^{
    //			if (isRecording)
    //			{
    //				[[self cameraButton] setEnabled:NO];
    //				[[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
    //				[[self recordButton] setEnabled:YES];
    //			}
    //			else
    //			{
    //				[[self cameraButton] setEnabled:YES];
    //				[[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
    //				[[self recordButton] setEnabled:YES];
    //			}
    //		});
    //	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
                //				[[self recordButton] setEnabled:YES];
				[[self stillButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
                //				[[self recordButton] setEnabled:NO];
				[[self stillButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

//- (IBAction)toggleMovieRecording:(id)sender
//{
//	[[self recordButton] setEnabled:NO];
//
//	dispatch_async([self sessionQueue], ^{
//		if (![[self movieFileOutput] isRecording])
//		{
//			[self setLockInterfaceRotation:YES];
//
//			if ([[UIDevice currentDevice] isMultitaskingSupported])
//			{
//				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
//				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
//			}
//
//			// Update the orientation on the movie file output video connection before starting recording.
//			[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
//
//			// Turning OFF flash for video recording
//			[AVCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
//
//			// Start recording to a temporary file.
//			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
//			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
//		}
//		else
//		{
//			[[self movieFileOutput] stopRecording];
//		}
//	});
//}

- (IBAction)changeCamera:(id)sender
{
	[[self cameraButton] setEnabled:NO];
    //	[[self recordButton] setEnabled:NO];
	[[self stillButton] setEnabled:NO];
    __block	BOOL selfieMode;
    
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
                selfieMode = NO;
                
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
                selfieMode = YES;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
                selfieMode = NO;
				break;
		}
		
		AVCaptureDevice *videoDevice = [PGCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
            //			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[PGCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
            //			[[self recordButton] setEnabled:YES];
			[[self stillButton] setEnabled:YES];
            if (selfieMode) {
                [self.cameraButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            } else {
                [self.cameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
		});
	});
}

-(IBAction)manualButtonClicked:(id)sender
{
    for (UIView* subviews in _thumbScrollView.subviews) {
        [subviews removeFromSuperview];
    }
    _images = [NSMutableArray new];
    
    [self.manualButton setSelected:!self.manualButton.isSelected];
}

-(IBAction)captureButtonClicked:(id)sender
{
    if (self.manualButton.isSelected) {
        [self takePhotoDelay:0];
    } else {
        for (UIView* subviews in _thumbScrollView.subviews) {
            [subviews removeFromSuperview];
        }
        _images = [NSMutableArray new];

        for (int i = 0; i < _framesButton.buttonState; i++) {
            [self takePhotoDelay:self.delaySlider.value * i];
        }
    }
}

-(IBAction)delaySliderChanged:(UISlider*)sender
{
    self.delaySlider.value = sender.value;
}

-(void)takePhotoDelay:(int)delay
{
    [self performblock:^(int blockI, UIImage *image) {
        UIImageView* iv = [[UIImageView alloc]initWithImage:image];
        iv.frame = CGRectMake((blockI * _thumbScrollView.frame.size.height), 0, _thumbScrollView.frame.size.height, _thumbScrollView.frame.size.height);
        
        [_thumbScrollView addSubview:iv];
        [_thumbScrollView setContentSize:CGSizeMake((blockI + 1) * (iv.frame.size.width), _thumbScrollView.frame.size.height)];
        DLog(@"%@", NSStringFromCGRect(iv.frame));
        [_thumbScrollView scrollRectToVisible:iv.frame animated:YES];
        if (blockI == _framesButton.buttonState - 1) {
            [self userDidPickImages];
        }
    } afterDelay:delay];
}

-(void)performblock:(void (^) (int blockI, UIImage* image))block afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    
    [self performSelector:@selector(snapStillImage:) withObject:block afterDelay:delay];
}

- (void)snapStillImage:(void (^) (int blockI, UIImage* image))block
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [PGCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                image = [self scaleAndCropImage:image];
                
                [_images addObject:image];
                
                block([_images indexOfObject:image], image);
                //                [self userDidPickImage:image];
                //
                
                //				[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
}

-(IBAction)pickFromLibary:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        if (picker.cropMode != DZNPhotoEditorViewControllerCropModeNone) {
            
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image cropMode:picker.cropMode];
            [picker pushViewController:editor animated:YES];
        }
        else {
            //            [self userDidPickImage:info[UIImagePickerControllerEditedImage]];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)userDidPickImages
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    if (_overalayImage) {
    
    //Create GIF from _overlayimage and image
    PGPingViewController* pingVC = [sb instantiateViewControllerWithIdentifier:@"PGPingViewController"];
    //        pingVC.images = @[_overalayImage, image];
    pingVC.images = _images;
    pingVC.delegate = _delegate;
    [self.navigationController pushViewController:pingVC animated:YES];
    //    } else {
    //        PGCamViewController* camVC = [sb instantiateViewControllerWithIdentifier:@"PGCamViewController"];
    //        camVC.overalayImage = image;
    //        camVC.delegate = _delegate;
    //        [self.navigationController pushViewController:camVC animated:YES];
    //    }
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (IBAction)dismissButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate) {
        [_delegate didDismissCamViewController:self];
    }
    DLog(@"%@", self.tabBarController);
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	if (error)
		DLog(@"%@", error);
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
	
	[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error)
			DLog(@"%@", error);
		
		[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
		
		if (backgroundRecordingID != UIBackgroundTaskInvalid)
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
	}];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			DLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			DLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    //	dispatch_async(dispatch_get_main_queue(), ^{
    //		[[[self previewView] layer] setOpacity:0.0];
    //		[UIView animateWithDuration:.25 animations:^{
    //			[[[self previewView] layer] setOpacity:1.0];
    //		}];
    //	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"GoCandid!"
											message:@"GoCandid doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (UIImage*)scaleAndCropImage:(UIImage *)image
{ //process captured image, crop, resize and rotate
    //    haveImage = YES;
    //    photoFromCam = YES;
    
    // Resize image to 640x640
    // Resize image
    //    NSLog(@"Image size %@",NSStringFromCGSize(image.size));
    DLog(@"%d", [[self videoDeviceInput] device].position);
    if ([[self videoDeviceInput].device position] == AVCaptureDevicePositionFront) {
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
    }
    UIImage *smallImage = [self imageWithImage:image scaledToWidth:640.0f]; //UIGraphicsGetImageFromCurrentImageContext();
    
    CGRect cropRect = CGRectMake(0, 405, 640, 640);
    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
    
    //    croppedImageWithoutOrientation = [[UIImage imageWithCGImage:imageRef] copy];
    
    UIImage *croppedImage = nil;
    //    assetOrientation = ALAssetOrientationUp;
    
    // adjust image orientation
    //    NSLog(@"orientation: %d",orientationLast);
    //    orientationAfterProcess = orientationLast;
    //    switch (orientationLast) {
    //        case UIInterfaceOrientationPortrait:
    //            NSLog(@"UIInterfaceOrientationPortrait");
    croppedImage = [UIImage imageWithCGImage:imageRef];
    //            break;
    //
    //        case UIInterfaceOrientationPortraitUpsideDown:
    //            NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
    //            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
    //                                                       scale: 1.0
    //                                                 orientation: UIImageOrientationDown] autorelease];
    //            break;
    //
    //        case UIInterfaceOrientationLandscapeLeft:
    //            NSLog(@"UIInterfaceOrientationLandscapeLeft");
    //            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
    //                                                       scale: 1.0
    //                                                 orientation: UIImageOrientationRight] autorelease];
    //            break;
    //
    //        case UIInterfaceOrientationLandscapeRight:
    //            NSLog(@"UIInterfaceOrientationLandscapeRight");
    //            croppedImage = [[[UIImage alloc] initWithCGImage: imageRef
    //                                                       scale: 1.0
    //                                                 orientation: UIImageOrientationLeft] autorelease];
    //            break;
    //
    //        default:
    //            croppedImage = [UIImage imageWithCGImage:imageRef];
    //            break;
    //    }
    
    
    CGImageRelease(imageRef);
    
    return croppedImage;
    //    [self.captureImage setImage:croppedImage];
    //
    //    [self setCapturedImage];
}

- (UIImage*)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
