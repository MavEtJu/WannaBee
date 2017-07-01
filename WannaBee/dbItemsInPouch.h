//
//  dbPouch.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbItemInPouch : dbObject

@property (nonatomic) NSId item_id;
@property (nonatomic) NSInteger number;

+ (NSArray<dbItemInPouch *> *)all;
+ (NSArray<dbItemInPouch *> *)allByItem:(dbItem *)item;
+ (dbItemInPouch *)get:(NSId)_id;
+ (dbItemInPouch *)getByItem:(dbItem *)item;
+ (void)deleteAll;

@end
