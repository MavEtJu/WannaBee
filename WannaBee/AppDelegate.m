//
//  AppDelegate.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Database object
    db = [[database alloc] init];

    // Location Manager
    locationManager = [[WannabeeLocationManager alloc] init];

    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServices are disabled");
        // location services is disabled, alert user

        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }

    // Remote API
    api = [[RemoteAPI alloc] init];

    //
    // And the view controllers
    //

    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:bounds];

    self.pouchVC = [[PouchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.pouchVC.title = @"Pouch";

    self.placesVC = [[PlacesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.placesVC.title = @"Places";

    self.setsVC = [[SetsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.setsVC.title = @"Sets";

    self.newerVC = [[NewerTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.newerVC.title = @"Newer";

    //create an array of all view controllers that will represent the tab at the bottom
    NSArray *myViewControllers = [[NSArray alloc] initWithObjects:
                                  self.pouchVC,
                                  self.placesVC,
                                  self.setsVC,
                                  self.newerVC,
                                  nil];

    //initialize the tab bar controller
    self.tabBarController = [[WannaBeenTabBarController alloc] init];

    //set the view controllers for the tab bar controller
    [self.tabBarController setViewControllers:myViewControllers];

    //add the tab bar controllers view to the window
    [self.window addSubview:self.tabBarController.view];
    self.window.rootViewController = self.tabBarController;

    //set the window background color and make it visible
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [self performSelectorInBackground:@selector(loadData) withObject:nil];

    // Override point for customization after application launch.
    return YES;
}

- (void)loadData
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    if (username == nil || [username isEqualToString:@""] == YES)
        return;
    if (password == nil || [password isEqualToString:@""] == YES)
        return;

    if (api.token == nil || api.user_id == nil)
        [api api_login:username password:password];

    [api api_users__sets];
    [api api_users__pouch];

    NSArray<dbSet *> *sets = [dbSet all];
    [sets enumerateObjectsUsingBlock:^(dbSet * _Nonnull set, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<dbItem *> *itemsInSet = [dbItem allInSet:set];
        if ([itemsInSet count] == 0 || [itemsInSet count] < set.items_in_set) {
            [api api_users__sets:set.set_id];
            [NSThread sleepForTimeInterval:0.5];
        }
    }];

    [api api_places:locationManager.last.latitude longitude:locationManager.last.longitude];
    NSArray<dbPlace *> *places = [dbPlace all];
    [places enumerateObjectsUsingBlock:^(dbPlace * _Nonnull place, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([place.name isEqualToString:@"The WallaBee Museum"] == YES)
            return;
        [dbItemInPlace deleteByPlace:place._id];
        [api api_places__items:place.place_id];
        [NSThread sleepForTimeInterval:1];
    }];

    [self.pouchVC.tableView reloadData];
    [self.placesVC.tableView reloadData];
    [self.setsVC.tableView reloadData];
    [self.newerVC.tableView reloadData];
}

@end
