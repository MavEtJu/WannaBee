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

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.canSortBySetName = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_SET];

    [self refreshInit];
    [self refreshData];
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
            if (self.refreshControl != nil)
                [self refreshTitle:[NSString stringWithFormat:@"Reloading data for set '%@'", set.name]];
            [api api_users__sets:set.set_id];
            [NSThread sleepForTimeInterval:0.5];
        }
    }];

    [self refreshData];
    [self refreshStop];

    // Now fill the pouch
    [appDelegate.pouchVC refreshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SET forIndexPath:indexPath];
    dbSet *set = [self.sets objectAtIndex:indexPath.row];

    cell.name.text = set.name;
    NSInteger count = [[dbItem allInSet:set] count];
    NSInteger got = [[dbItem allInSetStored:set] count];
    cell.subtitle.text = [NSString stringWithFormat:@"%d item%@, %d in set", count, count == 1 ? @"" : @"s", got];
    cell.image.image = [imageManager url:set.imgurl];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbSet *set = [self.sets objectAtIndex:indexPath.row];

    SetTableViewController *newController = [[SetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [newController showSet:set];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = set.name;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)sortBySetName
{
    id sort = nil;

    sort = ^(dbSet *a, dbSet *b) {
        return [a.name compare:b.name];
    };

    NSAssert(sort != nil, @"sort == nil");
    self.sets = [self.sets sortedArrayUsingComparator:sort];
}

@end
