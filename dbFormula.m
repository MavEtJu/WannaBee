//
//  dbFormula.m
//  WannaBee
//
//  Created by Edwin Groothuis on 30/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbFormula

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into formulas(item_id, source_number, source_id, formula) values(?, ?, ?, ?)");

        SET_VAR_INT (1, self.item_id);
        SET_VAR_INT (2, self.source_number);
        SET_VAR_INT (3, self.source_id);
        SET_VAR_INT (4, self.number);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

- (void)updateSource
{
    @synchronized(db) {
        DB_PREPARE(@"update formulas set source_id = ? where id = ?");

        SET_VAR_INT (1, self.source_id);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbFormula *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbFormula *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, item_id, source_id, source_number, formula from formulas "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbFormula *c = [[dbFormula alloc] init];
            INT_FETCH (0, c._id);
            INT_FETCH (1, c.item_id);
            INT_FETCH (2, c.source_id);
            INT_FETCH (3, c.source_number);
            INT_FETCH (4, c.number);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbFormula *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbFormula *> *)allByNoSource
{
    return [self dbAllXXX:@"where source_id = 0" keys:nil values:nil];
}

+ (NSArray<dbFormula *> *)allNeededForItem:(dbItem *)item
{
    return [self dbAllXXX:@"where item_id = ? and formula = 0" keys:@"i" values:@[[NSNumber numberWithInteger:item._id]]];
}

+ (void)deleteByItem:(dbItem *)item
{
    @synchronized (db) {
        DB_PREPARE(@"delete from formulas where item_id = ?");

        SET_VAR_INT(1, item._id);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)fixSource
{
    NSArray<dbFormula *> *formulas = [self allByNoSource];
    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem getByItemTypeId:formula.source_number];
        if (i == nil)
            return;
        formula.source_id = i._id;
        [formula updateSource];
    }];
}

+ (BOOL)isSourceObject:(dbItem *)item
{
    NSArray<dbFormula *> *formulas = [self dbAllXXX:@"where source_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:item._id]]];
    return ([formulas count] != 0);
}

@end
