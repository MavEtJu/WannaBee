//
//  MixingTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 1/7/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface MixingTableViewController ()

@property (nonatomic, retain) NSArray *mainItem;
@property (nonatomic, retain) NSArray *itemsRequired;
@property (nonatomic, retain) NSArray *itemsAvailable;
@property (nonatomic, retain) NSArray *itemsMissing;

@end

@implementation MixingTableViewController

enum {
    SECTION_HEADER = 0,
    SECTION_REQUIRED,
    SECTION_AVAILABLE,
    SECTION_NOTAVAILABLE,
    SECTION_MAX,
};

#define CELL_ITEM   @"MixingItemCell"
#define CELL_HEADER @"MixingHeaderCell"

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Pouch";
    self.type = TYPE_MIXING;

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_HEADER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ITEM];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_HEADER:
            return @"Item to create";
        case SECTION_REQUIRED:
            return @"Required";
        case SECTION_AVAILABLE:
            return @"Available";
        case SECTION_NOTAVAILABLE:
            return @"Missing";
    }
    return @"";
}

- (NSArray<NSObject *> *)itemsForSection:(NSInteger)section
{
    switch (section) {
        case SECTION_REQUIRED:
            return self.itemsRequired;
        case SECTION_AVAILABLE:
            return self.itemsAvailable;
        case SECTION_NOTAVAILABLE:
            return self.itemsMissing;
        case SECTION_HEADER:
            return self.mainItem;
    }

    return nil;
}

- (void)showItem:(dbItem *)item
{
    NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:item];

    NSMutableArray *req = [NSMutableArray arrayWithCapacity:[formulas count]];
    NSMutableArray *notfound = [NSMutableArray arrayWithCapacity:[formulas count]];
    NSMutableArray *found = [NSMutableArray arrayWithCapacity:[formulas count]];

    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *item = [dbItem get:f.source_id];
        [req addObject:item];

        [[dbItemInPouch allByItem:item] enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [found addObject:obj];
            f.found = YES;
        }];
        [[dbItemInPlace findThisItem:item] enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [found addObject:obj];
            f.found = YES;
        }];

        if (f.found == NO)
            [notfound addObject:item];
    }];

    self.itemsRequired = req;
    self.itemsAvailable = found;
    self.itemsMissing = notfound;
    self.mainItem = @[item];
}

@end
