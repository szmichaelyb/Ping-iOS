//
//  PGFeedTableViewCell.m
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import "PGFeedTableViewCell.h"
#import "UIImage+MyUIImage.h"

@interface PGFeedTableViewCell()

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UILabel* featuredLabel;

- (IBAction)nameButtonClicked:(id)sender;
//- (IBAction)thumbButtonClicked:(id)sender;
- (IBAction)moreButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;

@end

@implementation PGFeedTableViewCell

- (void)awakeFromNib
{
    // Initialization code.
    
    self.nameButton.titleLabel.font = FONT_GEOSANSLIGHT(FONT_SIZE_MEDIUM);
    self.timeAndlocationLabel.font = FONT_OPENSANS_CONDBOLD(FONT_SIZE_XS);
    self.captionLabel.font = FONT_OPENSANS_CONDLIGHT(FONT_SIZE_MEDIUM);
    self.featuredLabel.font = FONT_GEOSANSLIGHT(FONT_SIZE_MEDIUM);
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.thumbIV.layer.cornerRadius = self.thumbIV.frame.size.width/2;
    self.thumbIV.layer.masksToBounds = YES;
    self.thumbIV.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* thumbTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbButtonClicked:)];
    [self.thumbIV addGestureRecognizer:thumbTapGesture];
    [self.likeButton setImage:[UIImage imageNamed:@"heartON"] forState:UIControlStateSelected];
    
    [self.likeButton setImage:[UIImage imageNamed:@"heartOFF"] forState:UIControlStateNormal];
    
//    UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    gesture.minimumPressDuration = 0.08;
//    gesture.allowableMovement = 600;
//    [self.mainIV addGestureRecognizer:gesture];
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.mainIV addGestureRecognizer:doubleTapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)handleDoubleTap:(UIGestureRecognizer*)gesture
{
    [self likeButtonClicked:self.likeButton];
}

//-(void)handleGesture:(UIGestureRecognizer*)gesture
//{
//    DLog(@"%d", gesture.state);
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        if (_delegate) {
//            [_delegate cellDidStartTap:self];
//        }
//    }
//    if (gesture.state == UIGestureRecognizerStateEnded) {
//        if (_delegate) {
//            [_delegate cellDidStopTap:self];
//        }
//    }
//}

- (IBAction)nameButtonClicked:(id)sender
{
    if (_delegate) {
        [_delegate cellDidTapOnNameButton:self];
    }
}

- (IBAction)thumbButtonClicked:(id)sender
{
    if (_delegate) {
        [_delegate cellDidTapOnThumbButton:self];
    }
}

- (IBAction)moreButtonClicked:(id)sender {
    if (_delegate) {
        [_delegate cellDidTapOnMoreButton:self];
    }
}

- (IBAction)likeButtonClicked:(id)sender {
    if (_delegate) {
        [_delegate cellDidTapOnLikeButton:self];
    }
}

-(void)setLikeButtonState:(BOOL)liked
{    
    [self.likeButton setSelected:liked];
}

-(BOOL)likeButtonState
{
    return self.likeButton.selected;
}

@end
