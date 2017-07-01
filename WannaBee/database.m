//
//  database.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation database

- (instancetype)init
{
    self = [super init];

    NSFileManager *fm = [NSFileManager defaultManager];

    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *apsupDirectory = [paths objectAtIndex:0];
    NSString *dataDistributionDirectory = [[NSBundle mainBundle] resourcePath];

    NSError *error = nil;
    [fm createDirectoryAtPath:apsupDirectory withIntermediateDirectories:YES attributes:nil error:&error];

    NSString *database = [NSString stringWithFormat:@"%@/database.db", apsupDirectory];
    NSString *empty = [NSString stringWithFormat:@"%@/empty.db", dataDistributionDirectory];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"erasedatabase"] == YES) {
        [fm removeItemAtPath:database error:&error];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"erasedatabase"];
        NSLog(@"Nuking database");
    }

    if ([fm fileExistsAtPath:database] == YES) {
        NSLog(@"database: database.db already exists");
    } else {
        if ([fm fileExistsAtPath:empty] == NO) {
            NSLog(@"database: empty.db couldn't be found");
        } else {
            NSLog(@"database: installing empty.db as database.db");
            [fm copyItemAtPath:empty toPath:database error:&error];
            if (error != nil)
                NSLog(@"database: unable to copy: %@", [error description]);
        }
    }

    sqlite3 *db = nil;
    sqlite3_open([database UTF8String], &db);
    NSAssert(db != nil, @"db");
    self.db = db;
    NSLog(@"database: Using %@", database);

    return self;
}

- (void)upgrade
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"refreshallsets"] == YES) {
        [self execute:@"update sets set needs_refresh = 1"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshallsets"];
        NSLog(@"Refreshing all sets");
    }

    dbConfig *c = [dbConfig getByKey:@"version"];
    if (c == nil) {
        c = [[dbConfig alloc] init];
        c.key = @"version";
        c.value = @"0";
        [c create];
    }
    NSLog(@"Version: %@", c.value);
    switch ([c.value integerValue]) {
        case 0:
            [self execute:@"alter table places add column radius integer"];
            /* fall through */
        case 1:
            [self execute:@"insert into sets(set_name, set_id, items_in_set, needs_refresh) values('Unique Items', 25, 0, 0)"];
            [self execute:@"insert into sets(set_name, set_id, items_in_set, needs_refresh) values('Branded Items', 20, 0, 0)"];
            /* fall through */
        case 2:
            [self execute:@"alter table places add column lat float"];
            [self execute:@"alter table places add column lon float"];
            /* fall through */
        case 3:
            [self execute:@"alter table items add column imgurl text"];
            [self execute:@"alter table sets add column imgurl text"];
            [self execute:@"alter table places add column imgurl text"];
            /* fall through */
        case 4:
            [self execute:@"create table formulas(id integer primary key, item_id integer, source_number integer, source_id integer, formula integer)"];
            /* fall through */
        case 5:
            [self execute:@"alter table places add column safeplace bool"];
            [self execute:@"update places set safeplace = 0"];
            /* fall through */
        case 6:
            [self execute:@"delete from items_in_places where place_id = 0"];
            /* fall through */
        default:
            ;
    }
#define VERSION 6
    c.value = [NSString stringWithFormat:@"%d", VERSION];
    [c update];
}

- (void)execute:(NSString *)sql
{
    @synchronized (db) {
        DB_PREPARE(sql);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

/* Methods */

+ (NSArray<NSArray *> *)newerItemsInPlaces
{
    NSMutableArray *ss = [NSMutableArray arrayWithCapacity:20];

    dbPlace *excludePlace = [dbPlace getByPlaceName:@"The WallaBee Museum"];

    NSString *sql = @"select i.id, p.id, iip.id, iis.id from items i join items_in_places iip on i.id = iip.item_id join places p on iip.place_id = p.id join items_in_sets iis on iip.item_id = iis.item_id where iip.number < iis.number and iip.place_id != ?";

    @synchronized(db) {
        DB_PREPARE(sql);

        SET_VAR_INT(1, excludePlace._id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(0, item_id);
            INT_FETCH_AND_ASSIGN(1, place_id);
            INT_FETCH_AND_ASSIGN(2, iip_id);
            INT_FETCH_AND_ASSIGN(3, iis_id);

            dbItem *item = [dbItem get:item_id];
            dbPlace *place = [dbPlace get:place_id];
            dbSet *set = [dbSet get:item.set_id];
            dbItemInPlace *iip = [dbItemInPlace get:iip_id];
            dbItemInSet *iis = [dbItemInSet get:iis_id];

            [ss addObject:@[item, place, set, iip, iis]];
        }
        DB_FINISH;
    }

    return ss;
}

+ (NSArray<NSArray *> *)newerItemsInPouch
{
    NSMutableArray *ss = [NSMutableArray arrayWithCapacity:20];

    NSString *sql = @"select i.id, iip.id, iis.id from sets s join items i on s.id = i.set_id join items_in_sets iis on i.id = iis.item_id join items_in_pouch iip on iis.item_id = iip.item_id where iip.number < iis.number";

    @synchronized(db) {
        DB_PREPARE(sql);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(0, item_id);
            INT_FETCH_AND_ASSIGN(1, iip_id);
            INT_FETCH_AND_ASSIGN(2, iis_id);

            dbItem *item = [dbItem get:item_id];
            dbSet *set = [dbSet get:item.set_id];
            dbItemInSet *iis = [dbItemInSet get:iis_id];
            dbItemInPouch *iip = [dbItemInPouch get:iip_id];

            [ss addObject:@[item, set, iip, iis]];
        }
        DB_FINISH;
    }

    return ss;
}

+ (NSArray<NSArray *> *)newItemsInPlaces
{
    NSMutableArray *ss = [NSMutableArray arrayWithCapacity:20];

    dbPlace *excludePlace = [dbPlace getByPlaceName:@"The WallaBee Museum"];

    NSString *sql = @"select i.id, p.id, iip.id from items_in_places iip join items i on i.id = iip.item_id join places p on p.id = iip.place_id where item_id not in (select item_id from items_in_sets) and iip.place_id != ?";

    @synchronized(db) {
        DB_PREPARE(sql);

        SET_VAR_INT(1, excludePlace._id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(0, item_id);
            INT_FETCH_AND_ASSIGN(1, place_id);
            INT_FETCH_AND_ASSIGN(2, iip_id);

            dbItem *item = [dbItem get:item_id];
            dbPlace *place = [dbPlace get:place_id];
            dbSet *set = [dbSet get:item.set_id];
            dbItemInPlace *iip = [dbItemInPlace get:iip_id];

            [ss addObject:@[item, place, set, iip]];
        }
        DB_FINISH;
    }
    
    return ss;
}

+ (NSArray<NSArray *> *)itemsOnWishlist
{
    NSMutableArray *ss = [NSMutableArray arrayWithCapacity:20];

    dbPlace *excludePlace = [dbPlace getByPlaceName:@"The WallaBee Museum"];

    NSString *sql = @"select w.item_id, iip.id from items_in_places iip join wishlist w on iip.item_id = w.item_id where iip.place_id != ?";

    @synchronized(db) {
        DB_PREPARE(sql);

        SET_VAR_INT(1, excludePlace._id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(0, item_id);
            INT_FETCH_AND_ASSIGN(1, iip_id);

            dbItem *item = [dbItem get:item_id];
            dbSet *set = [dbSet get:item.set_id];
            dbItemInPlace *iip = [dbItemInPlace get:iip_id];
            dbPlace *place = [dbPlace get:iip.place_id];

            [ss addObject:@[item, set, iip, place]];
        }
        DB_FINISH;
    }
    
    return ss;
}

+ (NSDictionary *)itemsNeededForMixing
{
    NSArray<dbItem *> *itemsNotInASetYet = [dbItem allNotInASetButWithFormula];
    NSMutableDictionary *allItemsNeeded = [NSMutableDictionary dictionaryWithCapacity:100];

    [itemsNotInASetYet enumerateObjectsUsingBlock:^(dbItem * _Nonnull forItem, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:forItem];
        NSMutableArray *stuffNeeded = [NSMutableArray arrayWithCapacity:2];
        [stuffNeeded addObject:forItem];
        dbSet *set = [dbSet get:forItem.set_id];
        [stuffNeeded addObject:set];
        [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
            [stuffNeeded addObject:formula];
            dbItem *item = [dbItem get:formula.source_id];
            dbItemInPouch *iipo = [dbItemInPouch getByItem:item];
            if (iipo != nil) {
                [stuffNeeded addObject:iipo];
                return;
            }
            NSArray<dbItemInPlace *> *iipls = [dbItemInPlace findThisItem:item];
            [iipls enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull iipl, NSUInteger idx, BOOL * _Nonnull stop) {
                [stuffNeeded addObject:iipl];
            }];
        }];

        [allItemsNeeded setValue:stuffNeeded forKey:[[NSNumber numberWithInteger:forItem._id] stringValue]];
    }];

    return allItemsNeeded;
}

@end
