//
//  PouchViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PouchTableViewController ()

@property (nonatomic, retain) NSArray *mixableItems;
@property (nonatomic, retain) NSArray *otherItems;

@end

@implementation PouchTableViewController

enum {
    SECTION_MIXABLE = 0,
    SECTION_OTHERS,
    SECTION_MAX,
};

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Pouch";
    self.type = TYPE_POUCH;

    self.canSortBySetName = YES;
    self.canSortByItemName = YES;
    self.canSortByItemNumber = YES;

    return self;
}

- (NSArray<NSObject *> *)itemsForSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            return self.mixableItems;
        case SECTION_OTHERS:
            return self.otherItems;
    }
    return nil;
}

- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            self.mixableItems = items;
            break;
        case SECTION_OTHERS:
            self.otherItems = items;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MIXABLE:
            return @"Mixable items";
        case SECTION_OTHERS:
            return @"Other items";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshInit];
}

- (void)refreshData
{
    NSArray<dbItemInPouch *> *iips = [dbItemInPouch all];
    NSMutableArray<dbItemInPouch *> *m = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPouch *> *o = [NSMutableArray arrayWithCapacity:[iips count]];
    [iips enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull iip, NSUInteger idx, BOOL * _Nonnull stop) {
        dbItem *i = [dbItem get:iip.item_id];
        if ([dbFormula isSourceObject:i] == YES)
            [m addObject:iip];
        else
            [o addObject:iip];
    }];
    self.mixableItems = m;
    self.otherItems = o;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)reloadData
{
    [self refreshTitle:@"Reloading pouch data"];
    [self performSelectorInBackground:@selector(reloadDataBG) withObject:nil];
}

- (void)reloadDataBG
{
    [api api_users__pouch];
    [self refreshData];
    [self refreshStop];
}

@end
