//
//  PGFindFriendsViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/21/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFindFriendsViewController.h"
#import "PGFindFriendsTableViewCell.h"
#import <AddressBook/AddressBook.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@interface PGFindFriendsViewController ()<PGFindFriendsCellDelegate>

@property (nonatomic, strong) NSMutableArray* allDeviceContacts;
@property (nonatomic, strong) NSMutableArray* deviceContactsUsingApp;
@property (nonatomic, strong) NSMutableArray* deviceContactsNotUsingApp;

@property (nonatomic, strong) NSMutableArray* facebookDatasource;

@property (nonatomic, strong) NSMutableArray* followingStatusArray;

@property (nonatomic, strong) IBOutlet UISegmentedControl* segControl;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

- (IBAction)segmentChanged:(UISegmentedControl*)seg;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)inviteFacebookFriendsClicked:(id)sender;

@end

@implementation PGFindFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    _allDeviceContacts = [NSMutableArray new];
    _deviceContactsUsingApp = [NSMutableArray new];
    _deviceContactsNotUsingApp = [NSMutableArray new];
    _facebookDatasource = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAll:)];
    
    [NSThread detachNewThreadSelector:@selector(loadDeviceContacts) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(loadFacebookFriends) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadDeviceContacts
{
    NSMutableArray* allcontacts = [NSMutableArray new];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        accessGranted = NO;
    }
    
    if (accessGranted) {
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        CFIndex numberOfPeople = CFArrayGetCount(people);
        for (int i = 0; i < numberOfPeople; i++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
            ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
            for (CFIndex j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)(ABMultiValueCopyValueAtIndex(emails, j));
                NSString* firstName = (__bridge NSString*)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
                NSString* lastName = (__bridge NSString*)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
                NSString* name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                NSData* imgData = (__bridge NSData*)(ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail));
                UIImage* img = [UIImage imageWithData:imgData];
                if (img == nil) {
                    img = [UIImage imageNamed:@"NoProfilePhotoIMAGE"];
                }
                
                NSDictionary* dict = @{@"name": name, @"email": email, @"image": img};
                [allcontacts addObject:dict];
            }
            CFRelease(emails);
        }
        CFRelease(addressBook);
        CFRelease(people);
    }
    
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray* sortDescriptors = [NSArray arrayWithObject:descriptor];
    [allcontacts sortedArrayUsingDescriptors:sortDescriptors];
    _allDeviceContacts = [NSMutableArray arrayWithArray:[allcontacts sortedArrayUsingDescriptors:sortDescriptors]];
    [self getUserUsingApp:_allDeviceContacts completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)loadFacebookFriends
{
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray* friends = result[@"data"];
        PFQuery* query = [PFUser query];
        [query whereKey:kPFUser_FBID containedIn:[friends valueForKey:@"id"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            DLog(@"%@", objects);
            _facebookDatasource = [NSMutableArray arrayWithArray:objects];
            [self getFollowStatusForArray:_facebookDatasource completion:^(NSArray *array) {
                _followingStatusArray = [NSMutableArray arrayWithArray:array];
                DLog(@"%@", _followingStatusArray);
                [self.tableView reloadData];
            }];
        }];
    }];
}

- (IBAction)segmentChanged:(UISegmentedControl*)seg
{
    if (seg.selectedSegmentIndex == 0) {
        [self.tableView reloadData];
    }
    if (seg.selectedSegmentIndex == 1) {
        if (_facebookDatasource.count == 0) {
            [self loadFacebookFriends];
        }
        [self.tableView reloadData];
    }
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteFacebookFriendsClicked:(id)sender
{
    //invite
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"message" title:nil parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        
    }];
}

-(void)followAll:(id)sender
{
    NSArray* tempArr;
    if (self.segControl.selectedSegmentIndex == 0) {
        tempArr = [_deviceContactsUsingApp copy];
    } else {
        tempArr = [_facebookDatasource copy];
    }
    for (int i = 0; i < tempArr.count; i++) {
        
        PFUser* user = tempArr[i];
        PGFindFriendsTableViewCell* cell = (PGFindFriendsTableViewCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.followButtonStatus == FollowButtonStateNotFollowing) {
            [PGParseHelper followUserInBackground:user completion:^(bool finished) {
                [cell setFollowButtonStatus:FollowButtonStateFollowing];
            }];
        }
    }
}

-(void)getUserUsingApp:(NSArray*)users completion:(void (^) (PFObject* object))block
{
    PFQuery* query = [PFUser query];
    [query whereKey:kPFUser_Email containedIn:[users valueForKey:@"email"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        for (int i = 0; i < users.count; i++) {
            NSDictionary* contact = users[i];
            if ([[objects valueForKey:kPFUser_Email] containsObject:contact[@"email"]]) {
                
                NSPredicate* predicte = [NSPredicate predicateWithFormat:@"email == %@", contact[@"email"]];
                NSArray* filteredArray = [objects filteredArrayUsingPredicate:predicte];
                id firstFoundObject = nil;
                firstFoundObject = filteredArray.count > 0 ? filteredArray.firstObject : nil;
                [_deviceContactsUsingApp addObject:firstFoundObject];
            } else {
                [_deviceContactsNotUsingApp addObject:contact];
            }
        }
        [self getFollowStatusForArray:_deviceContactsUsingApp completion:^(NSArray *array) {
            _followingStatusArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }];
    }];
}

-(void)getFollowStatusForArray:(NSArray*)usersArray completion:(void (^)(NSArray* array))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableActivity];
    [query whereKey:kPFActivity_Type equalTo:kPFActivity_Type_Follow];
    [query whereKey:kPFActivity_ToUser containedIn:usersArray];
    [query includeKey:kPFActivity_ToUser];
    [query whereKey:kPFActivity_FromUser equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(objects);
    }];
}

#pragma mark -

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.segControl.selectedSegmentIndex == 0) {
        if (section == 0) {
            return @"contacts using GoCandid";
        } else {
            return @"Contact not using GoCandid";
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.segControl.selectedSegmentIndex == 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segControl.selectedSegmentIndex == 0) {
        if (section == 0) {
            return _deviceContactsUsingApp.count;
        } else {
            return _deviceContactsNotUsingApp.count;
        }
    } else {
        return _facebookDatasource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGFindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    if (self.segControl.selectedSegmentIndex == 0) {
        [self configureCell:cell forDeviceContactsAtIndexPath:indexPath];
    } else if (self.segControl.selectedSegmentIndex == 1) {
        [self configureCell:cell forFacebookAtIndexPath:indexPath];
    }
    
    return cell;
}

-(void)configureCell:(PGFindFriendsTableViewCell*)cell forFacebookAtIndexPath:(NSIndexPath*)indexPath
{
    PFUser* user = _facebookDatasource[indexPath.row];
    cell.nameLabel.text = user[kPFUser_Name];
    
    NSArray* followingUsers = [_followingStatusArray valueForKeyPath:kPFActivity_ToUser];
    if ([[followingUsers valueForKeyPath:kPFUser_FBID ]containsObject:_facebookDatasource[indexPath.row][kPFUser_FBID]]) {
        [cell setFollowButtonStatus:FollowButtonStateFollowing];
    } else {
        [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
    }
}

-(void)configureCell:(PGFindFriendsTableViewCell*)cell forDeviceContactsAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        cell.nameLabel.text = _deviceContactsUsingApp[indexPath.row][@"name"];
        NSArray* followingUsers = [_followingStatusArray valueForKeyPath:kPFActivity_ToUser];
        if ([[followingUsers valueForKeyPath:kPFUser_FBID] containsObject:_deviceContactsUsingApp[indexPath.row][kPFUser_FBID]]) {
            [cell setFollowButtonStatus:FollowButtonStateFollowing];
        } else {
            [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
        }
    } else {
        cell.nameLabel.text = _deviceContactsNotUsingApp[indexPath.row][@"name"];
        [cell setFollowButtonStatus:FollowButtonStateInvite];
    }
    
    //    cell.nameLabel.text  = _deviceContactsDatasource[indexPath.
}

#pragma mark - PGFindFriendsTableViewCell Delegate

-(void)cell:(PGFindFriendsTableViewCell *)cell didClickOnButton:(UIButton *)button
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PFUser* user;
    if (self.segControl.selectedSegmentIndex == 0) {
        if (indexPath.section == 0) {
            user = _deviceContactsUsingApp[indexPath.row];
        } else {
            user = _deviceContactsNotUsingApp[indexPath.row];
        }
    } else {
        user = _facebookDatasource[indexPath.row];
    }
    
    DLog(@"%d", cell.followButtonStatus);
    if (cell.followButtonStatus == FollowButtonStateFollowing) {
        [UIActionSheet showInView:self.view.window withTitle:user[kPFUser_Name] cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [PGParseHelper unfollowUserInBackground:user completion:^(bool finished) {
                    [cell setFollowButtonStatus:FollowButtonStateNotFollowing];
                }];
            }
        }];
    } else if (cell.followButtonStatus == FollowButtonStateNotFollowing) {
        [PGParseHelper followUserInBackground:user completion:^(bool finished) {
            [cell setFollowButtonStatus:FollowButtonStateFollowing];
        }];
    } else if (cell.followButtonStatus == FollowButtonStateInvite) {
        //Invite
    }
}

@end