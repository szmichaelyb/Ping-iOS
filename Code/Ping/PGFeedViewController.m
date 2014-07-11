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
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import "PGFeedHeader.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface PGFeedViewController ()
{
    CGRect originalFrame;
    UIImageView* tempIV;
}

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, strong) STZPullToRefresh *pullToRefresh;

- (IBAction)moreButtonClicked:(UIButton *)sender;

@end

@implementation PGFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    /// Setup pull to refresh
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height;
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
    
    if (_feedType == FeedTypeMine) {
        [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"reciever" equalTo:[PFUser currentUser]];
    }
    
    [query includeKey:@"owner"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        [self.pullToRefresh finishRefresh];
        
        _datasource = [NSMutableArray arrayWithArray:objects];
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
    }];
}

-(void)pullToRefreshDidStart
{
    [self getObjectsFromParse];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PGFeedHeader* view = [[NSBundle mainBundle] loadNibNamed:@"PGFeedHeader" owner:self options:nil][0];
    PFUser* senderUser = _datasource[section][@"owner"];
    view.nameLabel.text = senderUser[kPFUser_Name];
    view.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:((PFObject*)_datasource[section]).createdAt], _datasource[section][@"location"]];
    
    PFFile* file = senderUser[kPFUser_Picture];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [view.thumbIV setImage:[UIImage imageWithData:data]];
    }];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    PFFile* file = _datasource[indexPath.section][@"selfie"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage* img = [UIImage imageWithData:data];
        cell.iv.image = img;
    }];
    cell.captionLabel.text = _datasource[indexPath.section][@"caption"];
    
    cell.iv.userInteractionEnabled = YES;
    cell.iv.tag = indexPath.section;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performFullScreenAnimation:)];
    [cell.iv addGestureRecognizer:gesture];
}

#pragma mark -

-(void)performFullScreenAnimation:(UITapGestureRecognizer*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:sender.view.tag];
    
    PGFeedTableViewCell* cell = (PGFeedTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView* iv = cell.iv;
    
    UIImageView* ivExpand = [[UIImageView alloc] initWithImage:iv.image];
    ivExpand.contentMode = iv.contentMode;
    ivExpand.frame = [self.view convertRect:iv.frame fromView:iv.superview];
    ivExpand.userInteractionEnabled = YES;
    ivExpand.clipsToBounds = YES;
    
    originalFrame = ivExpand.frame;
    originalFrame.origin.y = originalFrame.origin.y + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
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
        DLog(@"Animation has completed.");
        if (completion) {
            completion(anim, finished);
        }
    };
    
    [view pop_addAnimation:animation forKey:@"fullscreen"];
}

#pragma mark -

- (IBAction)moreButtonClicked:(UIButton *)sender
{
    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Report this post"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        DLog(@"%d", buttonIndex);
        if (buttonIndex == 0) {
            
            [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
                    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
                    
                    DLog(@"%@", _datasource[indexPath.section]);
                    PFObject* object = _datasource[indexPath.section];
                    object[@"abuse"] = [NSNumber numberWithBool:YES];
                    [object saveEventually];
                }
            }];
        }
    }];
}

-(NSString*)friendlyDateTime:(NSDate*)dateTime
{
    NSTimeInterval interval = [dateTime timeIntervalSinceNow];
    TTTTimeIntervalFormatter* tif = [[TTTTimeIntervalFormatter alloc] init];
    NSString* str = [tif stringForTimeInterval:interval];
    return str;
}

@end
