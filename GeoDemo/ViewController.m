//
//  ViewController.m
//  GeoDemo
//
//  Created by Extractor on 11/16/13.
//  Copyright (c) 2013 Extractor. All rights reserved.
//

#import "ViewController.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <Foundation/NSURL.h>
#import <UIKit/UILocalNotification.h>
#import <Foundation/NSRegularExpression.h>

@interface ViewController ()


@end

const NSTimeInterval UPLOAD_INTERVAL = 20;
NSString *const UPLOAD_URL = @"http://localhost:1234/DyAuthen/storeMobileInfomation.php";

@implementation ViewController


- (void) prepareLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[UIApplication sharedApplication].delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionReceived:) name:@"RaiseQuestion" object:nil];
    [self prepareLocationManager];
    
    //[[[NSThread alloc]initWithTarget:self selector:@selector(updateProcessList) object:nil] start];
    
}

- (void) uploadAnswer: (NSString *)answer fromActivity: (NSString *)activityId
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    
    
    [content appendFormat:@"activity_id=%@&", activityId];
    [content appendFormat:@"detailedActivity=%@", answer];
    
    NSString *encodedBody = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [request setHTTPBody: [encodedBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:nil];
    
    //[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

- (void) questionReceived: (NSNotification *)notification
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:notification.userInfo[@"activity_id"] message:notification.userInfo[@"question"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *answer = [[alertView textFieldAtIndex:0] text];
    [self uploadAnswer:answer fromActivity:alertView.title];
}

- (void)updateProcessList
{
    while (true) {
        
        NSArray *processes = [self runningProcesses];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_processListText setText: [[self runningProcesses] componentsJoinedByString:@"\n"]];
            [_processListHeader setText:[NSString stringWithFormat:@"List of Processes (%d):", [processes count]]];
        }];
        
        [NSThread sleepForTimeInterval: 1.0];
    }
}

- (NSString *) searchString: (NSString *)string withRegex: (NSString *)regexStr
{
    NSError *err = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&err];
    if (err) return nil;
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        return [string substringWithRange:rangeOfFirstMatch];
    }
    return nil;
}


- (NSDictionary *) parseResponse: (NSString *)resString
{
    NSString *activityID =[self searchString:resString withRegex:@"&.*\\s"];
    if (!activityID) return nil;
    activityID = [activityID substringWithRange:NSMakeRange(1, activityID.length - 2)];
    
    NSString *question =[self searchString:resString withRegex:@"\\*\\*.*$"];
    if (!question) return nil;
    question = [question substringFromIndex:2];
    
    return @{
             @"activity_id": activityID,
             @"question": question
             };
}

- (void) uploadInfoWithLocation: (CLLocation *) location
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    
    
    [content appendFormat:@"device_model=%@&", [self hardwareString]];
    [content appendFormat:@"mem_info=%u&", [self freeMemory]];
    [content appendFormat:@"gps_info=%f|%f|%f|%@&",
        location.coordinate.longitude,
        location.coordinate.latitude,
        location.altitude,
        [NSDate date]];
    
    [content appendFormat:@"process=%@", [[self runningProcesses] componentsJoinedByString:@"\n"]];
    
    NSString *encodedBody = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [request setHTTPBody: [encodedBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *resBody = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (resBody.length > 0) {
        NSString *resString = [[NSString alloc] initWithData:resBody encoding:NSUTF8StringEncoding];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.userInfo = [self parseResponse:resString];
        if (!notification.userInfo) return;
        notification.alertBody = notification.userInfo[@"question"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
    }
    
   // NSLog(@"%@", location);
}




- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations firstObject];
    
    if (currentLocation != nil) {
        NSLog(@"%f", [_uploadTime timeIntervalSinceNow]);
        
        if (_uploadTime == nil || [_uploadTime timeIntervalSinceNow] <= -UPLOAD_INTERVAL) {
            [self uploadInfoWithLocation:currentLocation];
            _uploadTime = [NSDate date];
        }
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
            _longtitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        }
    }
}

- (natural_t)freeMemory {
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    
    //natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * pagesize;
    //natural_t   mem_total = mem_used + mem_free;
    
    return mem_free;
}


- (NSArray *)runningProcesses
{//Reference: http://stackoverflow.com/questions/4312613/can-we-retrieve-the-applications-currently-running-in-iphone-and-ipad
    
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0)
    {
        if (size % sizeof(struct kinfo_proc) == 0)
        {
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess)
            {
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    //NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    /*
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
                     */
                    [array addObject:[NSString stringWithFormat:@"%@", processName]];
                    
                }
                free(process);
                return array;
            }
        }
    }
    
    return nil;
}

- (NSString*)hardwareString
{
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
