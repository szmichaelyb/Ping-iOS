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

- (IBAction)moreButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;

@end

@implementation PGFeedTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.thumbIV.layer.cornerRadius = self.thumbIV.frame.size.width/2;
    self.thumbIV.layer.masksToBounds = YES;
    
    [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    [self.likeButton setImage:[[self.likeButton imageForState:UIControlStateSelected] imageWithOverlayColor:[UIColor redColor]] forState:UIControlStateSelected];
    
    [self.likeButton setImage:[UIImage imageNamed:@"like_empty"] forState:UIControlStateNormal];
    [self.likeButton setImage:[[self.likeButton imageForState:UIControlStateNormal] imageWithOverlayColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
