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

@end

@implementation SetTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.type = TYPE_SET;
    [self refreshInit];

    return self;
}

- (void)refreshData
{
    self.items = [dbItem allInSet:self.set];
    [self.tableView reloadData];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading set data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [api api_users__sets:self.set.set_id];
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
