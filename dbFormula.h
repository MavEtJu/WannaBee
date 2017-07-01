//
//  dbFormula.h
//  WannaBee
//
//  Created by Edwin Groothuis on 30/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbFormula : dbObject

@property (nonatomic) NSId item_id;
@property (nonatomic) NSId source_id;
@property (nonatomic) NSInteger source_number;
@property (nonatomic) NSInteger number;

/* Not part of the table */
@property (nonatomic) BOOL found;

+ (void)deleteByItem:(dbItem *)item;
+ (void)fixSource;
+ (NSArray<dbFormula *> *)allNeededForItem:(dbItem *)item;
+ (BOOL)isSourceObject:(dbItem *)item;

@end
