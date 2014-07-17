//
//  PGSearchTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGSearchTableViewCellDelegate;

@interface PGSearchTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (assign, nonatomic) id<PGSearchTableViewCellDelegate> delegate;

@end

@protocol PGSearchTableViewCellDelegate <NSObject>

-(void)buttonTappedOnCell:(PGSearchTableViewCell*)cell;

@end