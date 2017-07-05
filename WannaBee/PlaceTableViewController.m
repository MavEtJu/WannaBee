//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlaceTableViewController ()

@property (nonatomic, retain) NSArray *itemsNeededInSet;
@property (nonatomic, retain) NSArray *itemsNeededInMix;
@property (nonatomic, retain) NSArray *itemsOthers;

@end

@implementation PlaceTableViewController

enum {
    SECTION_NEEDEDINSET = 0,
    SECTION_NEEDEDINMIX,
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
        case SECTION_NEEDEDINSET:
            return self.itemsNeededInSet;
        case SECTION_NEEDEDINMIX:
            return self.itemsNeededInMix;
        case SECTION_OTHERS:
            return self.itemsOthers;
    }
    return nil;
}

- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section
{
    switch (section) {
        case SECTION_NEEDEDINMIX:
            self.itemsNeededInMix = items;
            break;
        case SECTION_NEEDEDINSET:
            self.itemsNeededInSet = items;
            break;
        case SECTION_OTHERS:
            self.itemsOthers = items;
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
        case SECTION_NEEDEDINSET:
            return @"Needed in sets";
        case SECTION_NEEDEDINMIX:
            return @"Needed in mix";
        case SECTION_OTHERS:
            return @"Others";
    }
    return @"";
}

- (void)refreshData
{
    NSArray<dbItemInPlace *> *iips = [dbItemInPlace allItemsInPlace:self.place];
    NSMutableArray<dbItemInPlace *> *m = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPlace *> *s = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPlace *> *o = [NSMutableArray arrayWithCapacity:[iips count]];
    [iips enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull iip, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:iip.item_id];
        if ([mixManager isItemNeeded:i] == YES)
            [s addObject:iip];
        else if ([mixManager isItemNeededForMixing:i] == YES)
            [m addObject:iip];
        else
            [o addObject:iip];
    }];
    self.itemsOthers = o;
    self.itemsNeededInSet = s;
    self.itemsNeededInMix = m;
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
