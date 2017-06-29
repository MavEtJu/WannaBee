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

@end

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_NEWITEMSINPLACES = 0,
    SECTION_NEWERITEMSINPLACES,
    SECTION_NEWERITEMSINPOUCH,
    SECTION_ITEMSONWISHLIST,
    SECTION_MAX,
};

@implementation NewerTableViewController

#define CELL_ITEM   @"CELL_ITEM"

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_ITEM];

    [self refreshData];
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
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
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

    cell.textLabel.text = @"-";
    cell.detailTextLabel.text = @"";

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
        if ([a isKindOfClass:[dbSet class]] == YES)
            set = (dbSet *)a;
        if ([a isKindOfClass:[dbPlace class]] == YES)
            place = (dbPlace *)a;
        if ([a isKindOfClass:[dbItemInSet class]] == YES)
            iis = (dbItemInSet *)a;
        if ([a isKindOfClass:[dbItemInPlace class]] == YES)
            iipl = (dbItemInPlace *)a;
        if ([a isKindOfClass:[dbItemInPouch class]] == YES)
            iipo = (dbItemInPouch *)a;
    }];

    switch (indexPath.section) {
        case SECTION_NEWERITEMSINPOUCH:
            cell.textLabel.text = [NSString stringWithFormat:@"%@", item.name];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d which is smaller than #%d", iipo.number, iis.number];
            break;
        case SECTION_NEWERITEMSINPLACES:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item.name, place.name];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d which is smaller than #%d", iipl.number, iis.number];
            break;
        case SECTION_NEWITEMSINPLACES:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item.name, place.name];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d", iipl.number];
            break;
        case SECTION_ITEMSONWISHLIST:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item.name, set.name];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d at %@", iipl.number, place.name];
            break;
    }

    return cell;
}

@end
