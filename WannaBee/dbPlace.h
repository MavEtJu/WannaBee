//
//  dbPlace.h
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbPlace : dbObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) NSInteger place_id;
@property (nonatomic) NSInteger radius;
@property (nonatomic) CLLocationDegrees lat;
@property (nonatomic) CLLocationDegrees lon;

+ (dbPlace *)get:(NSId)_id;
+ (dbPlace *)getByPlaceId:(NSInteger)place_id;
+ (dbPlace *)getByPlaceName:(NSString *)place_name;
+ (NSArray<dbPlace *> *)all;
+ (void)deleteAll;

@end
