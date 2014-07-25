//
//  PGSearchViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSearchViewController.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import "PGProfileViewController.h"

@interface PGSearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray* datasource;
@property (nonatomic, strong) NSMutableArray* followStatusArray;

@end

@implementation PGSearchViewController

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;

    self.title = @"Search users";
    
    _datasource = [NSMutableArray new];
    
    UITapGestureRecognizer* reco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    reco.delegate = self;
    [self.view addGestureRecognizer:reco];
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

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag == 1 ){
        return NO;
    }
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

-(void)dismissKeyboard:(UITapGestureRecognizer*)reco
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
}

#pragma mark - UITablveView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datasource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PGSearchTableViewCell" owner:nil options:nil][0];
    }
    cell.contentView.tag = 1;
    cell.delegate = self;
    [self configureCell:cell
      forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PGSearchTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser* object = _datasource[indexPath.row];
    cell.nameLabel.text = object[kPFUser_Name];
    
    NSArray* folloingUsers = [_followStatusArray valueForKeyPath:kPFActivity_ToUser];
    if ([[folloingUsers valueForKey:kPFUser_FBID] containsObject:_datasource[indexPath.row][kPFUser_FBID]]) {
        [cell setFollowButtonStatus:FollowButtonStateFollowing];
        //        [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
        //        [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    [PGParseHelper profilePhotoUser:object completion:^(UIImage *image) {
        cell.thumbIV.image = image;
    }];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _datasource.count - 1) {
        [self loadFromParseText:_searchBar.text];
    }
}

#pragma mark - UITablveView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGProfileViewController* profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PGProfileViewController"];
    profileVC.profileUser = _datasource[indexPath.row];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

-(void)loadFromParseText:(NSString*)text
{
    //Get objects from parse
    PFQuery *queryCapitalizedString = [PFUser query];
    [queryCapitalizedString whereKey:kPFUser_Name containsString:[text capitalizedString]];
    
    //query converted user text to lowercase
    PFQuery *queryLowerCaseString = [PFUser query];
    [queryLowerCaseString whereKey:kPFUser_Name containsString:[text lowercaseString]];
    
    //query real user text
    PFQuery *querySearchBarString = [PFUser query];
    [querySearchBarString whereKey:kPFUser_Name containsString:text];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
    finalQuery.limit = 15;
    finalQuery.skip = _datasource.count;
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_datasource addObjectsFromArray:objects];
//        _datasource = [[NSMutableArray alloc] initWithArray:objects];
        DLog(@"%@", objects);
        DLog(@"%@", _datasource);
        [self getFollowStatusCompletion:^(NSArray *array) {
            _followStatusArray = [NSMutableArray arrayWithArray:array];
            if (objects.count != 0) {
                [self.tableView reloadData];
            }
        }];
    }];
}

#pragma mark - UISearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0){
        _datasource = [NSMutableArray new];
        [_tableView reloadData];
    } else {
        [self loadFromParseText:searchBar.text];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    for (UIView *possibleButton in searchBar.subviews)
    {
        if ([possibleButton isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*) possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    [self searchBar:searchBar textDidChange:_searchBar.text];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _datasource = [NSMutableArray new];
    [_tableView reloadData];
}

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

-(void)getFollowStatusCompletion:(void (^)(NSArray* array))block
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