//
//  ShopTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 30/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ShopTableViewController ()

@property (nonatomic, retain) NSArray<dbItem *> *items;

@property (nonatomic, retain) UIColor *tooFarColour;
@property (nonatomic, retain) UIColor *reachableColour;;

@end

@implementation ShopTableViewController

#define CELL_ITEM   @"newercells"

#define SECTION_MAX 1

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
    self.items = [dbItem all];

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
    return @"???";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ITEM forIndexPath:indexPath];
    dbItem *item = [self.items objectAtIndex:indexPath.row];

    cell.itemName.text = @"";
    cell.setName.text = @"";
    cell.placeName.text = @"";
    cell.numbers.text = @"";

    cell.itemName.textColor = self.reachableColour;
    cell.setName.textColor = self.reachableColour;
    cell.placeName.textColor = self.reachableColour;
    cell.numbers.textColor = self.reachableColour;

    cell.itemName.text = item.name;
    cell.image.image = [imageManager url:item.imgurl];

    return cell;
}

@end
