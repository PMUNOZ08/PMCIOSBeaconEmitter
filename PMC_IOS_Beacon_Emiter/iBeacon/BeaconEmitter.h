//
//  BeaconEmitter.h
//  PMC_IOS_Beacon_Emitter
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface BeaconEmitter : NSObject

@property (nonatomic, readonly, getter = isEmiting) BOOL emiting;

+ (BeaconEmitter *)sharedInstance;

- (void)startEmittingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;
- (void)stopEmitting;


@end
