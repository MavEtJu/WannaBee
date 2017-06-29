//
//  dbItemInSet.h
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbItemInSet : dbObject

@property (nonatomic) NSId item_id;
@property (nonatomic) NSInteger number;

+ (dbItemInSet *)getByItemId:(dbItem *)item;
+ (dbItemInSet *)get:(NSId)_id;

@end
