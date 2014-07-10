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
                
                [self findRecieverBlock:^(PFObject *recieverObj) {
                    
                    object[@"reciever"] = recieverObj[@"owner"];
                    [object saveEventually];
                    
                    [self sendPushToObject:recieverObj];
                    
                    PFObject* queueObject = [PFObject objectWithClassName:kPFTableQueue];
                    queueObject[@"owner"] = [PFUser currentUser];
                    [queueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                    }];
                    
                }];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
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
        NSLog(@"%@", objects);
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
    [push setMessage:[NSString stringWithFormat:@"You have recieved a selfie from %@", [PFUser currentUser][kPFUser_Name]]];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //Remove object from queue
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }];
}

@end
