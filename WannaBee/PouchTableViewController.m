//
//  PouchViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PouchTableViewController ()

@end

@implementation PouchTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Pouch";

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTitle:(NSString *)title
{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

- (void)refreshData
{
    self.items = [dbItem allInPouch];
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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];
}

@end
