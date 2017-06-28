//
//  dbItem.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbItem : dbObject

@property (nonatomic) NSInteger item_type_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) NSId set_id;

+ (NSArray<dbItem *> *)all;
+ (NSArray<dbItem *> *)allInSet:(dbSet *)set;
+ (dbItem *)getByItemTypeId:(NSInteger)item_type_id;
+ (dbItem *)get:(NSId)_id;

@end
