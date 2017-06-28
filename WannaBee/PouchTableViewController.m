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


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.items = [dbItem allInPouch];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Pouch";
}

@end
