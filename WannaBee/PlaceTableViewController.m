//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlaceTableViewController ()

@property (nonatomic, retain) NSArray *mixableItems;
@property (nonatomic, retain) NSArray *otherItems;

@end

@implementation PlaceTableViewController

enum {
    SECTION_MIXABLE = 0,
    SECTION_OTHERS,
    SECTION_MAX,
};

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.type = TYPE_PLACE;
    [self refreshInit];

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;
    
    return self;
}

- (NSArray<NSObject *> *)itemsForSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            return self.mixableItems;
        case SECTION_OTHERS:
            return self.otherItems;
    }
    return nil;
}

- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            self.mixableItems = items;
            break;
        case SECTION_OTHERS:
            self.otherItems = items;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            return @"Mixable items";
        case SECTION_OTHERS:
            return @"Other items";
    }
    return @"";
}

- (void)refreshData
{
    NSArray<dbItemInPlace *> *iips = [dbItemInPlace allItemsInPlace:self.place];
    NSMutableArray<dbItemInPlace *> *m = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPlace *> *o = [NSMutableArray arrayWithCapacity:[iips count]];
    [iips enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull iip, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:iip.item_id];
        if ([dbFormula isSourceObject:i] == YES)
            [m addObject:iip];
        else
            [o addObject:iip];
    }];
    self.mixableItems = m;
    self.otherItems = o;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading place data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [dbItemInPlace deleteByPlace:self.place];
    [api api_places__items:self.place.place_id];
    [self refreshData];
    [self refreshStop];
}

- (void)showPlace:(dbPlace *)place
{
    self.place = place;
    [self refreshData];
}

@end
