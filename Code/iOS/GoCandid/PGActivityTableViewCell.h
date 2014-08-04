//
//  PGActivityTableViewCell.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGActivityTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *activityLabel;
@property (strong, nonatomic) IBOutlet UILabel *activityDate;
@property (strong, nonatomic) IBOutlet UIImageView *thumbIV;

@end
