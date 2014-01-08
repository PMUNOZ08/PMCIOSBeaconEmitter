//
//  SecondViewController.m
//  PMC_PlayyingWithBeacons
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

@import CoreLocation;

#ifdef ESTIMOTE_SDK
    @import SystemConfiguration;
    #import <ESTBeaconManager.h>
#endif

#import "RegionsNotificationsVC.h"

typedef NS_ENUM(NSInteger, RegionState) {
	RegionInside,
	RegionOutside
};


#ifndef ESTIMOTE_SDK
    @interface RegionsNotificationsVC () <CLLocationManagerDelegate>
#else
    @interface RegionsNotificationsVC () <ESTBeaconManagerDelegate>
#endif



#ifndef ESTIMOTE_SDK
    @property (nonatomic, strong) CLLocationManager *locManager;
#else
    @property (nonatomic, strong) ESTBeaconManager *beaconManager;
#endif
    @property (nonatomic, assign) RegionState beaconRegionState;
    @property (nonatomic, assign) RegionState fakeBeaconRegionState;

@end

@implementation RegionsNotificationsVC

static NSString *const beaconRegion = @"com.softpmc.Beacon";
static NSString *const beaconFakeRegion = @"com.softpmc.FakeBeacon";

#ifndef ESTIMOTE_SDK
- (CLLocationManager *)locManager{
    
    if (!_locManager) {
        _locManager = [[CLLocationManager alloc] init];
        _locManager.delegate = self;
    }
    return _locManager;
}
#else
- (ESTBeaconManager *)beaconManager{
    
    if (!_beaconManager) {
        _beaconManager = [[ESTBeaconManager alloc] init];
        _beaconManager.delegate = self;
    }
    return _beaconManager;
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.beaconRegionState = RegionOutside;
    self.fakeBeaconRegionState = RegionOutside;
    
#ifndef ESTIMOTE_SDK
    CLBeaconRegion *region;

    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDiBeacon] major:37620 identifier: beaconRegion];
    region.notifyEntryStateOnDisplay = YES;
    [self.locManager startMonitoringForRegion:region];
    
    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDiBeacon] major:37640 identifier: beaconFakeRegion];
    region.notifyEntryStateOnDisplay = YES;
    [self.locManager startMonitoringForRegion:region];

#else
    ESTBeaconRegion *region;
    
    region = [[ESTBeaconRegion alloc] initRegionWithMajor: 37620 identifier:beaconRegion];
    region.notifyEntryStateOnDisplay = YES;
    [self.beaconManager startMonitoringForRegion:region];
    
    region = [[ESTBeaconRegion alloc] initRegionWithMajor:37640 identifier: beaconFakeRegion];
    region.notifyEntryStateOnDisplay = YES;
    [self.beaconManager startMonitoringForRegion:region];

#endif

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#ifndef ESTIMOTE_SDK

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    NSMutableDictionary *info = [@{@"region":region} mutableCopy];
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
        [info setObject:@YES forKey:@"Inside"];
        
        if ([self notificateChangeStateForRegion:region withState:RegionInside]){
            [self sendLocalNotificationWithUserInfo:info];
            [self.locManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        }
        
    } else if(state == CLRegionStateOutside) {
        
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
        [info setObject:@YES forKey:@"Outside"];
        
        if ([self notificateChangeStateForRegion:region withState:RegionOutside]){
            [self sendLocalNotificationWithUserInfo:info];
            [self.locManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        }
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
        [self.locManager stopRangingBeaconsInRegion: (CLBeaconRegion *)region];
    }
}


#else

- (void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(ESTBeaconRegion *)region{
    
    NSMutableDictionary *info = [@{@"region":region} mutableCopy];
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
        [info setObject:@YES forKey:@"Inside"];
        
        if ([self notificateChangeStateForRegion:region withState:RegionInside]){
            [self sendLocalNotificationWithUserInfo:info];
            [self.beaconManager startRangingBeaconsInRegion:region];
        }
    } else if(state == CLRegionStateOutside) {
        
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
        [info setObject:@YES forKey:@"Outside"];
        
        if ([self notificateChangeStateForRegion:region withState:RegionOutside]){
            [self sendLocalNotificationWithUserInfo:info];
            [self.beaconManager stopRangingBeaconsInRegion:region];
        }
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
        [self.beaconManager stopRangingBeaconsInRegion: region];
    }

}

#endif


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        NSLog(@"Ranging works in background!!!  Beacons: %@ Hora: %@", beacons, [NSDate date]);
    }
}


- (void)sendLocalNotificationWithUserInfo:(NSDictionary *)info
{
    
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    
    NSString *insideOutside = [info[@"Inside"] isEqualToNumber:@YES] ? @"Inside" : @"Outside";
    
#ifndef ESTIMOTE_SDK
    CLBeaconRegion *region = info[@"region"];
#else
    ESTBeaconRegion *region = info[@"region"];
#endif
    notice.alertBody = [NSString stringWithFormat:@"%@ %@ region!", insideOutside, region.identifier];
    notice.alertAction = @"Open";
    notice.soundName = @"bingbong.aiff";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    
    
}

#pragma mark - Private

- (BOOL)notificateChangeStateForRegion:(CLRegion *)region withState:(RegionState)state{
    
    if ([region.identifier isEqualToString:beaconRegion]) {
        
        if (self.beaconRegionState != state) {
            self.beaconRegionState = state;
            return YES;
        }
    } else if ([region.identifier isEqualToString:beaconFakeRegion]) {
        
        if (self.fakeBeaconRegionState != state) {
            self.fakeBeaconRegionState = state;
            return YES;
        }
    }
    return NO;
}

@end
