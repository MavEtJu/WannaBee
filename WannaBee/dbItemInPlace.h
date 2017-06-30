//
//  dbItemInPlace.h
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbItemInPlace : dbObject

@property (nonatomic) NSId place_id;
@property (nonatomic) NSId item_id;
@property (nonatomic) NSInteger number;

+ (NSArray<dbItemInPlace *> *)allItemsInPlace:(dbPlace *)place;
+ (NSArray<dbItemInPlace *> *)findThisItem:(dbItem *)item;
+ (dbItemInPlace *)getByItemId:(dbItem *)item place:(dbPlace *)place;
+ (dbItemInPlace *)get:(NSId)_id;
+ (void)deleteByPlace:(dbPlace *)place;
+ (void)deleteAll;

@end
