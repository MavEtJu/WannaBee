//
//  AppDelegate.m
//  WannaBee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface AppDelegate ()
{
    MBProgressHUD *hud;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appDelegate = self;

    // Database object
    db = [[database alloc] init];
    [db upgrade];

    // Location Manager
    locationManager = [[LocationManager alloc] init];

    // Image Manager
    imageManager = [[ImageManager alloc] init];

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
    self.pouchNC = [[UINavigationController alloc] initWithRootViewController:self.pouchVC];

    self.placesVC = [[PlacesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.placesVC.title = @"Places";
    self.placesNC = [[UINavigationController alloc] initWithRootViewController:self.placesVC];

    self.setsVC = [[SetsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.setsVC.title = @"Sets";
    self.setsNC = [[UINavigationController alloc] initWithRootViewController:self.setsVC];

    self.newerVC = [[NewerTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.newerVC.title = @"Newer";
    self.newerNC = [[UINavigationController alloc] initWithRootViewController:self.newerVC];

    //create an array of all view controllers that will represent the tab at the bottom
    NSArray *myViewControllers = [[NSArray alloc] initWithObjects:
                                  self.pouchNC,
                                  self.placesNC,
                                  self.setsNC,
                                  self.newerNC,
                                  nil];

    //initialize the tab bar controller
    self.tabBarController = [[TabBarController alloc] init];

    //set the view controllers for the tab bar controller
    [self.tabBarController setViewControllers:myViewControllers];

    //add the tab bar controllers view to the window
    [self.window addSubview:self.tabBarController.view];
    self.window.rootViewController = self.tabBarController;

    //set the window background color and make it visible
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    hud = [MBProgressHUD showHUDAddedTo:_pouchVC.view animated:YES];
    [self performSelectorInBackground:@selector(loadData) withObject:nil];

    // Override point for customization after application launch.
    return YES;
}

- (void)loadData
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    if (username == nil || [username isEqualToString:@""] == YES ||
        password == nil || [password isEqualToString:@""] == YES) {
        NSLog(@"@No username or password yet");
        return;
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud.label.text = @"Authenticating";
    }];

    if (api.token == nil || api.user_id == nil)
        [api api_login:username password:password];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud.label.text = @"Download sets";
    }];
    [api api_users__sets];

    NSArray<dbSet *> *sets = [dbSet all];
    [sets enumerateObjectsUsingBlock:^(dbSet * _Nonnull set, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<dbItem *> *itemsInSet = [dbItem allInSet:set];
        if (set.needs_refresh == YES || [itemsInSet count] == 0 || [itemsInSet count] < set.items_in_set) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                hud.detailsLabel.text = [NSString stringWithFormat:@"%d / %d - %@", 1 + idx, [sets count], set.name];
            }];
            [dbItemInSet deleteBySet:set];
            [api api_users__sets:set.set_id];
            set.needs_refresh = NO;
            [set dbUpdateNeedsRefresh];
            [NSThread sleepForTimeInterval:0.5];
        }
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud.label.text = @"Downloading pouch";
        hud.detailsLabel.text = @"";
    }];
    [api api_users__pouch];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud.label.text = @"Downloading places";
    }];
    [dbPlace deleteAll];
    [dbItemInPlace deleteAll];
    [api api_places:locationManager.last.latitude longitude:locationManager.last.longitude];
    NSArray<dbPlace *> *places = [dbPlace all];
    [places enumerateObjectsUsingBlock:^(dbPlace * _Nonnull place, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([place.name isEqualToString:@"The WallaBee Museum"] == YES)
            return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            hud.detailsLabel.text = [NSString stringWithFormat:@"%d / %d - %@", 1 + idx, [places count], place.name];
        }];
        [dbItemInPlace deleteByPlace:place];
        [api api_places__items:place.place_id];
        [NSThread sleepForTimeInterval:1];
    }];

    [self.pouchVC refreshData];
    [self.placesVC refreshData];
    [self.setsVC refreshData];
    [self.newerVC refreshData];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [hud hideAnimated:TRUE];
    }];
}

@end
