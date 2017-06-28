//
//  dbObject.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbObject

- (void)create
{
    NSAssert(NO, @"Should be overridden");
}

+ (void)deleteAll:(NSString *)table
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@", table];
    @synchronized(db) {
        DB_PREPARE(sql);

        DB_CHECK_OKAY;
        DB_FINISH;
    } 
}

@end
