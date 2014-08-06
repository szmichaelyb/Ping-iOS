//
//  PGFeedTableView.m
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedTableView.h"
#import "PGFeedHeader.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>

#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>
#import "UIImage+MyUIImage.h"

@interface PGFeedTableView()

@property (strong, nonatomic) NSMutableArray* datasource;
@property (strong, nonatomic) NSMutableArray* activityArray;

@end

@implementation PGFeedTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    self.showsVerticalScrollIndicator = NO;
    self.nxEV_hideSeparatorLinesWheyShowingEmptyView = YES;
    self.datasource = [NSMutableArray new];
    self.activityArray = [NSMutableArray new];
}

#pragma mark -

-(void)refreshDatasource
{
    _datasource = [NSMutableArray new];
}

-(void)getFeedForUser:(PFUser *)user completion:(void (^)(bool))block
{
    self.nxEV_emptyView = self.emptyView;
    
    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
    
    if (_feedType == FeedTypeMine) {
        [query whereKey:kPFSelfie_Owner equalTo:[PFUser currentUser]];
    } else if (_feedType == FeedTypeOther) {
        PFQuery* featuredList = [PFQuery queryWithClassName:kPFTableName_Selfies];
        [featuredList whereKey:kPFSelfie_Featured equalTo:[NSNumber numberWithBool:YES]];
        
        PFQuery* othersList = [PFQuery queryWithClassName:kPFTableName_Selfies];
        NSArray* array = [[PGParseHelper getFollowingListForUser:[PFUser currentUser]] valueForKey:kPFActivity_ToUser];
        [othersList whereKey:kPFSelfie_Owner containedIn:array];
        
        query = [PFQuery orQueryWithSubqueries:@[featuredList, othersList]];
    } else if (_feedType == FeedTypeFriends) {
        [query whereKey:kPFSelfie_Owner equalTo:user];
    } else if (_feedType == FeedTypeRecent) {
        
    }
    
    query.limit = 5;
    query.skip = _datasource.count;
    [query includeKey:kPFSelfie_Owner];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (block) {
            block(YES);
        }
        [_datasource addObjectsFromArray:objects];
        [PGParseHelper getLikeActivityForSelfies:_datasource fromUser:[PFUser currentUser] completion:^(BOOL finished, NSArray *likeObjects) {
            [_activityArray addObjectsFromArray:likeObjects];
            if (objects.count != 0) {
                
                [UIView setAnimationsEnabled:NO];
                [self reloadData];
                [UIView setAnimationsEnabled:YES];
//                [self reloadData];
            }
            
        }];
    }];
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableScrollViewDidScroll:)]) {
        [_myDelegate tableScrollViewDidScroll:scrollView];
    }
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tablescrollViewDidScrollToTop:)]) {
        [_myDelegate tablescrollViewDidScrollToTop:scrollView];
    }
}

#pragma mark - UITableView Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 430;
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
    PGFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PGFeedTableViewCell" owner:self options:nil][0];
    }
    cell.delegate = self;
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PGFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser* senderUser = _datasource[indexPath.row][kPFSelfie_Owner];
    cell.nameLabel.text = senderUser[kPFUser_Name];
    cell.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:((PFObject*)_datasource[indexPath.row]).createdAt], _datasource[indexPath.row][kPFSelfie_Location]];
    
    [PGParseHelper profilePhotoUser:senderUser completion:^(UIImage *image) {
        cell.thumbIV.image = image;
    }];
    
    PFFile* file = _datasource[indexPath.row][kPFSelfie_Selfie];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
//        UIImage* img = [UIImage imageWithData:data];
        [UIView transitionWithView:cell.mainIV duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            cell.mainIV.image = img;
        } completion:nil];
        UIImage* temp = [UIImage imageWithData:data];
//        temp = [temp applyDarkEffect];
//        cell.blurBgIV.image = temp;
    }];
    
    cell.captionLabel.text = _datasource[indexPath.row][kPFSelfie_Caption];
    
    if (_datasource[indexPath.row][kPFSelfie_Featured]) {
        cell.featuredLabel.hidden = NO;
    } else {
        cell.featuredLabel.hidden = YES;
    }
    
    if ([[[_activityArray valueForKey:kPFActivity_Selfie] valueForKey:kPFObjectId] containsObject:[_datasource[indexPath.row] valueForKey:kPFObjectId]]) {
        [cell setLikeButtonState:YES];
    } else {
        [cell setLikeButtonState:NO];
    }
    
    [PGParseHelper getTotalLikeForSelfie:_datasource[indexPath.row] completion:^(BOOL finished, int number) {
        cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
    }];
    
    cell.mainIV.userInteractionEnabled = YES;
//    cell.mainIV.tag = indexPath.row;
//    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performFullScreenAnimation:)];
//    [cell.iv addGestureRecognizer:gesture];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PGFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _datasource.count - 1) {
        if (_myDelegate) {
            [_myDelegate tableView:self willDisplayLastCell:cell];
        }
    }
//    [cell.mainIV startAnimating];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(PGFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [cell.mainIV stopAnimating];
}

#pragma mark -

-(NSString*)friendlyDateTime:(NSDate*)dateTime
{
    NSTimeInterval interval = [dateTime timeIntervalSinceNow];
    TTTTimeIntervalFormatter* tif = [[TTTTimeIntervalFormatter alloc] init];
    NSString* str = [tif stringForTimeInterval:interval];
    return str;
}

//-(void)performFullScreenAnimation:(UITapGestureRecognizer*)sender
//{
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:0];
//    
//    PGFeedTableViewCell* cell = (PGFeedTableViewCell*)[self cellForRowAtIndexPath:indexPath];
//    
//    if (_myDelegate) {
//        [_myDelegate tableView:self didTapOnImageView:cell.mainIV];
//    }
//}

#pragma mark - PGFeedTableViewCell Delegate

//-(void)cellDidStartTap:(PGFeedTableViewCell *)cell
//{
//    NSIndexPath* indexPath = [self indexPathForCell:cell];
//    PFFile* file = _datasource[indexPath.row][kPFSelfie_Selfie];
//    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        //        UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
//        UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
//        cell.iv.image = img;
//    }];
//}
//
//-(void)cellDidStopTap:(PGFeedTableViewCell *)cell
//{
//    NSIndexPath* indexPath = [self indexPathForCell:cell];
//    PFFile* file = _datasource[indexPath.row][kPFSelfie_Selfie];
//    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        //        UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
//        UIImage* img = [UIImage imageWithData:data];
//        cell.iv.image = img;
//    }];
//}

-(void)cellDidTapOnMoreButton:(PGFeedTableViewCell *)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    
    if (_myDelegate) {
        [_myDelegate tableView:self moreButtonClicked:indexPath dataObject:_datasource[indexPath.row]];
    }
}

-(void)cellDidTapOnLikeButton:(PGFeedTableViewCell *)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    PFObject* object = _datasource[indexPath.row];
    BOOL alreadyLike = cell.likeButtonState;
    if (alreadyLike) {
        [PGParseHelper unlikeSelfie:object compltion:^(BOOL finished) {
            [cell setLikeButtonState:NO];
            [PGParseHelper getTotalLikeForSelfie:object completion:^(BOOL finished, int number) {
                cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
            }];
        }];
    } else {
        [PGParseHelper likeSelfie:object completion:^(BOOL finished) {
            DLog(@"Liked");
            [cell setLikeButtonState:YES];
            [PGParseHelper getTotalLikeForSelfie:object completion:^(BOOL finished, int number) {
                cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
            }];
        }];
        [self showLikeButtonAnimationInCell:cell];
    }
}

-(void)showLikeButtonAnimationInCell:(PGFeedTableViewCell*)cell
{
    UIImageView* likeIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    likeIV.center = CGPointMake(CGRectGetMidX(cell.mainIV.bounds), CGRectGetMidY(cell.mainIV.bounds));
    likeIV.image = [[UIImage imageNamed:@"like"] imageWithOverlayColor:[UIColor redColor]];
    [cell.mainIV addSubview:likeIV];
    
    [UIView animateWithDuration:0.5 animations:^{
        likeIV.alpha = 0;
        likeIV.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [likeIV removeFromSuperview];
    }];
}

@end
