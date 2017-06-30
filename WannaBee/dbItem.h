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
@property (nonatomic, retain) NSString *imgurl;

- (void)update;
+ (NSArray<dbItem *> *)all;
+ (NSArray<dbItem *> *)allInSet:(dbSet *)set;
+ (NSArray<dbItem *> *)allNotInASetButWithFormula;
+ (NSArray<dbItem *> *)allInSetStored:(dbSet *)set;
+ (NSArray<dbItem *> *)allInPouch;
+ (NSArray<dbItem *> *)allInPlace:(dbPlace *)place;
+ (dbItem *)getByItemTypeId:(NSInteger)item_type_id;
+ (dbItem *)get:(NSId)_id;

@end
