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
@property (nonatomic, strong) STZPullToRefresh *pullToRefresh;

@end

@implementation PGFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// Setup pull to refresh
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    STZPullToRefreshView *refreshView = [[STZPullToRefreshView alloc] initWithFrame:CGRectMake(0, refreshBarY, self.view.frame.size.width, 3)];
    [self.view addSubview:refreshView];
    
    self.pullToRefresh = [[STZPullToRefresh alloc] initWithTableView:self.tableView
                                                         refreshView:refreshView
                                                   tableViewDelegate:self];
    self.tableView.delegate = self.pullToRefresh;
    self.pullToRefresh.delegate = self;
    
    [self.pullToRefresh startRefresh];
    
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
    [query whereKey:@"reciever" equalTo:[PFUser currentUser]];
    [query includeKey:@"owner"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        [self.pullToRefresh finishRefresh];

        _datasource = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

-(void)pullToRefreshDidStart
{
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
    cell.captionLabel.text = _datasource[indexPath.row][@"caption"];
    PFUser* senderUser = _datasource[indexPath.row][@"owner"];
    cell.senderLabel.text = senderUser[kPFUser_Name];
}

@end
