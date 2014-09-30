//
//  GCCommentTableViewCell.h
//  GoCandid
//
//  Created by Rishabh Tayal on 9/30/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* commentText;
@property (nonatomic, strong) IBOutlet UIImageView* userImage;

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset;

@end
