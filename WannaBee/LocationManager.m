//
//  WannabeeLocationManager.m
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation LocationManager

- (instancetype)init
{
    self = [super init];

    self.last = CLLocationCoordinate2DMake(-34.047, 151.1229);

    self.lm = [[CLLocationManager alloc] init];
    self.lm.distanceFilter = kCLDistanceFilterNone;
    self.lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.lm.delegate = self;
    [self.lm startUpdatingLocation];

    CLAuthorizationStatus stat = [CLLocationManager authorizationStatus];
    if (stat == kCLAuthorizationStatusNotDetermined ||
        stat == kCLAuthorizationStatusRestricted ||
        stat == kCLAuthorizationStatusDenied)
        [self.lm requestWhenInUseAuthorization];

    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (self.last.latitude == newLocation.coordinate.latitude && self.last.longitude == newLocation.coordinate.longitude)
        return;
    NSLog(@"New location: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    self.last = newLocation.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"%@", [error description]);
}

@end
