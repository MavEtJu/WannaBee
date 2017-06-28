//
//  dbConfig.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbConfig

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into config(key, value) values(?, ?)");

        SET_VAR_TEXT(1, self.key);
        SET_VAR_TEXT(2, self.value);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

- (void)update
{
    @synchronized(db) {
        DB_PREPARE(@"update config set value = ? where key = ?");

        SET_VAR_TEXT(1, self.value);
        SET_VAR_TEXT(2, self.key);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbConfig *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbConfig *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, key, value from config "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbConfig *c = [[dbConfig alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.key);
            TEXT_FETCH(2, c.value);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbConfig *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbConfig *)getByKey:(NSString *)key
{
    return [[self dbAllXXX:@"where key = ?" keys:@"s" values:@[key]] firstObject];
}

@end
