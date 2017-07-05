//
//  main.m
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

database *db = nil;
LocationManager *locationManager = nil;
ImageManager *imageManager = nil;
RemoteAPI *api = nil;
AppDelegate *appDelegate = nil;
MixManager *mixManager = nil;

void showitems(NSArray *as, NSString *title);

int main(int argc, char * _Nonnull *argv)
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    return 0;
}
