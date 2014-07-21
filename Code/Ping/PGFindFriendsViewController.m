//
//  PGFindFriendsViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFindFriendsViewController.h"
#import "PGFindFriendsTableViewCell.h"

@interface PGFindFriendsViewController ()

@property (nonatomic, strong) NSMutableArray* datasource;
@property (nonatomic, strong) NSMutableArray* followingStatusArray;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

- (IBAction)segmentChanged:(UISegmentedControl*)seg;
- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation PGFindFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    _datasource = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(UISegmentedControl*)seg
{
    if (seg.selectedSegmentIndex == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAll:)];
        [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSArray* friends = result[@"data"];
            PFQuery* query = [PFUser query];
            [query whereKey:kPFUser_FBID containedIn:[friends valueForKey:@"id"]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                DLog(@"%@", objects);
                _datasource = [NSMutableArray arrayWithArray:objects];
                [self getFollowStatusCompletion:^(NSArray *array) {
                    _followingStatusArray = [NSMutableArray arrayWithArray:array];
                    DLog(@"%@", _followingStatusArray);
                    [self.tableView reloadData];
                }];
            }];
        }];
    }
    if (seg.selectedSegmentIndex == 2) {
        
    }
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)followAll:(id)sender
{
    for (int i = 0; i < _datasource.count; i++) {
        
        PFUser* user = _datasource[i];
        PGFindFriendsTableViewCell* cell = (PGFindFriendsTableViewCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.followButtonStatus == FollowButtonStateNotFollowing) {
            [PGParseHelper followUserInBackground:user completion:^(bool finished) {
                [cell setFollowButtonStatus:FollowButtonStateFollowing];
            }];
        }
    }
}

-(void)getFollowStatusCompletion:(void (^)(NSArray* array))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query whereKey:kPFActivity_ToUser containedIn:self.datasource];
    [query includeKey:kPFActivity_ToUser];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(objects);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGFindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PGFindFriendsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser* user = _datasource[indexPath.row];
    cell.nameLabel.text = user[kPFUser_Name];
    
    NSArray* followingUsers = [_followingStatusArray valueForKeyPath:kPFActivity_ToUser];
    if ([[followingUsers valueForKeyPath:kPFUser_FBID ]containsObject:_datasource[indexPath.row][kPFUser_FBID]]) {
        [cell setFollowButtonStatus:FollowButtonStateFollowing];
    } else {
        [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
    }
}

@end