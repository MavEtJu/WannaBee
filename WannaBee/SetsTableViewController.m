//
//  SetsTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface SetsTableViewController ()

@property (nonatomic, retain) NSArray<dbSet *> *sets;

@end

@implementation SetsTableViewController

#define CELL_SET  @"SetsCell"

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_SET];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];

    [self refreshData];
}

- (void)refreshTitle:(NSString *)title
{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

- (void)refreshData
{
    self.sets = [dbSet all];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading set data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [api api_users__sets];

    NSArray<dbSet *> *sets = [dbSet all];
    [sets enumerateObjectsUsingBlock:^(dbSet * _Nonnull set, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<dbItem *> *itemsInSet = [dbItem allInSet:set];
        if ([itemsInSet count] == 0 || [itemsInSet count] < set.items_in_set) {
            [self refreshTitle:[NSString stringWithFormat:@"Reloading data for set '%@'", set.name]];
            [api api_users__sets:set.set_id];
            [NSThread sleepForTimeInterval:0.5];
        }
    }];

    [self refreshData];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];

    // Now fill the pouch
    [appDelegate.pouchVC refreshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Sets";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SET forIndexPath:indexPath];
    dbSet *set = [self.sets objectAtIndex:indexPath.row];

    cell.textLabel.text = set.name;
    NSInteger count = [[dbItem allInSet:set] count];
    NSInteger got = [[dbItem allInSetStored:set] count];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d item%@, %d in set", count, count == 1 ? @"" : @"s", got];

    return cell;
}

@end
