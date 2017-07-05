//
//  PouchViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PouchTableViewController ()

@property (nonatomic, retain) NSArray *neededForSets;
@property (nonatomic, retain) NSArray *neededForMixing;
@property (nonatomic, retain) NSArray *notNeeded;

@end

@implementation PouchTableViewController

enum {
    SECTION_NEEDEDFORSETS = 0,
    SECTION_NEEDEDFORMIXING,
    SECTION_NOTNEEDED,
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
        case SECTION_NEEDEDFORSETS:
            return self.neededForSets;
        case SECTION_NEEDEDFORMIXING:
            return self.neededForMixing;
        case SECTION_NOTNEEDED:
            return self.notNeeded;
    }
    return nil;
}

- (void)setItems:(NSArray<NSObject *> *)items forSection:(NSInteger)section
{
    switch (section) {
        case SECTION_NEEDEDFORSETS:
            self.neededForSets = items;
            break;
        case SECTION_NEEDEDFORMIXING:
            self.neededForMixing = items;
            break;
        case SECTION_NOTNEEDED:
            self.notNeeded = items;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_NEEDEDFORSETS:
            return @"Items needed in sets";
        case SECTION_NEEDEDFORMIXING:
            return @"Items needed for mixing";
        case SECTION_NOTNEEDED:
            return @"Not needed";
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
    NSMutableArray<dbItemInPouch *> *neededForSets = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPouch *> *neededForMixing = [NSMutableArray arrayWithCapacity:[iips count]];
    NSMutableArray<dbItemInPouch *> *notNeeded = [NSMutableArray arrayWithCapacity:[iips count]];

    [iips enumerateObjectsUsingBlock:^(dbItemInPouch * _Nonnull iip, NSUInteger idx, BOOL * _Nonnull stop) {

        if (iip.item_id== 1875)
            NSLog(@"foo");
        dbItem *i = [dbItem get:iip.item_id];
        if ([mixManager isItemNeeded:i] == YES)
            [neededForSets addObject:iip];
        else if ([mixManager isItemNeededForMixing:i] == YES)
            [neededForMixing addObject:iip];
        else
            [notNeeded addObject:iip];
    }];

    NSLog(@"neededForSets: %d" , [neededForSets count]);
    NSLog(@"neededForMixing: %d" , [neededForMixing count]);
    NSLog(@"notNeeded: %d" , [notNeeded count]);

    self.neededForSets = neededForSets;
    self.neededForMixing = neededForMixing;
    self.notNeeded = notNeeded;
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
