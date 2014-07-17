//
//  PGSearchViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGSearchViewController.h"

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
    
    UITapGestureRecognizer* reco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    reco.delegate = self;
    [self.view addGestureRecognizer:reco];
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
//    if (_isFiltered) {
//        return _filteredDatasource.count;
//    } else {
        return [_datasource count];
//    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.contentView.tag = 1;
    cell.delegate = self;
    [self configureCell:cell
      forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PGSearchTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject* object = _datasource[indexPath.row];
    cell.nameLabel.text = object[kPFUser_Name];
    
    NSArray* folloingUsers = [_followStatusArray valueForKeyPath:kPFActivity_ToUser];
    if ([[folloingUsers valueForKey:kPFUser_FBID] containsObject:_datasource[indexPath.row][kPFUser_FBID]]) {
        [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

#pragma mark - UITablveView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_isFiltered)
//    {
//        //        _orderDetailVC = [[JPWOrderDetailViewController alloc] initWithOrderNum:[[_filteredDatasource objectAtIndex:indexPath.row] objectForKey:@"Order_Num"][@"text"] PONumber:[[_filteredDatasource objectAtIndex:indexPath.row] objectForKey:@"PO_Num"][@"text"]];
//    }
//    else
//    {
        //        _orderDetailVC = [[JPWOrderDetailViewController alloc] initWithOrderNum:[[_datasource objectAtIndex:indexPath.row] objectForKey:@"Order_Num"][@"text"] PONumber:[[_datasource objectAtIndex:indexPath.row] objectForKey:@"PO_Num"][@"text"]];
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //Push anotherVC
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

#pragma mark - UISearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0){
//        _isFiltered = false;
        [_tableView reloadData];
    }
    else
    {
        
        //Get objects from parse
        
        
        PFQuery *queryCapitalizedString = [PFUser query];
        [queryCapitalizedString whereKey:kPFUser_Name containsString:[searchBar.text capitalizedString]];
        
        //query converted user text to lowercase
        PFQuery *queryLowerCaseString = [PFUser query];
        [queryLowerCaseString whereKey:kPFUser_Name containsString:[searchBar.text lowercaseString]];
        
        //query real user text
        PFQuery *querySearchBarString = [PFUser query];
        [querySearchBarString whereKey:kPFUser_Name containsString:searchBar.text];
        
        PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryCapitalizedString,queryLowerCaseString, querySearchBarString,nil]];
        finalQuery.limit = 10;
        [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            _datasource = [[NSMutableArray alloc] initWithArray:objects];
            [self getFollowStatusCompletion:^(NSArray *array) {
                _followStatusArray = [NSMutableArray arrayWithArray:array];
                [self.tableView reloadData];
            }];
        }];
        
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
    [_tableView reloadData];
}

-(void)buttonTappedOnCell:(PGSearchTableViewCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PFUser* followUser = _datasource[indexPath.row];
    [PGParseHelper followUser:followUser];
}

-(void)getFollowStatusCompletion:(void (^)(NSArray* array))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query whereKey:kPFActivity_ToUser containedIn:self.datasource];
    [query includeKey:kPFActivity_ToUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(objects);
    }];
}

@end
