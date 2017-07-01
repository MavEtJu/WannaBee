//
//  dbPlace.m
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation dbPlace

- (void)create
{
    @synchronized(db) {
        DB_PREPARE(@"insert into places(name, place_id, radius, lat, lon, imgurl, safeplace) values(?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT  (1, self.name);
        SET_VAR_INT   (2, self.place_id);
        SET_VAR_INT   (3, self.radius);
        SET_VAR_DOUBLE(4, self.lat);
        SET_VAR_DOUBLE(5, self.lon);
        SET_VAR_TEXT  (6, self.imgurl);
        SET_VAR_BOOL  (7, self.safeplace);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
}

- (void)updateSafeplace
{
    @synchronized(db) {
        DB_PREPARE(@"update places set safeplace = ? where id = ?");

        SET_VAR_BOOL  (1, self.safeplace);
        SET_VAR_INT   (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbPlace *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbPlace *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, place_id, radius, lat, lon, imgurl, safeplace from places "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbPlace *c = [[dbPlace alloc] init];
            INT_FETCH   (0, c._id);
            TEXT_FETCH  (1, c.name);
            INT_FETCH   (2, c.place_id);
            INT_FETCH   (3, c.radius);
            DOUBLE_FETCH(4, c.lat);
            DOUBLE_FETCH(5, c.lon);
            TEXT_FETCH  (6, c.imgurl);
            BOOL_FETCH  (7, c.safeplace);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbPlace *> *)all
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbPlace *)get:(NSInteger)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbPlace *)getByPlaceId:(NSInteger)place_id
{
    return [[self dbAllXXX:@"where place_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:place_id]]] firstObject];
}

+ (dbPlace *)getByPlaceName:(NSString *)place_name;
{
    return [[self dbAllXXX:@"where name = ?" keys:@"s" values:@[place_name]] firstObject];
}

+ (void)deleteAll
{
    [self deleteAll:@"places"];
}

+ (void)deleteAllExceptSafeplaces
{
    [self deleteAll:@"places where safeplace = 0"];
}

/* Other methods */

- (CLLocationDegrees)toRadians:(CLLocationDegrees)f
{
    return f * M_PI / 180;
}

- (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    float R = 6371000; // radius of Earth in metres
    float φ1 = [self toRadians:c1.latitude];
    float φ2 = [self toRadians:c2.latitude];
    float Δφ = [self toRadians:c2.latitude - c1.latitude];
    float Δλ = [self toRadians:c2.longitude - c1.longitude];

    float a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2);
    float c = 2 * atan2(sqrt(a), sqrt(1 - a));

    float d = R * c;
    return d;
}

- (BOOL)canReach
{
    return ([self coordinates2distance:CLLocationCoordinate2DMake(locationManager.last.latitude, locationManager.last.longitude) to:CLLocationCoordinate2DMake(self.lat, self.lon)] < self.radius);
}

@end
