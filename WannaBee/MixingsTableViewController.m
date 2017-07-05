//
//  MixingsTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 1/7/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface MixingsTableViewController ()

@property (nonatomic, retain) NSMutableArray *itemsReady;
@property (nonatomic, retain) NSMutableArray *itemsPossible;
@property (nonatomic, retain) NSMutableArray *itemsNope;

@end

@implementation MixingsTableViewController

enum {
    SECTION_MIXINGS_READY = 0,
    SECTION_MIXINGS_POSSIBLE,
    SECTION_MIXINGS_NOPE,
    SECTION_MAX,
};

#define CELL_ITEM   @"mixingcells"

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;

    [self refreshInit];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ITEM];

    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshData];
    [super viewDidAppear:animated];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading set data"];
    [self refreshData];
    [self refreshStop];
}

- (void)refreshData
{
    [mixManager refreshMixData];

    self.itemsReady = [NSMutableArray arrayWithCapacity:1];
    self.itemsPossible = [NSMutableArray arrayWithCapacity:1];
    self.itemsNope = [NSMutableArray arrayWithCapacity:1];

    [mixManager.itemsMixable enumerateObjectsUsingBlock:^(dbItem * _Nonnull itemNeeded, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL foundAllitems = YES;
        __block BOOL foundNoItems = YES;
        [[dbFormula allNeededForItem:itemNeeded] enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull ostop) {
            __block BOOL found = NO;
            [mixManager.itemsInPouch enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                if (item._id == formula.source_id) {
                    found = YES;
                    foundNoItems = NO;
                    *stop = YES;
                }
            }];
            [mixManager.itemsInPlaces enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                if (item._id == formula.source_id) {
                    found = YES;
                    foundNoItems = NO;
                    *stop = YES;
                }
            }];
            if (found == NO)
                foundAllitems = NO;
        }];

        if (foundAllitems == YES)
            [self.itemsReady addObject:itemNeeded];
        else if (foundNoItems == NO)
            [self.itemsPossible addObject:itemNeeded];
        else
            [self.itemsNope addObject:itemNeeded];
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXINGS_READY:
            return [NSString stringWithFormat:@"Ready (%d items)", [self.itemsReady count]];
        case SECTION_MIXINGS_POSSIBLE:
            return [NSString stringWithFormat:@"Partly (%d items)", [self.itemsPossible count]];
        case SECTION_MIXINGS_NOPE:
            return [NSString stringWithFormat:@"None (%d items)", [self.itemsNope count]];
    }
    return @"???";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXINGS_READY:
            return [self.itemsReady count];
        case SECTION_MIXINGS_POSSIBLE:
            return [self.itemsPossible count];
        case SECTION_MIXINGS_NOPE:
            return [self.itemsNope count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    dbItem *item;
    switch (indexPath.section) {
        case SECTION_MIXINGS_READY:
            item = [self.itemsReady objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_POSSIBLE:
            item = [self.itemsPossible objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_NOPE:
            item = [self.itemsNope objectAtIndex:indexPath.row];
            break;
    }

    dbSet *set = [dbSet get:item.set_id];
    __block NSMutableArray<dbItemInPouch *> *iipos = [NSMutableArray arrayWithCapacity:1];
    __block NSMutableArray<dbItemInPlace *> *iipls = [NSMutableArray arrayWithCapacity:1];
    NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:item];
    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
        [[dbItemInPouch allByItem:[dbItem get:formula.source_id]] enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [iipos addObject:obj];
        }];
        [[dbItemInPlace findThisItem:[dbItem get:formula.source_id]] enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [iipls addObject:obj];
        }];
    }];
    
    cell.itemName.text = @"";
    cell.setName.text = @"";
    cell.placeName.text = @"";
    cell.numbers.text = @"";
    cell.mixing.text = @"";

    cell.itemName.text = item.name;
    cell.image.image = [imageManager url:item.imgurl];
    cell.setName.text = set.name;
    cell.backgroundColor = [UIColor clearColor];

    NSMutableString *numbers = [NSMutableString string];

    [numbers appendString:@"\nRequired:"];
    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:formula.source_id];
        dbSet *s = [dbSet get:item.set_id];
        [numbers appendFormat:@"\n%@ (%@)", i.name, s.name];
    }];

    if ([iipos count] != 0) {
        [numbers appendString:@"\n\nPouch:"];
        [iipos enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull iipo, NSUInteger idx, BOOL * _Nonnull stop) {
            dbItem *i = [dbItem get:iipo.item_id];
            dbSet *s = [dbSet get:item.set_id];
            [numbers appendFormat:@"\n%@ (%@)", i.name, s.name];
        }];
    }

    if ([iipls count] != 0) {
        [numbers appendString:@"\n\nPlaces:"];
        [iipls enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull iipl, NSUInteger idx, BOOL * _Nonnull stop) {
            dbItem *i = [dbItem get:iipl.item_id];
            dbPlace *p = [dbPlace get:iipl.place_id];
            [numbers appendFormat:@"\n%@ (%@)", i.name, p.name];
        }];
    }
    cell.mixing.text = numbers;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbItem *item = nil;
    switch (indexPath.section) {
        case SECTION_MIXINGS_READY:
            item = [self.itemsReady objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_POSSIBLE:
            item = [self.itemsPossible objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_NOPE:
            item = [self.itemsNope objectAtIndex:indexPath.row];
            break;
    }

    MixingTableViewController *newController = [[MixingTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [newController showItem:item];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = item.name;
    [self.navigationController pushViewController:newController animated:YES];
}

@end
