//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlacesTableViewController ()

@property (nonatomic, retain) NSArray<dbPlace *> *places;

@end

@implementation PlacesTableViewController

#define CELL_PLACE  @"PlacesCell"

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_PLACE];


    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];

//    [self refreshData];
}

- (void)refreshTitle:(NSString *)title
{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

- (void)refreshData
{
    self.places = [dbPlace all];
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
    [dbPlace deleteAll];
    [dbItemInPlace deleteAll];
    [self refreshTitle:@"Obtaining places"];
    [api api_places:locationManager.last.latitude longitude:locationManager.last.longitude];

    NSArray<dbPlace *> *places = [dbPlace all];
    [places enumerateObjectsUsingBlock:^(dbPlace * _Nonnull place, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([place.name isEqualToString:@"The WallaBee Museum"] == YES)
            return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self refreshTitle:[NSString stringWithFormat:@"Obtaining items for %@", place.name]];
        }];
        [dbItemInPlace deleteByPlace:place._id];
        [api api_places__items:place.place_id];
        [NSThread sleepForTimeInterval:1];
    }];

    [self refreshData];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Places";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_PLACE forIndexPath:indexPath];
    dbPlace *place = [self.places objectAtIndex:indexPath.row];

    cell.textLabel.text = place.name;
    NSInteger unique = [[dbItem allInPlace:place] count];
    NSInteger total = [[dbItemInPlace allItemsInPlace:place] count];
    if (total == unique)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d item%@", unique, unique == 1 ? @"" : @"s"];
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d item%@, %d unique", total, total == 1 ? @"" : @"s", unique];

    return cell;
}

@end
