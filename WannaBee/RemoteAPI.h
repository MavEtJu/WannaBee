//
//  RemoteAPI.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface RemoteAPI : NSObject

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *apikey;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *user_id;

- (int)api_login:(NSString *)username password:(NSString *)password;
- (int)api_users__pouch;
- (int)api_sets;
- (int)api_users__sets;
- (int)api_users__sets:(NSInteger)set_id;
- (int)api_places:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lon;
- (int)api_places__items:(NSInteger)place_id;

@end

extern RemoteAPI *api;
