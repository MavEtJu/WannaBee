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

    sqlite3 *db;
    sqlite3_open([@"/Users/edwin/dev/wannabee/database.db" UTF8String], &db);
    NSAssert(db != nil, @"db");
    self.db = db;

    return self;
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

@end
