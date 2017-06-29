//
//  WBTableViewController.h
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface WBTableViewController : UITableViewController

- (void)refreshInit;
- (void)refreshTitle:(NSString *)title;
- (void)refreshStop;

@end
