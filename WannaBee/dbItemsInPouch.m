//
//  dbPouch.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbItemInPouch

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into items_in_pouch(item_id, number) values(?, ?)");

        SET_VAR_INT (1, self.item_id);
        SET_VAR_INT (2, self.number);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

+ (NSArray<dbItemInPouch *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbItemInPouch *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, item_id, number from items_in_pouch "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbItemInPouch *c = [[dbItemInPouch alloc] init];
            INT_FETCH (0, c._id);
            INT_FETCH (1, c.item_id);
            INT_FETCH (2, c.number);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbItemInPouch *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbItemInPouch *> *)allByItem:(dbItem *)item
{
    return [self dbAllXXX:@"where item_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:item._id]]];
}

+ (dbItemInPouch *)get:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbItemInPouch *)getByItem:(dbItem *)item
{
    return [[self dbAllXXX:@"where item_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:item._id]]] firstObject];
}

+ (void)deleteAll
{
    [self deleteAll:@"items_in_pouch"];
}

@end
