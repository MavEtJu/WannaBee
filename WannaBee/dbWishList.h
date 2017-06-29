//
//  dbWishList.h
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface dbWishList : dbObject

@property (nonatomic) NSId item_id;

+ (dbWishList *)getByItem:(dbItem *)item;
- (void)_delete;

@end
