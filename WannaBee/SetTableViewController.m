//
//  SetTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface SetTableViewController ()

@property (nonatomic, retain) dbSet *set;
@property (nonatomic, retain) NSArray<NSObject *> *items;

@end

@implementation SetTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.type = TYPE_SET;
    [self refreshInit];

    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;

    return self;
}

- (NSArray<NSObject *> *)itemsForSection:(NSInteger)section
{
    return self.items;
}

- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section
{
    self.items = items;
}

- (void)refreshData
{
    self.items = [dbItem allInSet:self.set];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading set data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [dbItemInSet deleteBySet:self.set];
    [api api_users__sets:self.set.set_id];
    [dbFormula fixSource];
    self.set.needs_refresh = NO;
    [self.set dbUpdateNeedsRefresh];
    [self refreshData];
    [self refreshStop];
}

- (void)showSet:(dbSet *)set
{
    self.set = set;
    [self refreshData];
}

@end
