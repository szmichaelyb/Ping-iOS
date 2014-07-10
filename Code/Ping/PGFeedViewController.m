//
//  PGFeedViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedViewController.h"
#import "PGFeedTableViewCell.h"

@interface PGFeedViewController ()

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSMutableArray* datasource;

@end

@implementation PGFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    [self getObjectsFromParse];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getObjectsFromParse
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        _datasource = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

-(void)refreshTable:(UIRefreshControl*)refreshControl
{
    [refreshControl endRefreshing];
    
    [self getObjectsFromParse];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PGFeedTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFFile* file = _datasource[indexPath.row][@"selfie"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage* img = [UIImage imageWithData:data];
        cell.iv.image = img;
    }];
}

@end
