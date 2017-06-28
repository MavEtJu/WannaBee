//
//  dbPlace.m
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbPlace

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into places(name, place_id) values(?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self.place_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

+ (NSArray<dbPlace *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbPlace *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, place_id from places "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbPlace *c = [[dbPlace alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.name);
            INT_FETCH (2, c.place_id);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbPlace *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbPlace *)get:(NSInteger)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbPlace *)getByPlaceId:(NSInteger)place_id
{
    return [[self dbAllXXX:@"where place_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:place_id]]] firstObject];
}

+ (dbPlace *)getByPlaceName:(NSString *)place_name;
{
    return [[self dbAllXXX:@"where name = ?" keys:@"s" values:@[place_name]] firstObject];
}

@end
