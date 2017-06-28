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
@property (strong, nonatomic) WannaBeenTabBarController *tabBarController;
@property (strong, nonatomic) PouchTableViewController *pouchVC;
@property (strong, nonatomic) NewerTableViewController *newerVC;
@property (strong, nonatomic) PlacesTableViewController *placesVC;
@property (strong, nonatomic) SetsTableViewController *setsVC;

@end

