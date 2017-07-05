//
//  MixManager.h
//  WannaBee
//
//  Created by Edwin Groothuis on 3/7/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface MixManager : NSObject

@property (nonatomic, retain) NSMutableArray<dbItem *> *itemsNeeded;
@property (nonatomic, retain) NSMutableArray<dbItem *> *itemsMixable;
@property (nonatomic, retain) NSMutableArray<dbItem *> *itemsNeededForMixing;

@property (nonatomic, retain) NSArray<dbItem *> *itemsInPouch;
@property (nonatomic, retain) NSArray<dbItem *> *itemsInPlaces;

- (void)refreshMixData;
- (UITableViewCell *)cellForFormula:(dbItem *)item;

- (BOOL)isItemNeeded:(dbItem *)item;
- (BOOL)isItemMixable:(dbItem *)item;
- (BOOL)isItemNeededForMixing:(dbItem *)item;

@end

extern MixManager *mixManager;
