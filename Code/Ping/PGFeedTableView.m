//
//  PGFeedTableView.m
//  Ping
//
//  Created by Rishabh Tayal on 7/14/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedTableView.h"
#import "PGFeedHeader.h"
#import "PGFeedTableViewCell.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>

#import "UIImage+animatedGIF.h"
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

@interface PGFeedTableView()

@property (strong, nonatomic) NSMutableArray* datasource;

- (IBAction)moreButtonClicked:(UIButton *)sender;

@end

@implementation PGFeedTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.delegate = self;
        self.dataSource = self;
        self.nxEV_hideSeparatorLinesWheyShowingEmptyView = YES;
    }
    return self;
}

-(void)getObjectsFromParseCompletion:(void (^) (bool finished))block
{
    self.nxEV_emptyView = self.emptyView;

    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
    
    if (_feedType == FeedTypeMine) {
        [query whereKey:kPFSelfie_Owner equalTo:[PFUser currentUser]];
    } else if (_feedType == FeedTypeOther) {
        PFQuery* featuredList = [PFQuery queryWithClassName:kPFTableName_Selfies];
        [featuredList whereKey:kPFSelfie_Featured equalTo:[NSNumber numberWithBool:YES]];
        
        PFQuery* othersList = [PFQuery queryWithClassName:kPFTableName_Selfies];
        [othersList whereKey:kPFSelfie_Receiver equalTo:[PFUser currentUser]];
        
        query = [PFQuery orQueryWithSubqueries:@[featuredList, othersList]];
    }
    
    [query includeKey:kPFSelfie_Owner];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        //        [self.pullToRefresh finishRefresh];
        if (block) {
            block(YES);
        }
        _datasource = [NSMutableArray arrayWithArray:objects];
        [self reloadData];
    }];
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableScrollViewDidScroll:)]) {
        [_myDelegate tableScrollViewDidScroll:scrollView];
    }
}

#pragma mark - UITableView Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 459;
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
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PGFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser* senderUser = _datasource[indexPath.row][kPFSelfie_Owner];
    cell.nameLabel.text = senderUser[kPFUser_Name];
    cell.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:((PFObject*)_datasource[indexPath.row]).createdAt], _datasource[indexPath.row][kPFSelfie_Location]];
    
    PFFile* thumbFile = senderUser[kPFUser_Picture];
    [thumbFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [cell.thumbIV setImage:[UIImage imageWithData:data]];
    }];
    
    
    PFFile* file = _datasource[indexPath.row][kPFSelfie_Selfie];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
        cell.iv.image = img;
    }];
    
    cell.captionLabel.text = _datasource[indexPath.row][kPFSelfie_Caption];
    
    if (_datasource[indexPath.row][kPFSelfie_Featured]) {
        cell.featuredLabel.hidden = NO;
    } else {
        cell.featuredLabel.hidden = YES;
    }
    cell.iv.userInteractionEnabled = YES;
    cell.iv.tag = indexPath.row;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performFullScreenAnimation:)];
    [cell.iv addGestureRecognizer:gesture];
}

#pragma mark -

-(NSString*)friendlyDateTime:(NSDate*)dateTime
{
    NSTimeInterval interval = [dateTime timeIntervalSinceNow];
    TTTTimeIntervalFormatter* tif = [[TTTTimeIntervalFormatter alloc] init];
    NSString* str = [tif stringForTimeInterval:interval];
    return str;
}

-(void)performFullScreenAnimation:(UITapGestureRecognizer*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:0];
    
    PGFeedTableViewCell* cell = (PGFeedTableViewCell*)[self cellForRowAtIndexPath:indexPath];
    
    if (_myDelegate) {
        [_myDelegate tableView:self didTapOnImageView:cell.iv];
    }
}

-(void)moreButtonClicked:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self];
    NSIndexPath* indexPath = [self indexPathForRowAtPoint:buttonPosition];
    
    if (_myDelegate) {
        [_myDelegate tableView:self moreButtonClicked:indexPath dataObject:_datasource[indexPath.row]];
//        [_myDelegate tableView:self moreButtonClicked:indexPath] ;
    }
}

@end
