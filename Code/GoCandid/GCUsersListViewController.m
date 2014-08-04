//
//  GCUsersListViewController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 7/23/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCUsersListViewController.h"
#import "PGSearchTableViewCell.h"
#import "PGProfileViewController.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

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
    if (!_listForUser) {
        _listForUser = [PFUser currentUser];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getFollowingList
{
    [PGParseHelper getFollowingListForUser:_listForUser completion:^(BOOL finished, NSArray *followingUsers) {
        _datasource = [NSMutableArray arrayWithArray:[followingUsers valueForKey:kPFActivity_ToUser]];
        [self getFollowStatusArrayCompletion:^(NSArray *array) {
            _followStatusArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }];
    }];
}

-(void)getFollowersList
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_ToUser equalTo:_listForUser];
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

#pragma mark - UITableView Datasource

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
    if ([[[_followStatusArray valueForKey:kPFActivity_ToUser] valueForKey:kPFObjectId] containsObject:user.objectId]) {
        [cell setFollowButtonStatus:FollowButtonStateFollowing];
    } else {
        [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
    }
    [PGParseHelper profilePhotoUser:user completion:^(UIImage *image) {
        cell.thumbIV.image = image;
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGProfileViewController* profileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PGProfileViewController"];
    profileVC.profileUser = _datasource[indexPath.row];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark -

-(void)buttonTappedOnCell:(PGSearchTableViewCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PFUser* user = _datasource[indexPath.row];
    
    if ([cell followButtonStatus] == FollowButtonStateFollowing) {
        [UIActionSheet showInView:self.view.window withTitle:user[kPFUser_Name] cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [PGParseHelper unfollowUserInBackground:user completion:^(bool finished) {
                    [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
                }];
            }
        }];
    } else {
        [PGParseHelper followUserInBackground:user completion:^(bool finished) {
            [cell setFollowButtonStatus:FollowButtonStateFollowing];
        }];
    }
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
