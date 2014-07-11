//
//  PGFeedViewController.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedViewController.h"
#import "PGFeedTableViewCell.h"
#import <pop/POP.h>

@interface PGFeedViewController ()
{
    CGRect originalFrame;
    UIImageView* tempIV;
}

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
    
    self.pullToRefresh = [[STZPullToRefresh alloc] initWithTableView:self.tableView refreshView:refreshView tableViewDelegate:self];
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
//        [query whereKey:@"reciever" equalTo:[PFUser currentUser]];
  
        [query whereKey:@"owner" equalTo:[PFUser currentUser]];
  
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
    
    cell.iv.userInteractionEnabled = YES;
    cell.iv.tag = indexPath.row;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performFullScreenAnimation:)];
    [cell.iv addGestureRecognizer:gesture];
}

-(void)performFullScreenAnimation:(UITapGestureRecognizer*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:0];
    
    PGFeedTableViewCell* cell = (PGFeedTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView* iv = cell.iv;
    
    UIImageView* ivExpand = [[UIImageView alloc] initWithImage:iv.image];
    ivExpand.contentMode = iv.contentMode;
    ivExpand.frame = [self.view convertRect:iv.frame fromView:iv.superview];
    ivExpand.userInteractionEnabled = YES;
    ivExpand.clipsToBounds = YES;
    
    originalFrame = ivExpand.frame;
    tempIV = cell.iv;
    
    [self.navigationController.view addSubview:ivExpand];
    self.tabBarController.tabBar.hidden = YES;
    
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFullScreen:)];
    [ivExpand addGestureRecognizer:tgr];
    
    [self animateView:ivExpand toFrame:self.view.bounds completion:^(POPAnimation *anim, bool finished) {
        tempIV.hidden = YES;
    }];
}

-(void)removeFullScreen:(UITapGestureRecognizer*)tgr
{
    CGRect frame = originalFrame;
    self.tabBarController.tabBar.hidden = NO;
    
    [self animateView:tgr.view toFrame:frame completion:^(POPAnimation *anim, bool finished) {
        [tgr.view removeFromSuperview];
        tempIV.hidden = NO;
    }];
}

-(void)animateView:(UIView*)view toFrame:(CGRect)frame completion:(void (^)(POPAnimation* anim, bool finished))completion
{
    [view pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation.springBounciness = 10;
    
    animation.toValue = [NSValue valueWithCGRect:frame];
    
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        NSLog(@"Animation has completed.");
        if (completion) {
            completion(anim, finished);
        }
    };
    
    [view pop_addAnimation:animation forKey:@"fullscreen"];
}

@end
