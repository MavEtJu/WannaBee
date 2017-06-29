//
//  PlaceTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface PlaceTableViewController ()

@end

@implementation PlaceTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.title = @"Place";
    self.type = TYPE_PLACE;

    return self;
}

- (void)showPlace:(dbPlace *)place
{
    self.place = place;
    self.items = [dbItem allInPlace:place];
}

@end
