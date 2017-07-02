//
//  AppDelegate.h
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TabBarController *tabBarController;
@property (strong, nonatomic) PouchTableViewController *pouchVC;
@property (strong, nonatomic) UINavigationController *pouchNC;
@property (strong, nonatomic) NewerTableViewController *newerVC;
@property (strong, nonatomic) UINavigationController *newerNC;
@property (strong, nonatomic) PlacesTableViewController *placesVC;
@property (strong, nonatomic) UINavigationController *placesNC;
@property (strong, nonatomic) MixingsTableViewController *mixingsVC;
@property (strong, nonatomic) UINavigationController *mixingsNC;
@property (strong, nonatomic) SetsTableViewController *setsVC;
@property (strong, nonatomic) UINavigationController *setsNC;

@end

extern AppDelegate *appDelegate;
