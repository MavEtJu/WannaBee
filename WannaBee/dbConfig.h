//
//  dbConfig.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbConfig : dbObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

+ (NSArray<dbConfig *> *)all;
+ (dbConfig *)getByKey:(NSString *)key;
- (void)update;

@end
