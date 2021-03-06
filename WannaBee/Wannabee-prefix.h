//
//  Wannabee-prefix.h
//  Wannabee
//
//  Created by Edwin Groothuis on 27/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#ifndef Wannabee_prefix_h
#define Wannabee_prefix_h

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>

#import "MBProgressHUD.h"

#import "RemoteAPI.h"
#import "LocationManager.h"
#import "ImageManager.h"

#import "database.h"
#import "dbObject.h"
#import "dbConfig.h"
#import "dbSet.h"
#import "dbPlace.h"
#import "dbItem.h"
#import "dbWishList.h"
#import "dbItemInSet.h"
#import "dbItemsInPouch.h"
#import "dbItemInPlace.h"
#import "dbFormula.h"

#import "MixManager.h"

#import "ImageTableViewCell.h"
#import "ItemTableViewCell.h"

#import "TabBarController.h"
#import "WBTableViewController.h"
#import "ItemsTableViewController.h"
#import "PouchTableViewController.h"
#import "PlaceTableViewController.h"
#import "PlacesTableViewController.h"
#import "SetsTableViewController.h"
#import "SetTableViewController.h"
#import "MixingTableViewController.h"
#import "MixingsTableViewController.h"
#import "NewerTableViewController.h"

#import "AppDelegate.h"

extern ImageManager *imageManager;

#endif /* Wannabee_prefix_h */
