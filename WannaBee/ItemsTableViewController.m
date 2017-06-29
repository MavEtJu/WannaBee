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
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ITEM];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;
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
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];

    cell.itemName.text = @"";
    cell.setName.text = @"";
    cell.placeName.text = @"";
    cell.numbers.text = @"";

    if (self.type == TYPE_POUCH) {
        dbItemInPouch *iip = (dbItemInPouch *)[self.items objectAtIndex:indexPath.row];
        dbItem *item = [dbItem get:iip.item_id];
        cell.itemName.text = item.name;
        cell.numbers.text = [NSString stringWithFormat:@"Item in pouch: #%d", iip.number];
        dbSet *set = [dbSet get:item.set_id];
        cell.setName.text = set.name;
        cell.image.image = [imageManager url:item.imgurl];
        return cell;
    }

    if (self.type == TYPE_PLACE) {
        dbItemInPlace *iip = (dbItemInPlace *)[self.items objectAtIndex:indexPath.row];
        dbItem *item = [dbItem get:iip.item_id];
        cell.itemName.text = item.name;
        cell.numbers.text = [NSString stringWithFormat:@"Item in place: #%d", iip.number];
        dbSet *set = [dbSet get:item.set_id];
        cell.setName.text = set.name;
        cell.image.image = [imageManager url:item.imgurl];
        return cell;
    }

    if (self.type == TYPE_SET) {
        dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
        dbItemInSet *iis = [dbItemInSet getByItemId:item];
        cell.itemName.text = item.name;
        if (iis != nil)
            cell.numbers.text = [NSString stringWithFormat:@"Item in set: #%d", iis.number];
        cell.image.image = [imageManager url:item.imgurl];
        return cell;
    }

    NSAssert(FALSE, @"Shouldn't happen");
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.type) {
        case TYPE_SET:
            return YES;
        case TYPE_POUCH: {
            dbItemInPouch *iip = (dbItemInPouch *)[self.items objectAtIndex:indexPath.row];
            dbItem *item = [dbItem get:iip.item_id];
            if ([dbWishList getByItem:item] == nil)
                return NO;
            return YES;
        }
        case TYPE_NEWER:
        case TYPE_UNKNOWN:
        case TYPE_PLACE:
            return NO;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    switch (self.type) {
        case TYPE_SET: {
            dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
            if ([dbWishList getByItem:item] == nil)
                return @"Add to wishlist";
            else
                return @"Remove from wishlist";
        }
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
    switch (self.type) {
        case TYPE_SET: {
            dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
            dbWishList *wl = [dbWishList getByItem:item];
            if (wl == nil) {
                wl = [[dbWishList alloc] init];
                wl.item_id = item._id;
                [wl create];
            } else {
                [wl _delete];
            }
            [self.tableView reloadData];
            return;
        }
        case TYPE_POUCH: {
            dbItemInPouch *iip = (dbItemInPouch *)[self.items objectAtIndex:indexPath.row];
            dbItem *item = [dbItem get:iip.item_id];
            dbWishList *wl = [dbWishList getByItem:item];
            [wl _delete];
            [self.tableView reloadData];
            return;
        }
        case TYPE_UNKNOWN:
        case TYPE_NEWER:
        case TYPE_PLACE:
            return;
    }
}


@end
