//
//  PGSearchViewController.h
//  Ping
//
//  Created by Rishabh Tayal on 7/17/14.
//  Copyright (c) 2014 Appikon Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGSearchTableViewCell.h"

@interface PGSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, PGSearchTableViewCellDelegate>

@end
