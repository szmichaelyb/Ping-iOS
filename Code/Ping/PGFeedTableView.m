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
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

-(void)getObjectsFromParseCompletion:(void (^) (bool finished))block
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableName_Selfies];
    
    if (_feedType == FeedTypeMine) {
        [query whereKey:kPFSelfie_Owner equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:kPFSelfie_Receiver equalTo:[PFUser currentUser]];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PGFeedTableViewCell" owner:self options:nil][0];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 261;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _datasource.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PGFeedHeader* view = [[NSBundle mainBundle] loadNibNamed:@"PGFeedHeader" owner:self options:nil][0];
    PFUser* senderUser = _datasource[section][kPFSelfie_Owner];
    view.nameLabel.text = senderUser[kPFUser_Name];
    view.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:((PFObject*)_datasource[section]).createdAt], _datasource[section][kPFSelfie_Location]];
    
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

- (void)configureCell:(PGFeedTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFFile* file = _datasource[indexPath.section][kPFSelfie_Selfie];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage* img = [UIImage imageWithData:data];
        cell.iv.image = img;
    }];
    cell.captionLabel.text = _datasource[indexPath.section][kPFSelfie_Caption];
    
    cell.iv.userInteractionEnabled = YES;
    cell.iv.tag = indexPath.section;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performFullScreenAnimation:)];
    [cell.iv addGestureRecognizer:gesture];
}

-(NSString*)friendlyDateTime:(NSDate*)dateTime
{
    NSTimeInterval interval = [dateTime timeIntervalSinceNow];
    TTTTimeIntervalFormatter* tif = [[TTTTimeIntervalFormatter alloc] init];
    NSString* str = [tif stringForTimeInterval:interval];
    return str;
}

-(void)performFullScreenAnimation:(UITapGestureRecognizer*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:sender.view.tag];
    
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
        [_myDelegate tableView:self moreButtonClicked:indexPath];
    }
}

@end
