//
//  dbItemInPlace.m
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbItemInPlace

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into items_in_places(item_id, place_id, number) values(?, ?, ?)");

        SET_VAR_INT (1, self.item_id);
        SET_VAR_INT (2, self.place_id);
        SET_VAR_INT (3, self.number);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

+ (NSArray<dbItemInPlace *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbItemInPlace *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, item_id, place_id, number from items_in_places "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbItemInPlace *c = [[dbItemInPlace alloc] init];
            INT_FETCH (0, c._id);
            INT_FETCH (1, c.item_id);
            INT_FETCH (2, c.place_id);
            INT_FETCH (3, c.number);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbItemInPlace *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbItemInPlace *> *)allItemsInPlace:(dbPlace *)place
{
    return [self dbAllXXX:@"where place_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:place._id]]];
}

+ (dbItemInPlace *)get:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbItemInPlace *)getByItemId:(dbItem *)item place:(dbPlace *)place
{
    return [[self dbAllXXX:@"where item_id = ? and place_id = ?" keys:@"ii" values:@[[NSNumber numberWithInteger:item._id], [NSNumber numberWithInteger:place._id]]] firstObject];
}

+ (void)deleteAll
{
    [self deleteAll:@"items_in_places"];
}

+ (void)deleteByPlace:(NSId)place_id
{
    @synchronized(db) {
        DB_PREPARE(@"delete from items_in_places where place_id = ?");

        SET_VAR_INT (1, place_id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
