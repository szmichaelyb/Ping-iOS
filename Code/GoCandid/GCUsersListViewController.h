//
//  GCUsersListViewController.h
//  GoCandid
//
//  Created by Rishabh Tayal on 7/23/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGSearchUserTableViewCell.h"

typedef enum
{
    GCListTypeFollowing = 0,
    GCListTypeFollowers
}GCListType;

@interface GCUsersListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PGSearchUserTableViewCellDelegate>

@property (nonatomic, strong) PFUser* listForUser;
@property (nonatomic, assign) GCListType listType;

@end