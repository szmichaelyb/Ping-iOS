//
//  GCPhotoDetailViewController.m
//  GoCandid
//
//  Created by Rishabh Tayal on 9/30/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "GCPhotoDetailViewController.h"
#import "GCPhotoDetailsFooterView.h"
#import "PGFeedTableViewCell.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "GCCommentTableViewCell.h"

@interface GCPhotoDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PGFeedTableViewCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* commentsDatasource;

@property (nonatomic, strong) UITextField *commentTextField;

@end

@implementation GCPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set table header
    PGFeedTableViewCell* cell = [[NSBundle mainBundle] loadNibNamed:@"PGFeedTableViewCell" owner:nil options:nil][0];
    [self configureSelfieView:cell];
    self.tableView.tableHeaderView = cell;

    // Set table footer
    GCPhotoDetailsFooterView *footerView = [[GCPhotoDetailsFooterView alloc] initWithFrame:[GCPhotoDetailsFooterView rectForView]];
    _commentTextField = footerView.commentField;
    _commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;
    
    [self loadObjects];
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height - kbSize.height) animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_commentTextField resignFirstResponder];
}

-(void)configureSelfieView:(PGFeedTableViewCell*)cell
{
    PFUser* senderUser = _photo[kPFSelfie_Owner];
    //    cell.nameLabel.text = senderUser[kPFUser_Name];
    [cell.nameButton setTitle:senderUser[kPFUser_Name] forState:UIControlStateNormal];
    cell.timeAndlocationLabel.text = [NSString stringWithFormat:@"%@ at %@", [self friendlyDateTime:_photo.createdAt], _photo[kPFSelfie_Location]];
    
    [PGParseHelper profilePhotoUser:senderUser completion:^(UIImage *image) {
        cell.thumbIV.image = image;
        //        [cell.thumbButton setImage:image    forState:UIControlStateNormal];
        //        [cell.thumbButton setBackgroundImage:image forState:UIControlStateNormal];
        //        cell.thumbButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    
    PFFile* file = _photo[kPFSelfie_Selfie];
    if (![file isKindOfClass:[NSNull class]] && file != NULL)
    {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage* img = [UIImage animatedImageWithAnimatedGIFData:data];
            //        UIImage* img = [UIImage imageWithData:data];
            [UIView transitionWithView:cell.mainIV duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                cell.mainIV.image = img;
            } completion:nil];
        }];
    }
    
    cell.captionLabel.text = _photo[kPFSelfie_Caption];
    [cell.captionLabel setDetectionBlock:^(STTweetHotWord hotword, NSString *string, NSString *protocol, NSRange range) {
        DLog(@"%@", string);
//        if (_myDelegate) {
//            [_myDelegate tableView:self didTapOnKeyword:[string lowercaseString]];
//        }
    }];
    if ([_photo[kPFSelfie_Featured] boolValue]) {
        cell.featuredView.hidden = NO;
    } else {
        cell.featuredView.hidden = YES;
    }

//    if ([[[_likeActivityArray valueForKey:kPFActivity_Selfie] valueForKey:kPFObjectId] containsObject:[_datasource[indexPath.row] valueForKey:kPFObjectId]]) {
//        [cell setLikeButtonState:YES];
//    } else {
//        [cell setLikeButtonState:NO];
//    }
    
    [PGParseHelper getTotalCommentsForSelfie:_photo completion:^(BOOL finished, int number) {
        [cell.commentButton setTitle:[NSString stringWithFormat:@"%d comments", number] forState:UIControlStateNormal];
    }];
    
    [PGParseHelper getTotalLikeForSelfie:_photo completion:^(BOOL finished, int number) {
        cell.totalLikes.text = [NSString stringWithFormat:@"%d likes", number];
    }];
}

#pragma mark - UITextfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.photo objectForKey:kPFSelfie_Owner]) {
        
        [PGParseHelper commentOnSelfie:self.photo comment:trimmedComment completion:^(BOOL finished) {
            [self loadObjects];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

-(void)loadObjects
{
    _commentsDatasource = [NSMutableArray new];
    [PGParseHelper getCommentActivityForSelfie:_photo completion:^(BOOL finished, NSArray *objects) {
        DLog(@"%@", objects);
        [_commentsDatasource addObjectsFromArray:objects];
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [self.commentsDatasource objectAtIndex:indexPath.row];
    
    if (object) {
        NSString *commentString = [self.commentsDatasource[indexPath.row] objectForKey:kPFActivity_Content];
        
        PFUser *commentAuthor = (PFUser *)[object objectForKey:kPFActivity_FromUser];
        
        NSString *nameString = @"";
        if (commentAuthor) {
            nameString = [commentAuthor objectForKey:kPFUser_Name];
        }
        
        return [GCCommentTableViewCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:20.0f];
    }
    
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentsDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GCCommentTableViewCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GCCommentTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.commentText.text = _commentsDatasource[indexPath.row][kPFActivity_Content];
    
    [PGParseHelper profilePhotoUser:_commentsDatasource[indexPath.row][kPFActivity_FromUser] completion:^(UIImage *image) {
        cell.userImage.image = image;
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
