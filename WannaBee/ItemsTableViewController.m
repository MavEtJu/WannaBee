//
//  ItemTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ItemsTableViewController ()

@end

@implementation ItemsTableViewController

#define CELL_ITEM   @"CELL_ITEM"

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TableViewCellSubtitle class] forCellReuseIdentifier:CELL_ITEM];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    NSObject *o = [self.items objectAtIndex:indexPath.row];

    cell.textLabel.text = @"-";
    cell.detailTextLabel.text = @"";

    if ([o isKindOfClass:[dbItem class]] == YES) {
        dbItem *item = (dbItem *)[self.items objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", item.name];
        dbSet *set = [dbSet get:item.set_id];
        cell.detailTextLabel.text = set.name;
        return cell;
    }

    if ([o isKindOfClass:[NSArray class]] == YES) {
        NSArray *as = (NSArray *)[self.items objectAtIndex:indexPath.row];

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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Found %d which is smaller than %d", newnumber, mynumber];

        return cell;
    }

    return cell;
}

@end
