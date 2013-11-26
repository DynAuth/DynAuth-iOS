//
//  ViewController.h
//  GeoDemo
//
//  Created by Extractor on 11/16/13.
//  Copyright (c) 2013 Extractor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, UIApplicationDelegate>
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longtitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *processListHeader;
@property (weak, nonatomic) IBOutlet UITextView *processListText;

@property(nonatomic, strong) NSDate *uploadTime;
@end
