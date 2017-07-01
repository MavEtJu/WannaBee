//
//  NewerItemsInPouchTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface NewerTableViewController ()

@property (nonatomic, retain) NSArray<NSObject *> *newerItemsInPlaces;
@property (nonatomic, retain) NSArray<NSObject *> *newerItemsInPouch;
@property (nonatomic, retain) NSArray<NSObject *> *unseenItemsInPlaces;
@property (nonatomic, retain) NSArray<NSObject *> *itemsOnWishlist;
@property (nonatomic, retain) NSDictionary *itemsNeededForMixing;
@property (nonatomic, retain) NSArray *itemsNeededForMixingItems;

@property (nonatomic, retain) UIColor *tooFarColour;
@property (nonatomic, retain) UIColor *reachableColour;;

@end

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_ITEMSONWISHLIST = 0,
    SECTION_NEWITEMSINPLACES,
    SECTION_NEWERITEMSINPLACES,
    SECTION_NEWERITEMSINPOUCH,
    SECTION_ITEMSNEEDEDFORMIXING,
    SECTION_MAX,
};

@implementation NewerTableViewController

#define CELL_ITEM   @"newercells"

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.tooFarColour = [UIColor lightGrayColor];
    self.reachableColour = [UIColor darkTextColor];

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByPlaceName = YES;
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
    self.newerItemsInPlaces = [database newerItemsInPlaces];
    self.newerItemsInPouch = [database newerItemsInPouch];
    self.unseenItemsInPlaces = [database newItemsInPlaces];
    self.itemsOnWishlist = [database itemsOnWishlist];

    self.itemsNeededForMixing = [database itemsNeededForMixing];
    NSMutableArray *found = [NSMutableArray arrayWithCapacity:[self.itemsNeededForMixing count]];
    NSMutableArray *notfound = [NSMutableArray arrayWithCapacity:[self.itemsNeededForMixing count]];
    [self.itemsNeededForMixing enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull number, NSArray *  _Nonnull as, BOOL * _Nonnull stop) {
        __block BOOL foundit = NO;
        [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull o, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([o isKindOfClass:[dbItemInPlace class]] == YES ||
                [o isKindOfClass:[dbItemInPouch class]] == YES) {
                [found addObject:number];
                foundit = YES;
                *stop = YES;
            }
        }];
        if (foundit == NO)
            [notfound addObject:number];
    }];
    [found addObjectsFromArray:notfound];
    self.itemsNeededForMixingItems = found;

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
        case SECTION_NEWITEMSINPLACES:
            return @"New Items in Places";
        case SECTION_NEWERITEMSINPLACES:
            return @"Newer Items in Places";
        case SECTION_NEWERITEMSINPOUCH:
            return @"Newer Items in Pouch";
        case SECTION_ITEMSONWISHLIST:
            return @"Wishlist";
        case SECTION_ITEMSNEEDEDFORMIXING:
            return @"Items Needed for Mixing";
    }
    return @"???";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_NEWITEMSINPLACES:
            return [self.unseenItemsInPlaces count];
        case SECTION_NEWERITEMSINPLACES:
            return [self.newerItemsInPlaces count];
        case SECTION_NEWERITEMSINPOUCH:
            return [self.newerItemsInPouch count];
        case SECTION_ITEMSONWISHLIST:
            return [self.itemsOnWishlist count];
        case SECTION_ITEMSNEEDEDFORMIXING:
            return [self.itemsNeededForMixing count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    NSObject *o;
    switch (indexPath.section) {
        case SECTION_NEWITEMSINPLACES:
            o = [self.unseenItemsInPlaces objectAtIndex:indexPath.row];
            break;
        case SECTION_NEWERITEMSINPLACES:
            o = [self.newerItemsInPlaces objectAtIndex:indexPath.row];
            break;
        case SECTION_NEWERITEMSINPOUCH:
            o = [self.newerItemsInPouch objectAtIndex:indexPath.row];
            break;
        case SECTION_ITEMSONWISHLIST:
            o = [self.itemsOnWishlist objectAtIndex:indexPath.row];
            break;
        case SECTION_ITEMSNEEDEDFORMIXING:
            o = [self.itemsNeededForMixing objectForKey:[self.itemsNeededForMixingItems objectAtIndex:indexPath.row]];
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

    [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a isKindOfClass:[dbItem class]] == YES)
            item = (dbItem *)a;
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

    cell.itemName.text = @"";
    cell.setName.text = @"";
    cell.placeName.text = @"";
    cell.numbers.text = @"";
    cell.mixing.text = @"";

    cell.itemName.textColor = self.reachableColour;
    cell.setName.textColor = self.reachableColour;
    cell.placeName.textColor = self.reachableColour;
    cell.numbers.textColor = self.reachableColour;
    cell.mixing.textColor = self.reachableColour;

    if (indexPath.section == SECTION_NEWITEMSINPLACES ||
        indexPath.section == SECTION_NEWERITEMSINPLACES ||
        indexPath.section == SECTION_ITEMSONWISHLIST ||
        indexPath.section == SECTION_ITEMSNEEDEDFORMIXING) {
        if ([place canReach] == NO) {
            cell.itemName.textColor = self.tooFarColour;
            cell.setName.textColor = self.tooFarColour;
            cell.placeName.textColor = self.tooFarColour;
            cell.numbers.textColor = self.tooFarColour;
            cell.mixing.textColor = self.tooFarColour;
        }
    }

    cell.itemName.text = item.name;
    cell.image.image = [imageManager url:item.imgurl];
    cell.setName.text = set.name;
    cell.backgroundColor = [UIColor clearColor];

    switch (indexPath.section) {
        case SECTION_NEWERITEMSINPOUCH:
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d in pouch, #%d in set", iipo.number, iis.number];
            if (set.needs_refresh == NO) {
                set.needs_refresh = YES;
                [set dbUpdateNeedsRefresh];
            }
            break;
        case SECTION_NEWERITEMSINPLACES:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d in place, #%d in set", iipl.number, iis.number];
            if (set.needs_refresh == NO) {
                set.needs_refresh = YES;
                [set dbUpdateNeedsRefresh];
            }
            break;
        case SECTION_NEWITEMSINPLACES:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d", iipl.number];
            if (set.needs_refresh == NO) {
                set.needs_refresh = YES;
                [set dbUpdateNeedsRefresh];
            }
            break;
        case SECTION_ITEMSONWISHLIST:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d", iipl.number];
            if (set.needs_refresh == NO) {
                set.needs_refresh = YES;
                [set dbUpdateNeedsRefresh];
            }
            break;
        case SECTION_ITEMSNEEDEDFORMIXING: {
            BOOL someFound = NO;
            NSMutableString *s = [NSMutableString string];
            if ([formulas count] != 0) {
                [s appendString:@"Required:"];
                [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
                    f.found = NO;
                    dbItem *i = [dbItem get:f.source_id];
                    dbSet *set = [dbSet get:i.set_id];
                    [s appendFormat:@"\n%@ (%@)", i.name, set.name];
                }];
            }
            if ([iipos count] != 0) {
                someFound = YES;
                [s appendString:@"\nPouch:"];
                [iipos enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull iipo, NSUInteger idx, BOOL * _Nonnull stop) {
                    dbItem *i = [dbItem get:iipo.item_id];
                    [s appendFormat:@"\n%@", i.name];
                    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (f.found == NO && f.source_id == i._id) {
                            f.found = YES;
                            *stop = YES;
                        }
                    }];
                }];
            }
            if ([iipls count] != 0) {
                someFound = YES;
                [s appendString:@"\nPlaces:"];
                [iipls enumerateObjectsUsingBlock:^(dbItemInPlace * _Nonnull iipl, NSUInteger idx, BOOL * _Nonnull stop) {
                    dbItem *i = [dbItem get:iipl.item_id];
                    dbPlace *p = [dbPlace get:iipl.place_id];
                    [s appendFormat:@"\n%@: %@", p.name, i.name];
                    [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (f.found == NO && f.source_id == i._id) {
                            f.found = YES;
                            *stop = YES;
                        }
                    }];
                }];
            }
            __block BOOL allFound = YES;
            [formulas enumerateObjectsUsingBlock:^(dbFormula * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
                if (f.found == NO) {
                    allFound = NO;
                    *stop = YES;
                }
            }];
            if (allFound == YES)
                cell.backgroundColor = [UIColor yellowColor];

            if (someFound == YES) {
                cell.itemName.textColor = self.reachableColour;
                cell.setName.textColor = self.reachableColour;
                cell.placeName.textColor = self.reachableColour;
                cell.numbers.textColor = self.reachableColour;
                cell.mixing.textColor = self.reachableColour;
            }

            cell.mixing.text = s;
            break;
        }
    }

    return cell;
}

@end
