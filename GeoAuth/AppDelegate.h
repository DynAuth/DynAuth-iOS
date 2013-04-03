//
//  AppDelegate.h
//  GeoAuth
//
//  Created by Jacob Okamoto on 1/31/13.
//  Copyright (c) 2013 Jacob Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MKNetworkEngine.h>
#import <MKNetworkOperation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKNetworkEngine *networkEngine;
@property (strong, nonatomic) UIWindow *window;

@end
