//
//  PGFeedTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/10/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGFeedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* iv;
@property (strong, nonatomic) IBOutlet UILabel* captionLabel;
@property (strong, nonatomic) IBOutlet UILabel* senderLabel;

@end