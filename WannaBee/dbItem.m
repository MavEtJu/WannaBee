//
//  dbItem.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%d)", self.name, self.item_type_id];
}

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into items(item_type_id, name, set_id, imgurl) values(?, ?, ?, ?)");

        SET_VAR_INT (1, self.item_type_id);
        SET_VAR_TEXT(2, self.name);
        SET_VAR_INT (3, self.set_id);
        SET_VAR_TEXT(4, self.imgurl);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

- (void)update
{
    @synchronized(db) {
        DB_PREPARE(@"update items set item_type_id = ?, name = ?, set_id =?, imgurl = ? where id = ?");

        SET_VAR_INT (1, self.item_type_id);
        SET_VAR_TEXT(2, self.name);
        SET_VAR_INT (3, self.set_id);
        SET_VAR_TEXT(4, self.imgurl);
        SET_VAR_INT (5, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbItem *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbItem *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, item_type_id, name, set_id, imgurl from items "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbItem *c = [[dbItem alloc] init];
            INT_FETCH (0, c._id);
            INT_FETCH (1, c.item_type_id);
            TEXT_FETCH(2, c.name);
            INT_FETCH (3, c.set_id);
            TEXT_FETCH(4, c.imgurl);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbItem *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbItem *> *)allInSet:(dbSet *)set
{
    return [self dbAllXXX:@"where set_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:set._id]]];
}

+ (NSArray<dbItem *> *)allNotInASet
{
    return [self dbAllXXX:@"where id not in (select item_id from items_in_sets)" keys:nil values:nil];
}

+ (NSArray<dbItem *> *)allNotInASetButWithFormula
{
    return [self dbAllXXX:@"where id not in (select item_id from items_in_sets) and id in (select item_id from formulas)" keys:nil values:nil];
}

+ (NSArray<dbItem *> *)allInSetStored:(dbSet *)set
{
    return [self dbAllXXX:@"where set_id = ? and id in (select item_id from items_in_sets where set_id = ?)" keys:@"ii" values:@[[NSNumber numberWithInteger:set._id], [NSNumber numberWithInteger:set._id]]];
}

+ (NSArray<dbItem *> *)allInPouch
{
    return [self dbAllXXX:@"where id in (select item_id from items_in_pouch)" keys:nil values:nil];
}

+ (NSArray<dbItem *> *)allInPlace:(dbPlace *)place
{
    return [self dbAllXXX:@"where id in (select item_id from items_in_places where place_id = ?)" keys:@"i" values:@[[NSNumber numberWithInteger:place._id]]];
}

+ (NSArray<dbItem *> *)allInPlaces
{
    return [self dbAllXXX:@"where id in (select item_id from items_in_places)" keys:nil values:nil];
}

+ (dbItem *)get:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbItem *)getByItemTypeId:(NSInteger)item_type_id
{
    return [[self dbAllXXX:@"where item_type_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:item_type_id]]] firstObject];
}

@end
