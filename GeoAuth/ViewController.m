//
//  ViewController.m
//  GeoAuth
//
//  Created by Jacob Okamoto on 1/31/13.
//  Copyright (c) 2013 Jacob Okamoto. All rights reserved.
//

#import "ViewController.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize networkEngine;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    networkEngine = [[MKNetworkEngine alloc] initWithHostName:@"cs5221.oko.io:8000"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendUpdate:(id)sender {
    MKNetworkEngine* ne = [[MKNetworkEngine alloc] initWithHostName:@"cs5221.oko.io:8000"];
    
    NSMutableDictionary* md = [[NSMutableDictionary alloc] init];
    NSData *keyData = [[NSUserDefaults standardUserDefaults] dataForKey:@"GEOAUTH_DEVICE_ID"];
    NSLog(@"KeySize: %d", [keyData length]);
    NSString *dev_id = [[NSString alloc] initWithData:keyData encoding:NSASCIIStringEncoding];
    if(dev_id == nil) dev_id = @"852d106e102342c2911455998cf7e637";
    [md setValue:dev_id forKey:@"device_id"];
    [md setValue:@"44.972024" forKey:@"latitude"];
    [md setValue:@"-93.225174" forKey:@"longitude"];
    [md setValue:@"2013-04-02 23:24:48" forKey:@"time"];
    
    MKNetworkOperation* op = [ne operationWithPath:@"api/device/check-in" params:md httpMethod:@"POST"];
    [ne enqueueOperation:op];
}
- (IBAction)registerDevice:(id)sender {
    NSString *dkey = self.deviceKey.text;
    NSString *dname = self.deviceName.text;
    if([dkey length] == 32 && [dname length] > 0) {
        
        NSMutableDictionary* md = [[NSMutableDictionary alloc] init];
        [md setValue:self.deviceKey.text forKey:@"device_key"];
        [md setValue:self.deviceName.text forKey:@"device_name"];
        [md setValue:@"okam0013" forKey:@"username"];
        [md setValue:@"porkchop" forKey:@"password"];
        
        MKNetworkOperation* op = [networkEngine operationWithPath:@"api/device/register" params:md httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString *dev_id = [completedOperation responseString];
            [[NSUserDefaults standardUserDefaults] setValue:dev_id forKey:@"GEOAUTH_DEVICE_ID"];
            NSLog(@"Set Device ID to: %@", dev_id);
        }errorHandler:nil];
        [networkEngine enqueueOperation:op];
        
    } else {
        [self.notifier setText:@"Invalid key and/or missing name"];
    }
}

@end
