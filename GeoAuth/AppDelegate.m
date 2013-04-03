//
//  AppDelegate.m
//  GeoAuth
//
//  Created by Jacob Okamoto on 1/31/13.
//  Copyright (c) 2013 Jacob Okamoto. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize networkEngine;
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    networkEngine = [[MKNetworkEngine alloc] initWithHostName:@"cs5221.oko.io:8000"];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
    
    NSString *lat = [[NSString alloc] initWithFormat:@"%+.6f", location.coordinate.latitude];
    NSString *lon = [[NSString alloc] initWithFormat:@"%+.6f", location.coordinate.longitude];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *time = [df stringFromDate:location.timestamp];
    
    
    NSMutableDictionary* md = [[NSMutableDictionary alloc] init];
    NSString *dev_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"GEOAUTH_DEVICE_ID"];
    if([dev_id length] == 0) dev_id = @"852d106e102342c2911455998cf7e637";
    [md setValue:dev_id forKey:@"device_id"];
    [md setValue:lat forKey:@"latitude"];
    [md setValue:lon forKey:@"longitude"];
    [md setValue:time forKey:@"time"];
    
    MKNetworkOperation* op = [networkEngine operationWithPath:@"api/device/check-in" params:md httpMethod:@"POST"];
    [networkEngine enqueueOperation:op];
}

@end
