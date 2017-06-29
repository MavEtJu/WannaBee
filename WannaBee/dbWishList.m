//
//  dbWishList.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbWishList

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into wishlist(item_id) values(?)");

        SET_VAR_INT (1, self.item_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

+ (NSArray<dbWishList *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbWishList *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, item_id from wishlist "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbWishList *c = [[dbWishList alloc] init];
            INT_FETCH (0, c._id);
            INT_FETCH (1, c.item_id);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbWishList *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbWishList *)get:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbWishList *)getByItem:(dbItem *)item
{
    return [[self dbAllXXX:@"where item_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:item._id]]] firstObject];
}

+ (void)deleteAll
{
    [self deleteAll:@"wishlist"];
}

- (void)_delete
{
    [self delete:@"wishlist"];
}


@end
