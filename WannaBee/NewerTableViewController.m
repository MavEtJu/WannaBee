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

@end

@implementation NewerTableViewController

#define CELL_ITEM   @"CELL_ITEM"

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_ITEM];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];

    [self refreshData];
}

- (void)refreshData
{
    [self.refreshControl beginRefreshing];

    self.newerItemsInPlaces = [database newerItemsInPlaces];
    self.newerItemsInPouch = [database newerItemsInPouch];
    self.unseenItemsInPlaces = [database newItemsInPlaces];

    [self.refreshControl endRefreshing];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"New Items in Places";
        case 1:
            return @"Newer Items in Places";
        case 2:
            return @"Newer Items in Pouch";
    }
    return @"???";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.unseenItemsInPlaces count];
        case 1:
            return [self.newerItemsInPlaces count];
        case 2:
            return [self.newerItemsInPouch count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    NSObject *o;
    switch (indexPath.section) {
        case 0:
            o = [self.unseenItemsInPlaces objectAtIndex:indexPath.row];
            break;
        case 1:
            o = [self.newerItemsInPlaces objectAtIndex:indexPath.row];
            break;
        case 2:
            o = [self.newerItemsInPouch objectAtIndex:indexPath.row];
            break;
    }

    cell.textLabel.text = @"-";
    cell.detailTextLabel.text = @"";

    if ([o isKindOfClass:[dbItem class]] == YES) {
        dbItem *item = (dbItem *)o;
        cell.textLabel.text = item.name;
        return cell;
    }

    if ([o isKindOfClass:[NSArray class]] == YES) {
        NSArray *as = (NSArray *)o;

        __block NSString *place = nil;
        __block NSString *set = nil;
        __block NSString *item = nil;
        __block NSInteger mynumber = 0;
        __block NSInteger newnumber = 0;

        [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([a isKindOfClass:[dbItem class]] == YES) {
                dbItem *i = (dbItem *)a;
                item = i.name;
            }
            if ([a isKindOfClass:[dbSet class]] == YES) {
                dbSet *s = (dbSet *)a;
                set = s.name;
            }
            if ([a isKindOfClass:[dbPlace class]] == YES) {
                dbPlace *p = (dbPlace *)a;
                place = p.name;
            }
            if ([a isKindOfClass:[dbItemInSet class]] == YES) {
                dbItemInSet *iis = (dbItemInSet *)a;
                mynumber = iis.number;
            }
            if ([a isKindOfClass:[dbItemInPlace class]] == YES) {
                dbItemInPlace *iip = (dbItemInPlace *)a;
                newnumber = iip.number;
            }
            if ([a isKindOfClass:[dbItemInPouch class]] == YES) {
                dbItemInPouch *iip = (dbItemInPouch *)a;
                newnumber = iip.number;
            }
        }];

        if (place == nil)
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (pouch)", item];
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item, place];
        if (mynumber == 0)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d", newnumber];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Found #%d which is smaller than #%d", newnumber, mynumber];

        return cell;
    }
    
    return cell;
}

@end
