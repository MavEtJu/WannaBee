//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlaceTableViewController ()

@end

@implementation PlaceTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.type = TYPE_PLACE;
    [self refreshInit];

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;
    
    return self;
}
    
- (void)refreshData
{
    self.items = [dbItemInPlace allItemsInPlace:self.place];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading place data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [api api_places__items:self.place.place_id];
    [self refreshData];
    [self refreshStop];
}

- (void)showPlace:(dbPlace *)place
{
    self.place = place;
    [self refreshData];
}

@end
