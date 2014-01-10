//
//  BeaconEmitter.m
//  PMC_IOS_Beacon_Emitter
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

#import "BeaconEmitter.h"

@import CoreBluetooth;

NSString * const kBeaconIdentifier = @"com.sodtpmc.iosbeaconemiter";

@interface BeaconEmitter () <CBPeripheralManagerDelegate>

@property (nonatomic, readwrite, getter = isAEmiting) BOOL emiting;

@end

@implementation BeaconEmitter {
    
    CBPeripheralManager *_peripheralManager;
}


+ (BeaconEmitter *)sharedInstance {
    static BeaconEmitter *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    return self;
}

- (void)startEmittingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    NSError *bluetoothStateError = nil;
    
    if (![self bluetoothStateValid:&bluetoothStateError]) {
        [[[UIAlertView alloc] initWithTitle:@"Bluetooth Issue" message:bluetoothStateError.userInfo[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    CLBeaconRegion *region;
    if (uuid && major && minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:kBeaconIdentifier];
    } else if (uuid && major) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:kBeaconIdentifier];
    } else if (uuid) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kBeaconIdentifier];
    } else {
        [NSException raise:@"You must at least provide a UUID to start advertising" format:nil];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:peripheralData];
}

- (void)stopEmitting {
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [_peripheralManager stopAdvertising];
    self.emiting = NO;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSError *bluetoothStateError = nil;
    if (![self bluetoothStateValid:&bluetoothStateError]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *bluetoothIssueAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Issue" message:bluetoothStateError.userInfo[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [bluetoothIssueAlert show];
        });
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Cannot Emit Beacon" message:@"There was an issue starting the advertisement of your beacon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Start Emitting Error: %@", error);
        } else {
            NSLog(@"Emitting!");
            self.emiting = YES;
        }
    });
}

- (BOOL)bluetoothStateValid:(NSError **)error {
    BOOL bluetoothStateValid = YES;
    switch (_peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOff:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.softpmc.I'm-a-beacon.bluetoothstate"
                                             code:CBPeripheralManagerStatePoweredOff
                                         userInfo:@{@"message": @"You must turn Bluetooth on in order to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateResetting:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.softpmc.I'm-a-beacon.bluetoothstate"
                                             code:CBPeripheralManagerStateResetting
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnauthorized:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.softpmc.I'm-a-beacon.bluetoothstate"
                                             code:CBPeripheralManagerStateUnauthorized
                                         userInfo:@{@"message": @"This application is not authorized to use Bluetooth, verify your settings or check with your device's administrator"}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnknown:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.softpmc.I'm-a-beacon.bluetoothstate"
                                             code:CBPeripheralManagerStateUnknown
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnsupported:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.softpmc.I'm-a-beacon.bluetoothstate"
                                             code:CBPeripheralManagerStateUnsupported
                                         userInfo:@{@"message": @"Your device does not support Bluetooth. You will not be able to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStatePoweredOn:
            bluetoothStateValid = YES;
            break;
    }
    
    return bluetoothStateValid;
}




@end
