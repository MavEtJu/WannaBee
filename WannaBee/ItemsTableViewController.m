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

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    // Do not set canSortBy.... here.

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ITEM];
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
    cell.backgroundColor = [UIColor clearColor];

    if (self.type == TYPE_POUCH) {
        dbItemInPouch *iip = (dbItemInPouch *)[self.items objectAtIndex:indexPath.row];
        dbItem *item = [dbItem get:iip.item_id];
        cell.itemName.text = item.name;
        cell.numbers.text = [NSString stringWithFormat:@"Item in pouch: #%d", iip.number];
        dbSet *set = [dbSet get:item.set_id];
        cell.setName.text = set.name;
        cell.image.image = [imageManager url:item.imgurl];
        if ([dbWishList getByItem:item] != nil)
            cell.backgroundColor = [UIColor yellowColor];
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
        if ([dbWishList getByItem:item] != nil)
            cell.backgroundColor = [UIColor yellowColor];
        return cell;
    }

    if (self.type == TYPE_SET) {
        dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
        dbItemInSet *iis = [dbItemInSet getByItemId:item];
        cell.itemName.text = item.name;
        if (iis != nil)
            cell.numbers.text = [NSString stringWithFormat:@"Item in set: #%d", iis.number];
        cell.image.image = [imageManager url:item.imgurl];
        if ([dbWishList getByItem:item] != nil)
            cell.backgroundColor = [UIColor yellowColor];
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

- (void)sortBySetName
{
    id sort = nil;

    if (self.type == TYPE_POUCH) {
        sort = ^(dbItemInPouch *a, dbItemInPouch *b) {
            dbItem *itemA = [dbItem get:a.item_id];
            dbItem *itemB = [dbItem get:b.item_id];
            dbSet *setA = [dbSet get:itemA.set_id];
            dbSet *setB = [dbSet get:itemB.set_id];
            return [setA.name compare:setB.name];
        };
    }

    if (self.type == TYPE_PLACE) {
        sort = ^(dbItemInPlace *a, dbItemInPlace *b) {
            dbItem *itemA = [dbItem get:a.item_id];
            dbItem *itemB = [dbItem get:b.item_id];
            dbSet *setA = [dbSet get:itemA.set_id];
            dbSet *setB = [dbSet get:itemB.set_id];
            return [setA.name compare:setB.name];
        };
    }

    if (self.type == TYPE_SET) {
        sort = ^(dbItemInSet *a, dbItemInSet *b) {
            dbItem *itemA = [dbItem get:a.item_id];
            dbItem *itemB = [dbItem get:b.item_id];
            dbSet *setA = [dbSet get:itemA.set_id];
            dbSet *setB = [dbSet get:itemB.set_id];
            return [setA.name compare:setB.name];
        };
    }

    NSAssert(sort != nil, @"sort == nil");
    self.items = [self.items sortedArrayUsingComparator:sort];
}

- (void)sortByItemName
{
    id sort = nil;

    if (self.type == TYPE_POUCH) {
        sort = ^(dbItemInPouch *a, dbItemInPouch *b) {
            dbItem *itemA = [dbItem get:a.item_id];
            dbItem *itemB = [dbItem get:b.item_id];
            return [itemA.name compare:itemB.name];
        };
    }

    if (self.type == TYPE_PLACE) {
        sort = ^(dbItemInPlace *a, dbItemInPlace *b) {
            dbItem *itemA = [dbItem get:a.item_id];
            dbItem *itemB = [dbItem get:b.item_id];
            return [itemA.name compare:itemB.name];
        };
    }

    if (self.type == TYPE_SET) {
        sort = ^(dbItem *a, dbItem *b) {
            return [a.name compare:b.name];
        };
    }

    NSAssert(sort != nil, @"sort == nil");
    self.items = [self.items sortedArrayUsingComparator:sort];
}

- (void)sortByPlaceName
{
    id sort = nil;

    if (self.type == TYPE_POUCH) {
        // Nope
    }

    if (self.type == TYPE_PLACE) {
        sort = ^(dbItemInPlace *a, dbItemInPlace *b) {
            dbPlace *placeA = [dbPlace get:a.place_id];
            dbPlace *placeB = [dbPlace get:b.place_id];
            return [placeA.name compare:placeB.name];
        };
    }

    if (self.type == TYPE_SET) {
        // Nope
    }

    NSAssert(sort != nil, @"sort == nil");
    self.items = [self.items sortedArrayUsingComparator:sort];
}

#define CMP(a, b) (a > b) ? 1L : (a < b) ? -1L : 0L

- (void)sortByItemNumber
{
    id sort = nil;

    if (self.type == TYPE_POUCH) {
        sort = ^(dbItemInPouch *a, dbItemInPouch *b) {
            return CMP(a.number, b.number);
        };
    }

    if (self.type == TYPE_PLACE) {
        sort = ^(dbItemInPlace *a, dbItemInPlace *b) {
            return CMP(a.number, b.number);
        };
    }

    if (self.type == TYPE_SET) {
        sort = ^(dbItem *a, dbItem *b) {
            dbItemInSet *iisA = [dbItemInSet getByItemId:a];
            dbItemInSet *iisB = [dbItemInSet getByItemId:b];
            return CMP(iisA.number, iisB.number);
        };
    }

    NSAssert(sort != nil, @"sort == nil");
    self.items = [self.items sortedArrayUsingComparator:sort];
}

@end
