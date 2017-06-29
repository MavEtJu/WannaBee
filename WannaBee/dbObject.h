//
//  dbObject.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbObject : NSObject

@property (nonatomic) NSId _id;

- (void)create;

+ (void)deleteAll:(NSString *)table;
- (void)delete:(NSString *)table;

@end
