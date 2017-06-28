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

+ (dbItemInPlace *)getByItemId:(NSId)item_id place_id:(NSId)place_id;
+ (dbItemInPlace *)get:(NSId)_id;
+ (void)deleteByPlace:(NSId)place_id;

@end
