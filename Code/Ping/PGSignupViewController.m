//
//  PGSignupViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSignupViewController.h"

@interface PGSignupViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTF;
@property (strong, nonatomic) IBOutlet UITextField *emailTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;

-(IBAction)signup:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end

@implementation PGSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nameTF becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signup:(id)sender
{
    if (self.nameTF.text.length != 0 && self.passwordTF.text.length != 0 && self.emailTF.text != 0) {
        //Create account
        
        PFUser* user = [PFUser user];
        user.password = self.passwordTF.text;
        user.email = self.emailTF.text;
        user[kPFUser_Name] = self.nameTF.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
