//
//  GCUsersListViewController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 7/23/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCUsersListViewController.h"
#import "PGSearchTableViewCell.h"

@interface GCUsersListViewController ()

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* datasource;
@property (nonatomic, strong) NSMutableArray* followStatusArray;

@end

@implementation GCUsersListViewController

- (id)init
{
    self = [super initWithNibName:@"GCUsersListViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_listType == GCListTypeFollowing) {
        self.title = @"Following";
        [self getFollowingList];
    } else {
        self.title = @"Followers";
        [self getFollowersList];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getFollowingList
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query includeKey:kPFActivity_ToUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _datasource = [NSMutableArray arrayWithArray:[objects valueForKey:kPFActivity_ToUser]];
        _followStatusArray = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadData];
    }];
}

-(void)getFollowersList
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_ToUser equalTo:[PFUser currentUser]];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query includeKey:kPFActivity_FromUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _datasource = [NSMutableArray arrayWithArray:[objects valueForKey:kPFActivity_FromUser]];
        [self getFollowStatusArrayCompletion:^(NSArray *array) {
            _followStatusArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PGSearchTableViewCell" owner:nil options:nil][0];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PGSearchTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%@", _datasource[indexPath.row]);
    PFUser* user = _datasource[indexPath.row];
    cell.nameLabel.text = user[kPFUser_Name];
    cell.delegate = self;
    if ([[_followStatusArray valueForKey:kPFActivity_ToUser] containsObject:user]) {
        [cell setFollowButtonStatus:FollowButtonStateFollowing];
    } else {
    [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
    }
    [PGParseHelper profilePhotoUser:user completion:^(UIImage *image) {
        cell.thumbIV.image = image;
    }];
}

-(void)buttonTappedOnCell:(PGSearchTableViewCell *)cell
{
    
}

-(void)getFollowStatusArrayCompletion:(void (^)(NSArray* array))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query whereKey:kPFActivity_ToUser containedIn:self.datasource];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    [query includeKey:kPFActivity_ToUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(objects);
    }];
}

@end
