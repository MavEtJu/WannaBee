//
//  ItemTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ItemsTableViewController ()

@end

@implementation ItemsTableViewController

#define CELL_ITEM   @"CELL_ITEM"

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_ITEM];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];

    cell.textLabel.text = @"-";
    cell.detailTextLabel.text = @"";

    if (self.type == TYPE_POUCH) {
        dbItemInPouch *iip = [dbItemInPouch getByItem:item];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (#%d)", item.name, iip.number];
        dbSet *set = [dbSet get:item.set_id];
        cell.detailTextLabel.text = set.name;
        return cell;
    }

    if (self.type == TYPE_PLACE) {
        dbItemInPlace *iip = [dbItemInPlace getByItemId:item place:self.place];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (#%d)", item.name, iip.number];
        dbSet *set = [dbSet get:item.set_id];
        cell.detailTextLabel.text = set.name;
        return cell;
    }

    if (self.type == TYPE_SET) {
        dbItemInSet *iis = [dbItemInSet getByItemId:item];
        cell.textLabel.text = item.name;
        if (iis != nil)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"#%d", iis.number];
        return cell;
    }

    NSAssert(FALSE, @"Shouldn't happen");
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
    switch (self.type) {
        case TYPE_SET:
            return YES;
        case TYPE_POUCH:
            if ([dbWishList getByItem:item] == nil)
                return NO;
            return YES;
        case TYPE_NEWER:
        case TYPE_UNKNOWN:
        case TYPE_PLACE:
            return NO;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
    switch (self.type) {
        case TYPE_SET:
            if ([dbWishList getByItem:item] == nil)
                return @"Add to wishlist";
            else
                return @"Remove from wishlist";
        case TYPE_POUCH:
            return @"Remove from wishlist";
        case TYPE_UNKNOWN:
        case TYPE_NEWER:
        case TYPE_PLACE:
            return @"???";
    }
    return @"???";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
    dbWishList *wl = [dbWishList getByItem:item];
    switch (self.type) {
        case TYPE_SET:
            if (wl == nil) {
                wl = [[dbWishList alloc] init];
                wl.item_id = item._id;
                [wl create];
            } else {
                [wl _delete];
            }
            [self.tableView reloadData];
            return;
        case TYPE_POUCH:
            [wl _delete];
            [self.tableView reloadData];
            return;
        case TYPE_UNKNOWN:
        case TYPE_NEWER:
        case TYPE_PLACE:
            return;
    }
}


@end
