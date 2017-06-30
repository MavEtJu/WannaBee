//
//  WBTableViewController.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"


@interface WBTableViewController ()

@end

@implementation WBTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.canSortBySetName = NO;
    self.canSortByItemName = NO;
    self.canSortByPlaceName = NO;
    self.canSortByItemNumber = NO;

    return self;
}

- (void)sortBySetName { NSAssert(NO, @"Muh"); }
- (void)sortByItemName { NSAssert(NO, @"Muh"); }
- (void)sortByPlaceName { NSAssert(NO, @"Muh"); }
- (void)sortByItemNumber { NSAssert(NO, @"Muh"); }


- (void)refreshInit
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;

    if ([self respondsToSelector:@selector(handleLongPress:)] == YES) {
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //seconds
        lpgr.delegate = self;
        [self.tableView addGestureRecognizer:lpgr];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Sort by"
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *setName = [UIAlertAction
                              actionWithTitle:@"Set Name"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [self sortBySetName];
                                  [self.tableView reloadData];
                              }];

    UIAlertAction *itemName = [UIAlertAction
                               actionWithTitle:@"Item Name"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                  [self sortByItemName];
                                  [self.tableView reloadData];
                               }];

    UIAlertAction *placeName = [UIAlertAction
                                actionWithTitle:@"Place Name"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                  [self sortByPlaceName];
                                  [self.tableView reloadData];
                                }];

    UIAlertAction *itemNumber = [UIAlertAction
                                 actionWithTitle:@"Item Number"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                  [self sortByItemNumber];
                                  [self.tableView reloadData];
                                 }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    if (self.canSortBySetName == YES)
        [alert addAction:setName];
    if (self.canSortByItemName == YES)
        [alert addAction:itemName];
    if (self.canSortByPlaceName == YES)
        [alert addAction:placeName];
    if (self.canSortByItemNumber == YES)
        [alert addAction:itemNumber];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshTitle:(NSString *)title
{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.refreshControl.attributedTitle = attributedTitle;
    }];
}

- (void)refreshStop
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.refreshControl endRefreshing];
    }];
}

@end
