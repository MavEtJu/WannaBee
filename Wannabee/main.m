//
//  main.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

database *db = nil;
WannabeeLocationManager *locationManager = nil;

void showitems(NSArray *as, NSString *title);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Database object
        db = [[database alloc] init];

        // Location Manager
        locationManager = [[WannabeeLocationManager alloc] init];

        if ([CLLocationManager locationServicesEnabled] == NO) {
            NSLog(@"locationServices are disabled");
            // location services is disabled, alert user
#ifdef NOTDEF
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                            message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                                  otherButtonTitles:nil];
            [servicesDisabledAlert show];
#endif 
        }

        RemoteAPI *api = [[RemoteAPI alloc] init];

        if (api.token == nil || api.user_id == nil)
            [api api_login:@"username" password:@"password"];

        [api api_users__sets];
        [api api_users__pouch];

        NSArray<dbSet *> *sets = [dbSet all];
        [sets enumerateObjectsUsingBlock:^(dbSet * _Nonnull set, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<dbItem *> *itemsInSet = [dbItem allInSet:set];
            if ([itemsInSet count] < set.items_in_set) {
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

        NSArray *as;
        as = [database newerItemsInPouch];
        showitems(as, @"Newer Items in Pouch");
        as = [database newerItemsInPlaces];
        showitems(as, @"Newer Items in Places");
        as = [database newItemsInPlaces];
        showitems(as, @"New Items in Places");
    }
    return 0;
}

void showitems(NSArray *as, NSString *title)
{
    NSLog(@"Section: %@", title);
    [as enumerateObjectsUsingBlock:^(NSArray * _Nonnull is, NSUInteger idx, BOOL * _Nonnull stop) {
        [is enumerateObjectsUsingBlock:^(NSObject * _Nonnull o, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([o isKindOfClass:[dbSet class]] == YES) {
                dbSet *s = (dbSet *)o;
                NSLog(@"Set: %@", s.name);
            }
            if ([o isKindOfClass:[dbItem class]] == YES) {
                dbItem *i = (dbItem *)o;
                NSLog(@"Item: %@", i.name);
            }
            if ([o isKindOfClass:[dbPlace class]] == YES) {
                dbPlace *p = (dbPlace *)o;
                NSLog(@"Place: %@", p.name);
            }
            if ([o isKindOfClass:[dbItemInSet class]] == YES) {
                dbItemInSet *iis = (dbItemInSet *)o;
                NSLog(@"Number in set: %ld", iis.number);
            }
            if ([o isKindOfClass:[dbItemInPouch class]] == YES) {
                dbItemInPouch *iip = (dbItemInPouch *)o;
                NSLog(@"Number in pouch: %ld", iip.number);
            }
            if ([o isKindOfClass:[dbItemInPlace class]] == YES) {
                dbItemInPlace *iip = (dbItemInPlace *)o;
                NSLog(@"Number in place: %ld", iip.number);
            }
        }];
        NSLog(@"");
    }];
    NSLog(@"------------");
}
