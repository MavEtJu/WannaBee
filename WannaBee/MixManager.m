//
//  MixManager.m
//  WannaBee
//
//  Created by Edwin Groothuis on 3/7/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface MixManager ()

@end

@implementation MixManager

- (instancetype)init
{
    self = [super init];

    self.itemsNeeded = nil;
    self.itemsMixable = nil;
    self.itemsNeededForMixing = nil;

    return self;
}

- (void)refreshMixData
{
    self.itemsInPouch = [dbItem allInPouch];
    self.itemsInPlaces = [dbItem allInPlaces];

    self.itemsNeeded = [NSMutableArray arrayWithArray:[dbItem allNotInASet]];
    NSLog(@"Items needed: %d", [self.itemsNeeded count]);

    self.itemsMixable = [NSMutableArray arrayWithCapacity:[self.itemsNeeded count]];
    [self.itemsNeeded enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[dbFormula allNeededForItem:item] count] != 0)
            [self.itemsMixable addObject:item];
    }];
    NSLog(@"Items mixable: %d", [self.itemsMixable count]);

    self.itemsNeededForMixing = [NSMutableArray arrayWithCapacity:[self.itemsNeeded count]];

    NSMutableDictionary *seen = [NSMutableDictionary dictionaryWithCapacity:20];
    [self.itemsMixable enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [self findSourcesForItem:item seen:seen];
    }];
}

- (void)findSourcesForItem:(dbItem *)item seen:(NSMutableDictionary *)seen
{
    if ([seen objectForKey:[NSNumber numberWithInteger:item._id]] != nil)
        return;

    if (item._id == 1871)
        NSLog(@"foo");
    NSLog(@"Searching for formula for %d '%@' (Depth: %d)", item._id, item.name, [seen count]);
    [seen setObject:item forKey:[NSNumber numberWithInteger:item._id]];

    NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:item];
    if ([formulas count] == 0) {
        if ([seen count] != 1)
            [self.itemsNeededForMixing addObject:item];
        NSLog(@"No formulas");
        [seen removeObjectForKey:[NSNumber numberWithInteger:item._id]];
        return;
    }
    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:formula.source_id];
        NSLog(@"Finding item for formula %d '%@'", i._id, i.name);
        [self.itemsNeededForMixing addObject:i];

        NSArray<dbItemInPouch *> *iipo = [dbItemInPouch allByItem:i];
        NSArray<dbItemInPlace *> *iipl = [dbItemInPlace findThisItem:i];
        if ([iipo count] != 0) {
            NSLog(@"Found in pouch");
            [seen removeObjectForKey:[NSNumber numberWithInteger:item._id]];
            return;
        }
        if ([iipl count] != 0) {
            NSLog(@"Found in places");
            [seen removeObjectForKey:[NSNumber numberWithInteger:item._id]];
            return;
        }

        NSLog(@"Not found, finding formula for formula %d '%@'", i._id, i.name);
        [self findSourcesForItem:i seen:seen];
    }];

    [seen removeObjectForKey:[NSNumber numberWithInteger:item._id]];
}

- (UITableViewCell *)cellForFormula:(dbItem *)item
{
    return nil;
}

- (BOOL)isItemNeeded:(dbItem *)item
{
    __block BOOL found = NO;

    [self.itemsNeeded enumerateObjectsUsingBlock:^(dbItem * _Nonnull i, NSUInteger idx, BOOL * _Nonnull stop) {
        if (i.item_type_id == item.item_type_id) {
            found = YES;
            *stop = YES;
        }
    }];

    return found;
}

- (BOOL)isItemMixable:(dbItem *)item;
{
    __block BOOL found = NO;

    [self.itemsMixable enumerateObjectsUsingBlock:^(dbItem * _Nonnull i, NSUInteger idx, BOOL * _Nonnull stop) {
        if (i.item_type_id == item.item_type_id) {
            found = YES;
            *stop = YES;
        }
    }];

    return found;
}

- (BOOL)isItemNeededForMixing:(dbItem *)item
{
    __block BOOL found = NO;

    [self.itemsNeededForMixing enumerateObjectsUsingBlock:^(dbItem * _Nonnull i, NSUInteger idx, BOOL * _Nonnull stop) {
        if (i.item_type_id == item.item_type_id) {
            found = YES;
            *stop = YES;
        }
    }];

    return found;
}

@end
