//
//  SetTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation SetTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Set";

    return self;
}

- (void)showSet:(dbSet *)set
{
    self.items = [dbItem allInSet:set];
}

@end
