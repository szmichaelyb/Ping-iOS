//
//  PGPingViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGPingViewController.h"

@interface PGPingViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIButton* sendButton;
@property (nonatomic, strong) IBOutlet UIButton* retakeButton;

-(IBAction)sendButtonClicked:(id)sender;
-(IBAction)retakeClicked:(id)sender;

@end

@implementation PGPingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
    
    self.sendButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.sendButton.layer.cornerRadius = self.sendButton.bounds.size.width/2;
    self.sendButton.layer.borderWidth = 2;
    self.sendButton.layer.masksToBounds = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendButtonClicked:(id)sender
{
    PFObject* object = [PFObject objectWithClassName:kPFTableName_Selfies];
    object[@"owner"] = [PFUser currentUser];
    
    NSData* imgData = UIImagePNGRepresentation(self.imageView.image);
    PFFile* imageFile = [PFFile fileWithName:@"selfie.png" data:imgData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        object[@"selfie"] = imageFile;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

-(IBAction)retakeClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)sendPush
{
    
}

@end
