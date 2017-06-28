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
+ (dbItemInPouch *)get:(NSId)_id;
+ (void)deleteAll;

@end
