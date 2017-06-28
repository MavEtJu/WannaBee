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

    self.places = [dbPlace all];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_PLACE];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_PLACE forIndexPath:indexPath];
    dbPlace *place = [self.places objectAtIndex:indexPath.row];

    cell.textLabel.text = place.name;

    return cell;
}

@end
