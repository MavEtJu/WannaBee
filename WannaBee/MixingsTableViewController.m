//
//  MixingsTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 1/7/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface MixingsTableViewController ()

@property (nonatomic, retain) NSArray *itemsReady;
@property (nonatomic, retain) NSArray *itemsPossible;
@property (nonatomic, retain) NSArray *itemsNope;

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
    NSArray<dbItem *> *allNeeded = [dbItem allNotInASet];
    NSMutableArray<dbItem *> *allMixable = [NSMutableArray arrayWithCapacity:[allNeeded count]];

    NSLog(@"Items needed: %d", [allNeeded count]);

    [allNeeded enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[dbFormula allNeededForItem:item] count] != 0)
            [allMixable addObject:item];
    }];

    NSLog(@"Items mixable: %d", [allMixable count]);

    NSMutableDictionary *seen = [NSMutableDictionary dictionaryWithCapacity:20];
    [allMixable enumerateObjectsUsingBlock:^(dbItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [self findSourcesForItem:item seen:seen];
    }];

    NSMutableArray *ready = [NSMutableArray arrayWithCapacity:[seen count]];
    NSMutableArray *possible = [NSMutableArray arrayWithCapacity:[seen count]];
    NSMutableArray *nope = [NSMutableArray arrayWithCapacity:[seen count]];
    [seen enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, dbItem * _Nonnull item, BOOL * _Nonnull stop) {
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:10];
        [objects addObject:item];

        NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:item];
        __block BOOL foundAll = YES;
        __block BOOL foundNone = YES;

        if ([formulas count] == 0)
            return;

        [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
            [objects addObject:formula];
            dbItem *i = [dbItem get:formula.source_id];
            NSArray<dbItemInPouch *> *iipos = [dbItemInPouch allByItem:i];
            [iipos enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [objects addObject:obj];
            }];
            NSArray<dbItemInPlace *> *iipls = [dbItemInPlace findThisItem:i];
            [iipls enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [objects addObject:obj];
            }];
            if ([iipos count] == 0 && [iipls count] == 0) {
                foundAll = NO;
            }
            if ([iipos count] + [iipls count] > 0) {
                foundNone = NO;
            }
        }];

        if (foundAll == YES)
            [ready addObject:objects];
        else if (foundNone == YES)
            [nope addObject:objects];
        else
            [possible addObject:objects];
    }];

    self.itemsReady = ready;;
    self.itemsPossible = possible;
    self.itemsNope = nope;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)findSourcesForItem:(dbItem *)item seen:(NSMutableDictionary *)seen
{
    if ([seen objectForKey:[NSNumber numberWithInteger:item._id]] != nil)
        return;

    NSLog(@"Searching for formula for %d '%@' (Depth: %d)", item._id, item.name, [seen count]);
    [seen setObject:item forKey:[NSNumber numberWithInteger:item._id]];

    NSArray<dbFormula *> *formulas = [dbFormula allNeededForItem:item];
    if ([formulas count] == 0) {
        NSLog(@"No formulas");
        return;
    }
    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull formula, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:formula.source_id];
        NSLog(@"Finding item for formula %d '%@'", i._id, i.name);

        NSArray<dbItemInPouch *> *iipo = [dbItemInPouch allByItem:i];
        NSArray<dbItemInPlace *> *iipl = [dbItemInPlace findThisItem:i];
        if ([iipo count] != 0) {
            NSLog(@"Found in pouch");
            return;
        }
        if ([iipl count] != 0) {
            NSLog(@"Found in places");
            return;
        }

        NSLog(@"Not found, finding formula for formula %d '%@'", i._id, i.name);
        [self findSourcesForItem:i seen:seen];
    }];

//    [seen removeObjectForKey:[NSNumber numberWithInteger:item._id]];
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
    NSObject *o;
    switch (indexPath.section) {
        case SECTION_MIXINGS_READY:
            o = [self.itemsReady objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_POSSIBLE:
            o = [self.itemsPossible objectAtIndex:indexPath.row];
            break;
        case SECTION_MIXINGS_NOPE:
            o = [self.itemsNope objectAtIndex:indexPath.row];
            break;
    }

    NSArray *as = (NSArray *)o;

    __block dbItem *item = nil;
    __block dbSet *set = nil;
    __block dbPlace *place = nil;
    __block dbItemInSet *iis = nil;
    __block dbItemInPlace *iipl = nil;
    __block dbItemInPouch *iipo = nil;
    NSMutableArray<dbItemInPouch *> *iipos = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<dbItemInPlace *> *iipls = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<dbFormula *> *formulas = [NSMutableArray arrayWithCapacity:2];


    if ([as isKindOfClass:[dbItem class]] == YES) {
        item = (dbItem *)as;
        set = [dbSet get:item.set_id];
    } else {
        [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([a isKindOfClass:[dbItem class]] == YES) {
                item = (dbItem *)a;
                set = [dbSet get:item.set_id];
            }
            if ([a isKindOfClass:[dbSet class]] == YES)
                set = (dbSet *)a;
            if ([a isKindOfClass:[dbPlace class]] == YES)
                place = (dbPlace *)a;
            if ([a isKindOfClass:[dbItemInSet class]] == YES)
                iis = (dbItemInSet *)a;
            if ([a isKindOfClass:[dbItemInPlace class]] == YES) {
                iipl = (dbItemInPlace *)a;
                [iipls addObject:iipl];
            }
            if ([a isKindOfClass:[dbItemInPouch class]] == YES) {
                iipo = (dbItemInPouch *)a;
                [iipos addObject:iipo];
            }
            if ([a isKindOfClass:[dbFormula class]] == YES) {
                dbFormula *f = (dbFormula *)a;
                [formulas addObject:f];
            }
        }];
    }

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
            dbSet *s = [dbSet get:item.set_id];
            [numbers appendFormat:@"\n%@ (%@)", i.name, p.name];
        }];
    }


    cell.mixing.text = numbers;

    return cell;
}

@end
