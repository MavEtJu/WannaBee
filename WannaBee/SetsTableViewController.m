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

    self.sets = [dbSet all];

    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_SET];
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
    return [self.sets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SET forIndexPath:indexPath];
    dbSet *set = [self.sets objectAtIndex:indexPath.row];

    cell.textLabel.text = set.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d items", [[dbItem allInSet:set] count]];

    return cell;
}

@end
