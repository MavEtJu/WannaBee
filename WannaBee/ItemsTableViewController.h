//
//  ItemTableViewController.h
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

typedef NS_ENUM(NSInteger, ItemsTableType) {
    TYPE_UNKNOWN = 0,
    TYPE_POUCH,
    TYPE_PLACE,
    TYPE_SET,
    TYPE_NEWER,
    TYPE_MIXING,
};

@interface ItemsTableViewController : WBTableViewController

@property (nonatomic) ItemsTableType type;
@property (nonatomic, retain) dbPlace *place;

- (NSArray<NSObject *> *)itemsForSection:(NSInteger)section;
- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section;

@end
