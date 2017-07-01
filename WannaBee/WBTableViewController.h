//
//  WBTableViewController.h
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface WBTableViewController : UITableViewController<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL canSortBySetName;
@property (nonatomic) BOOL canSortByItemName;
@property (nonatomic) BOOL canSortByPlaceName;
@property (nonatomic) BOOL canSortByItemNumber;

- (void)refreshInit;
- (void)refreshTitle:(NSString *)title;
- (void)refreshStop;

- (void)sortBySetName:(NSInteger)section;
- (void)sortByItemName:(NSInteger)section;
- (void)sortByPlaceName:(NSInteger)section;
- (void)sortByItemNumber:(NSInteger)section;

@end
