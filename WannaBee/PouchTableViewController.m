//
//  PouchViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PouchTableViewController ()

@end

@implementation PouchTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Pouch";
    self.type = TYPE_POUCH;

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshInit];
}

- (void)refreshData
{
    self.items = [dbItemInPouch all];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading pouch data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [api api_users__pouch];
    [self refreshData];
    [self refreshStop];
}

@end
