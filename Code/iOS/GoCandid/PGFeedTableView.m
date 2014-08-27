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

-(void)getFeedForHashTag:(NSString *)hashTag completion:(void (^)(bool))block

{
    self.nxEV_emptyView = self.emptyView;
    
    PFQuery* query = [PFQuery queryWithClassName:kPFTableNameSelfies];
    
    [query whereKey:kPFSelfie_HashTags containedIn:@[hashTag]];
    
    query.limit = 5;
    query.skip = _datasource.count;
    [query includeKey:kPFSelfie_Owner];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            //            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
            
        } else {
            if (block) {
                block(YES);
            }
            [_datasource addObjectsFromArray:objects];
            NSInteger i = _datasource.count - objects.count;
            NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
            for (NSDictionary* result in objects) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                i++;
            }
            
            [PGParseHelper getLikeActivityForSelfies:_datasource fromUser:[PFUser currentUser] completion:^(BOOL finished, NSArray *likeObjects) {
                [_activityArray addObjectsFromArray:likeObjects];
                if (_datasource.count != objects.count) {
                    //Check if objects are new.
                    [self beginUpdates];
                    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self endUpdates];
                } else {
                    [self reloadData];
                }
                
            }];
        }
    }];
}

-(void)getFeedForUser:(PFUser *)user completion:(void (^)(bool))block
{
    self.nxEV_emptyView = self.emptyView;
    
    PFQuery* query = [PFQuery queryWithClassName:kPFTableNameSelfies];
    
    if (_feedType == FeedTypeMine) {
        [query whereKey:kPFSelfie_Owner equalTo:[PFUser currentUser]];
    } else if (_feedType == FeedTypeOther) {
        PFQuery* featuredList = [PFQuery queryWithClassName:kPFTableNameSelfies];
        [featuredList whereKey:kPFSelfie_Featured equalTo:[NSNumber numberWithBool:YES]];
        
        PFQuery* othersList = [PFQuery queryWithClassName:kPFTableNameSelfies];
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
        if (error) {
            //            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
            
        } else {
            if (block) {
                block(YES);
            }
            [_datasource addObjectsFromArray:objects];
            NSInteger i = _datasource.count - objects.count;
            NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
            for (NSDictionary* result in objects) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                i++;
            }
            
            [PGParseHelper getLikeActivityForSelfies:_datasource fromUser:[PFUser currentUser] completion:^(BOOL finished, NSArray *likeObjects) {
                [_activityArray addObjectsFromArray:likeObjects];
                if (_datasource.count != objects.count) {
                    //Check if objects are new.
#warning implement table reload
                    [self beginUpdates];
                    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self endUpdates];
                    //                    [self reloadData];
                } else {
                    [self reloadData];
                }
                
            }];
        }
    }];
}

-(NSInteger)numberOfRows
{
    return self.datasource.count;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableScrollViewWillBeginDragging:)]) {
        [_myDelegate tableScrollViewWillBeginDragging:scrollView];
    }
}

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
    //    cell.nameLabel.text = senderUser[kPFUser_Name];
    [cell.nameButton setTitle:senderUser[kPFUser_Name] forState:UIControlStateNormal];
    cell.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:((PFObject*)_datasource[indexPath.row]).createdAt], _datasource[indexPath.row][kPFSelfie_Location]];
    
    [PGParseHelper profilePhotoUser:senderUser completion:^(UIImage *image) {
        cell.thumbIV.image = image;
        //        [cell.thumbButton setImage:image    forState:UIControlStateNormal];
        //        [cell.thumbButton setBackgroundImage:image forState:UIControlStateNormal];
        //        cell.thumbButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    
    PFFile* file = _datasource[indexPath.row][kPFSelfie_Selfie];
    if (![file isKindOfClass:[NSNull class]] && file != NULL)
    {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
            //        UIImage* img = [UIImage imageWithData:data];
            [UIView transitionWithView:cell.mainIV duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                cell.mainIV.image = img;
            } completion:nil];
            //        UIImage* temp = [UIImage imageWithData:data];
            //        temp = [temp applyDarkEffect];
            //        cell.blurBgIV.image = temp;
        }];
    }
    
    cell.captionLabel.text = _datasource[indexPath.row][kPFSelfie_Caption];
    [cell.captionLabel setDetectionBlock:^(STTweetHotWord hotword, NSString *string, NSString *protocol, NSRange range) {
        DLog(@"%@", string);
        if (_myDelegate) {
            [_myDelegate tableView:self didTapOnKeyword:[string lowercaseString]];
        }
    }];
    if (_datasource[indexPath.row][kPFSelfie_Featured]) {
        cell.featuredView.hidden = NO;
    } else {
        cell.featuredView.hidden = YES;
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

-(void)cellDidTapOnNameButton:(PGFeedTableViewCell *)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:didTapOnNameButton:dataObject:)]) {
        [_myDelegate tableView:self didTapOnNameButton:indexPath dataObject:_datasource[indexPath.row]];
    }
}

-(void)cellDidTapOnThumbButton:(PGFeedTableViewCell *)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:didTapOnThumbButton:dataObject:)]) {
        [_myDelegate tableView:self didTapOnThumbButton:indexPath dataObject:_datasource[indexPath.row]];
    }
}

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
        [cell setLikeButtonState:NO];
        [PGParseHelper unlikeSelfie:object compltion:^(BOOL finished) {
            [PGParseHelper getTotalLikeForSelfie:object completion:^(BOOL finished, int number) {
                cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
            }];
        }];
    } else {
        [cell setLikeButtonState:YES];
        [PGParseHelper likeSelfie:object completion:^(BOOL finished) {
            DLog(@"Liked");
            [PGParseHelper getTotalLikeForSelfie:object completion:^(BOOL finished, int number) {
                cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
            }];
        }];
        [self sendPushToOwner:object[kPFSelfie_Owner]];
        [self showLikeButtonAnimationInCell:cell];
    }
}

-(void)sendPushToOwner:(PFUser*)user
{
    PFQuery* installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"owner" equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:installationQuery];
    [push setMessage:[NSString stringWithFormat:@"%@ liked your post.", [PFUser currentUser][kPFUser_Name]]];
    [push sendPushInBackground];
}

#pragma mark -

-(void)showLikeButtonAnimationInCell:(PGFeedTableViewCell*)cell
{
    UIImageView* likeIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    likeIV.center = CGPointMake(CGRectGetMidX(cell.mainIV.bounds), CGRectGetMidY(cell.mainIV.bounds));
    likeIV.image = [UIImage imageNamed:@"heartON"];
    [cell.mainIV addSubview:likeIV];
    
    [UIView animateWithDuration:0.5 animations:^{
        likeIV.alpha = 0;
        likeIV.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [likeIV removeFromSuperview];
    }];
}

@end
