//
//  dbSet.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbSet

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into sets(set_name, set_id, items_in_set, needs_refresh, imgurl) values(?, ?, ?, ?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self.set_id);
        SET_VAR_INT (3, self.items_in_set);
        SET_VAR_BOOL(4, self.needs_refresh);
        SET_VAR_TEXT(5, self.imgurl);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

- (void)update
{
    @synchronized(db) {
        DB_PREPARE(@"update sets set set_name = ?, set_id = ?, items_in_set = ?, needs_refresh = ?, imgurl = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self.set_id);
        SET_VAR_INT (3, self.items_in_set);
        SET_VAR_BOOL(4, self.needs_refresh);
        SET_VAR_TEXT(5, self.imgurl);
        SET_VAR_INT (6, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateNeedsRefresh
{
    @synchronized(db) {
        DB_PREPARE(@"update sets set needs_refresh = ? where id = ?");

        SET_VAR_INT (1, self.needs_refresh);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbSet *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbSet *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, set_name, set_id, items_in_set, needs_refresh, imgurl from sets "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbSet *c = [[dbSet alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.name);
            INT_FETCH (2, c.set_id);
            INT_FETCH (3, c.items_in_set);
            BOOL_FETCH(4, c.needs_refresh);
            TEXT_FETCH(5, c.imgurl);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbSet *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbSet *)get:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbSet *)getBySetId:(NSInteger)set_id
{
    return [[self dbAllXXX:@"where set_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:set_id]]] firstObject];
}

+ (dbSet *)getBySetName:(NSString *)name
{
    return [[self dbAllXXX:@"where set_name = ?" keys:@"s" values:@[name]] firstObject];
}

@end
