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
#import "PGFeedTableView.h"
#import "PGProgressHUD.h"

@interface PGFeedViewController ()<PGFeedTableViewDelegate>
{
    CGRect originalFrame;
    UIImageView* tempIV;
}

@property (strong, nonatomic) PGFeedTableView* tableView;

//@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, strong) STZPullToRefresh *pullToRefresh;


@end

@implementation PGFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    /// Setup pull to refresh
    CGFloat refreshBarY = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.tableView = [[PGFeedTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.myDelegate = self;
    self.tableView.feedType = FeedTypeOther;
    DLog(@"%f", self.tabBarController.tabBar.frame.size.height);
    self.tableView.contentInset=  UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height + refreshBarY, 0);
    [self.view addSubview:self.tableView];
    
    STZPullToRefreshView *refreshView = [[STZPullToRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    [self.view addSubview:refreshView];
    
    self.pullToRefresh = [[STZPullToRefresh alloc] initWithTableView:self.tableView refreshView:refreshView tableViewDelegate:self.tableView];
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

-(void)pullToRefreshDidStart
{
    [self.tableView getObjectsFromParseCompletion:^(bool finished) {
        [self.pullToRefresh finishRefresh];
    }];
}

#pragma mark - PGFeedTableView Delegate

-(void)tableView:(PGFeedTableView *)tableView moreButtonClicked:(NSIndexPath*)indexPath dataObject:(id)object
{
    [UIActionSheet showInView:self.view.window withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report inappropriate" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        DLog(@"%d", buttonIndex);
        if (buttonIndex == 0) {
            
            [UIActionSheet showInView:self.view.window withTitle:@"Are you sure?" cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
//                    DLog(@"%@", _datasource[indexPath.row]);
                    
//                    PFObject* object = object;
                    object[kPFSelfie_Abuse] = [NSNumber numberWithBool:YES];
                    [object saveEventually:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [[PGProgressHUD sharedInstance] showInView:self.navigationController.view withText:@"Reported"];
                        }
                    }];
                }
            }];
        }
    }];
}


-(void)tableView:(PGFeedTableView *)tableView didTapOnImageView:(UIImageView *)imageView
{
//    UIImageView* iv = imageView;
//    
//    UIImageView* ivExpand = [[UIImageView alloc] initWithImage:iv.image];
//    ivExpand.contentMode = iv.contentMode;
//    ivExpand.frame = [self.view convertRect:iv.frame fromView:iv.superview];
//    ivExpand.userInteractionEnabled = YES;
//    ivExpand.clipsToBounds = YES;
//    
//    originalFrame = ivExpand.frame;
////    originalFrame.origin.y = originalFrame.origin.y + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
//    tempIV = imageView;
//    
//    [self.navigationController.view addSubview:ivExpand];
//    self.tabBarController.tabBar.hidden = YES;
//    
//    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFullScreen:)];
//    [ivExpand addGestureRecognizer:tgr];
//    
//    [self animateView:ivExpand toFrame:self.view.bounds completion:^(POPAnimation *anim, bool finished) {
//        tempIV.hidden = YES;
//    }];
}

#pragma mark -

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

@end
