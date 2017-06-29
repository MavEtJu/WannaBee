//
//  WannabeeLocationManager.h
//  Wannabee
//
//  Created by Edwin Groothuis on 28/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *lm;
@property (nonatomic) CLLocationCoordinate2D last;

@end

extern LocationManager *locationManager;
