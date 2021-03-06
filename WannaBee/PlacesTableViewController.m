//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlacesTableViewController ()

@property (nonatomic, retain) NSArray<dbPlace *> *placesGlobal;
@property (nonatomic, retain) NSArray<dbPlace *> *placesLocal;
@property (nonatomic, retain) NSArray<dbPlace *> *placesTooFar;

@end

@implementation PlacesTableViewController

#define CELL_PLACE  @"PlacesCell"

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_GLOBAL = 0,
    SECTION_LOCAL,
    SECTION_TOOFAR,
    SECTION_MAX,
};

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.canSortByPlaceName = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_PLACE];
    [self refreshInit];
}

- (void)refreshData
{
    NSArray *places = [dbPlace all];
    NSMutableArray *global = [NSMutableArray arrayWithCapacity:[places count]];
    NSMutableArray *local = [NSMutableArray arrayWithCapacity:[places count]];
    NSMutableArray *toofar = [NSMutableArray arrayWithCapacity:[places count]];

    [[dbPlace all] enumerateObjectsUsingBlock:^(dbPlace * _Nonnull place, NSUInteger idx, BOOL * _Nonnull stop) {
        if (place.radius > 100000)  // 100km
            [global addObject:place];
        else if ([place canReach] == YES)
            [local addObject:place];
        else
            [toofar addObject:place];
    }];

    self.placesGlobal = global;
    self.placesLocal = local;
    self.placesTooFar = toofar;

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
    [dbPlace deleteAllExceptSafeplaces];
    [dbItemInPlace deleteAllExceptFromSafeplaces];
    [self refreshTitle:@"Obtaining places"];
    [api api_places:locationManager.last.latitude longitude:locationManager.last.longitude];

    NSArray<dbPlace *> *places = [dbPlace all];
    [places enumerateObjectsUsingBlock:^(dbPlace * _Nonnull place, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([place.name isEqualToString:@"The WallaBee Museum"] == YES)
            return;
        [self refreshTitle:[NSString stringWithFormat:@"Obtaining items for %@", place.name]];
        [dbItemInPlace deleteByPlace:place];
        [api api_places__items:place.place_id];
        [NSThread sleepForTimeInterval:1];
    }];

    [self refreshData];
    [self refreshStop];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_GLOBAL:
            return @"Global";
        case SECTION_LOCAL:
            return @"Local";
        case SECTION_TOOFAR:
            return @"Too far";
    }
    return @"?";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_GLOBAL:
            return [self.placesGlobal count];
        case SECTION_LOCAL:
            return [self.placesLocal count];
        case SECTION_TOOFAR:
            return [self.placesTooFar count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_PLACE forIndexPath:indexPath];

    dbPlace *place = nil;
    switch (indexPath.section) {
        case SECTION_GLOBAL:
            place = [self.placesGlobal objectAtIndex:indexPath.row];
            break;
        case SECTION_LOCAL:
            place = [self.placesLocal objectAtIndex:indexPath.row];
            break;
        case SECTION_TOOFAR:
            place = [self.placesTooFar objectAtIndex:indexPath.row];
            break;
    }

    cell.name.text = place.name;
    NSInteger unique = [[dbItem allInPlace:place] count];
    NSInteger total = [[dbItemInPlace allItemsInPlace:place] count];
    if (total == unique)
        cell.subtitle.text = [NSString stringWithFormat:@"%d item%@", unique, unique == 1 ? @"" : @"s"];
    else
        cell.subtitle.text = [NSString stringWithFormat:@"%d item%@, %d unique", total, total == 1 ? @"" : @"s", unique];
    cell.remark.text = @"";
    if (place.safeplace)
        cell.remark.text = @"Safe storage place";
    cell.image.image = [imageManager url:place.imgurl];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbPlace *place = nil;

    switch (indexPath.section) {
        case SECTION_GLOBAL:
            place = [self.placesGlobal objectAtIndex:indexPath.row];
            break;
        case SECTION_LOCAL:
            place = [self.placesLocal objectAtIndex:indexPath.row];
            break;
        case SECTION_TOOFAR:
            place = [self.placesTooFar objectAtIndex:indexPath.row];
            break;
    }

    PlaceTableViewController *newController = [[PlaceTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [newController showPlace:place];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = place.name;
    [self.navigationController pushViewController:newController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbPlace *place = nil;
    switch (indexPath.section) {
        case SECTION_GLOBAL:
            place = [self.placesGlobal objectAtIndex:indexPath.row];
            break;
        case SECTION_LOCAL:
            place = [self.placesLocal objectAtIndex:indexPath.row];
            break;
        case SECTION_TOOFAR:
            place = [self.placesTooFar objectAtIndex:indexPath.row];
            break;
    }

    if (place.safeplace == YES)
        return @"Unmark as safe place";
    else
        return @"Mark as safe place";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbPlace *place = nil;
    switch (indexPath.section) {
        case SECTION_GLOBAL:
            place = [self.placesGlobal objectAtIndex:indexPath.row];
            break;
        case SECTION_LOCAL:
            place = [self.placesLocal objectAtIndex:indexPath.row];
            break;
        case SECTION_TOOFAR:
            place = [self.placesTooFar objectAtIndex:indexPath.row];
            break;
    }

    place.safeplace = !place.safeplace;
    [place updateSafeplace];
    [self.tableView reloadData];
}

- (void)sortByPlaceName:(NSInteger)section
{
    id sort = nil;

    sort = ^(dbPlace *a, dbPlace *b) {
        return [a.name compare:b.name];
    };

    NSAssert(sort != nil, @"sort == nil");
    self.placesLocal = [self.placesLocal sortedArrayUsingComparator:sort];
    self.placesGlobal = [self.placesGlobal sortedArrayUsingComparator:sort];
    self.placesTooFar = [self.placesTooFar sortedArrayUsingComparator:sort];
}


@end
