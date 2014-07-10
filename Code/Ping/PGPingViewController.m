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
@property (nonatomic, strong) IBOutlet UITextField* captionTF;

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
    
    UITapGestureRecognizer* dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:dismissGesture];
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Enter a caption" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        PFObject* object = [PFObject objectWithClassName:kPFTableName_Selfies];
        object[@"owner"] = [PFUser currentUser];
        
        //TODO: Change it to
        NSData* imgData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        PFFile* imageFile = [PFFile fileWithName:@"selfie.png" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            object[@"selfie"] = imageFile;
            object[@"caption"] = _captionTF.text;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self sendPush];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
}

-(IBAction)retakeClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)sendPush
{
    
    PFQuery* query = [PFQuery queryWithClassName:kPFTableQueue];
    query.limit = 1;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"owner" notEqualTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        if (objects.count) {
            
            PFQuery* pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"owner" equalTo:((PFObject*)objects[0])[@"owner"]];
            
            PFPush* push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setMessage:@"You have recieved a selfie"];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                //Remove object from queue
                [objects[0] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                }];
            }];
        }
    }];
    
    
    PFObject* queueObject = [PFObject objectWithClassName:kPFTableQueue];
    queueObject[@"owner"] = [PFUser currentUser];
    [queueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    }];
    
    
}

@end
