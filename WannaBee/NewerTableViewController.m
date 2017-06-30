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

@property (nonatomic, retain) UIColor *tooFarColour;
@property (nonatomic, retain) UIColor *reachableColour;;

@end

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_ITEMSONWISHLIST = 0,
    SECTION_NEWITEMSINPLACES,
    SECTION_NEWERITEMSINPLACES,
    SECTION_NEWERITEMSINPOUCH,
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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ITEM];

    [self refreshInit];
    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshData];
    [super viewDidAppear:animated];
}

- (void)refreshData
{
    self.newerItemsInPlaces = [database newerItemsInPlaces];
    self.newerItemsInPouch = [database newerItemsInPouch];
    self.unseenItemsInPlaces = [database newItemsInPlaces];
    self.itemsOnWishlist = [database itemsOnWishlist];

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
    }

    NSArray *as = (NSArray *)o;

    __block dbItem *item = nil;
    __block dbSet *set = nil;
    __block dbPlace *place = nil;
    __block dbItemInSet *iis = nil;
    __block dbItemInPlace *iipl = nil;
    __block dbItemInPouch *iipo = nil;

    [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a isKindOfClass:[dbItem class]] == YES)
            item = (dbItem *)a;
        if ([a isKindOfClass:[dbSet class]] == YES) {
            set = (dbSet *)a;
            set.needs_refresh = YES;
            [set dbUpdateNeedsRefresh];
        }
        if ([a isKindOfClass:[dbPlace class]] == YES)
            place = (dbPlace *)a;
        if ([a isKindOfClass:[dbItemInSet class]] == YES)
            iis = (dbItemInSet *)a;
        if ([a isKindOfClass:[dbItemInPlace class]] == YES)
            iipl = (dbItemInPlace *)a;
        if ([a isKindOfClass:[dbItemInPouch class]] == YES)
            iipo = (dbItemInPouch *)a;
    }];

    cell.itemName.text = @"";
    cell.setName.text = @"";
    cell.placeName.text = @"";
    cell.numbers.text = @"";

    cell.itemName.textColor = self.reachableColour;
    cell.setName.textColor = self.reachableColour;
    cell.placeName.textColor = self.reachableColour;
    cell.numbers.textColor = self.reachableColour;

    if (indexPath.section == SECTION_NEWITEMSINPLACES ||
        indexPath.section == SECTION_NEWERITEMSINPLACES ||
        indexPath.section == SECTION_ITEMSONWISHLIST) {
        if ([place canReach] == NO) {
            cell.itemName.textColor = self.tooFarColour;
            cell.setName.textColor = self.tooFarColour;
            cell.placeName.textColor = self.tooFarColour;
            cell.numbers.textColor = self.tooFarColour;
        }
    }

    cell.itemName.text = item.name;
    cell.image.image = [imageManager url:item.imgurl];
    cell.setName.text = set.name;
    switch (indexPath.section) {
        case SECTION_NEWERITEMSINPOUCH:
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d in pouch, #%d in set", iipo.number, iis.number];
            break;
        case SECTION_NEWERITEMSINPLACES:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d in place, #%d in set", iipl.number, iis.number];
            break;
        case SECTION_NEWITEMSINPLACES:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d", iipl.number];
            break;
        case SECTION_ITEMSONWISHLIST:
            cell.placeName.text = place.name;
            cell.numbers.text = [NSString stringWithFormat:@"Found #%d", iipl.number];
            break;
    }

    return cell;
}

@end
