//
//  dbSet.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbSet : dbObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) NSInteger set_id;
@property (nonatomic) NSInteger items_in_set;
@property (nonatomic) BOOL needs_refresh;
@property (nonatomic, retain) NSString *imgurl;

- (void)dbUpdateNeedsRefresh;
+ (dbSet *)get:(NSId)_id;
+ (dbSet *)getBySetId:(NSInteger)set_id;
+ (dbSet *)getBySetName:(NSString *)name;
+ (NSArray<dbSet *> *)all;

@end
