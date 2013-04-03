//
//  ViewController.h
//  GeoAuth
//
//  Created by Jacob Okamoto on 1/31/13.
//  Copyright (c) 2013 Jacob Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MKNetworkEngine.h>
#import <MKNetworkOperation.h>

@interface ViewController : UIViewController

- (IBAction)sendUpdate:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *deviceKey;
@property (weak, nonatomic) IBOutlet UITextField *deviceName;
- (IBAction)registerDevice:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *notifier;

@property (strong, nonatomic) MKNetworkEngine *networkEngine;

@end
