//
//  RemoteAPI.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@implementation RemoteAPI

- (instancetype)init
{
    self = [super init];

    self.host= @"https://new-api.wallab.ee";
    self.apikey = @"4f3659cd-5c78-46e0-94fa-38304d4902ac";

    dbConfig *c = [dbConfig getByKey:@"token"];
    self.token = c.value;
    c = [dbConfig getByKey:@"user_id"];
    self.user_id = c.value;

    return self;
}

- (NSMutableURLRequest *)newRequest:(NSURL *)url
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:self.apikey forHTTPHeaderField:@"x-wallabee-api-key"];
    if (self.token != nil)
        [req setValue:self.token forHTTPHeaderField:@"x-user-token"];
    return req;
}

- (int)api_login:(NSString *)username password:(NSString *)password
{
    NSLog(@"api_login:%@:%@", username, password);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login", self.host]];

    NSMutableURLRequest *req = [self newRequest:url];
    [req setHTTPMethod:@"POST"];

    NSString *boundary = @"YOUR_BOUNDARY_STRING";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
    [params setObject:username forKey:@"username"];
    [params setObject:password forKey:@"password"];

    NSMutableData *body = [NSMutableData data];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull k, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", k, [params objectForKey:k]] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    req.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    self.token = [json objectForKey:@"token"];
    self.user_id = [[json objectForKey:@"user_id"] stringValue];

    dbConfig *c = [[dbConfig alloc] init];
    c.key = @"token";
    c.value = self.token;
    [c create];

    c = [[dbConfig alloc] init];
    c.key = @"user_id";
    c.value = self.user_id;
    [c create];

    return 0;
}

- (int)api_users__pouch
{
    NSLog(@"api_users__pouch");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/pouch", self.host, self.user_id]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    [dbItemInPouch deleteAll];
    NSArray *items = [json objectForKey:@"items"];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [itemDict objectForKey:@"name"];
        NSNumber *number = [itemDict objectForKey:@"number"];
        NSNumber *item_type_id = [itemDict objectForKey:@"item_type_id"];
        NSNumber *set_id = [itemDict objectForKey:@"set_id"];

        dbSet *set = [dbSet getBySetId:[set_id integerValue]];
        dbItem *item = [dbItem getByItemTypeId:[item_type_id integerValue]];
        if (item == nil) {
            item = [[dbItem alloc] init];
            item.item_type_id = [item_type_id integerValue];
            item.name = name;
            item.set_id = set._id;
            [item create];
        }

        dbItemInPouch *iip = [[dbItemInPouch alloc] init];
        iip.item_id = item._id;
        iip.number = [number integerValue];
        [iip create];
    }];

    return 0;
}

- (int)api_sets
{
    NSLog(@"api_sets");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sets", self.host]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    NSArray *sets = [json objectForKey:@"sets"];
    [sets enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull setDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *set_name = [setDict objectForKey:@"name"];
        NSNumber *set_id = [setDict objectForKey:@"id"];

        dbSet *set = [dbSet getBySetId:[set_id integerValue]];
        if (set == nil) {
            set = [[dbSet alloc] init];
            set.name = set_name;
            set.set_id = [set_id integerValue];
            [set create];
        }
    }];
    
    return 0;
}

- (int)api_users__sets
{
    NSLog(@"api_users__sets");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/sets", self.host, self.user_id]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    NSArray *sets = [json objectForKey:@"sets"];
    [sets enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [itemDict objectForKey:@"name"];
        NSString *set_id = [itemDict objectForKey:@"id"];
        NSNumber *items_in_set = [itemDict objectForKey:@"numberinset"];

        dbSet *set = [dbSet getBySetId:[set_id integerValue]];
        if (set == nil) {
            set = [[dbSet alloc] init];
            set.name = name;
            set.set_id = [set_id integerValue];
            set.items_in_set = [items_in_set integerValue];
            [set create];
        }
    }];

    return 0;
}

- (int)api_users__sets:(NSInteger)set_id
{
    NSLog(@"api_users__sets:%d", set_id);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/sets/%d", self.host, self.user_id, set_id]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    NSArray *items = [json objectForKey:@"items"];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [itemDict objectForKey:@"name"];
        NSString *number = [itemDict objectForKey:@"number"];
        NSNumber *item_type_id = [itemDict objectForKey:@"item_type_id"];

        dbSet *set = [dbSet getBySetId:set_id];
        dbItem *item = [dbItem getByItemTypeId:[item_type_id integerValue]];
        if (item == nil) {
            item = [[dbItem alloc] init];
            item.item_type_id = [item_type_id integerValue];
            item.name = name;
            item.set_id = set._id;
            [item create];
        }
        if ([number isKindOfClass:[NSNumber class]] == YES) {
            dbItemInSet *iis = [dbItemInSet getByItemId:item._id];
            if (iis == nil) {
                iis = [[dbItemInSet alloc] init];
                iis.item_id = item._id;
                iis.number = [number integerValue];
                [iis create];
            }
        }
    }];

    dbSet *set = [dbSet getBySetId:set_id];
    NSLog(@"%@: Imported %d items", set.name, [items count]);

    return 0;
}

- (int)api_places:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lon
{
    NSLog(@"api_places:%f, %f", lat, lon);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places?lat=%f&lng=%f", self.host, lat, lon]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    NSArray *places = [json objectForKey:@"places"];
    [places enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [itemDict objectForKey:@"name"];
        NSNumber *place_id = [itemDict objectForKey:@"id"];

        dbPlace *place = [dbPlace getByPlaceId:[place_id integerValue]];
        if (place == nil) {
            place = [[dbPlace alloc] init];
            place.name = name;
            place.place_id = [place_id integerValue];
            [place create];
        }
    }];
    
    return 0;
}

- (int)api_places__items:(NSInteger)place_id
{
    NSLog(@"api_places__items:%d", place_id);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/%d/items", self.host, place_id]];

    NSMutableURLRequest *req = [self newRequest:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return 1;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return 1;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    dbPlace *place = [dbPlace getByPlaceId:place_id];
    NSArray *items = [json objectForKey:@"items"];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *item_type_id = [itemDict objectForKey:@"item_type_id"];
        NSNumber *number = [itemDict objectForKey:@"number"];

        dbItem *item = [dbItem getByItemTypeId:[item_type_id integerValue]];
        dbItemInPlace *iip = [[dbItemInPlace alloc] init];
        iip.place_id = place._id;
        iip.item_id = item._id;
        iip.number = [number integerValue];
        [iip create];
    }];
    NSLog(@"Imported %d items to %@", [items count], place.name);
    
    return 0;
    
}

@end
