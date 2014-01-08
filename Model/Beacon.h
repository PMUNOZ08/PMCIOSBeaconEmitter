//
//  Beacon.h
//  PMC_PlayyingWithBeacons
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beacon : NSObject


@property (nonatomic, copy) NSString *proximityUUID;
@property (nonatomic) NSNumber *major;
@property (nonatomic) NSNumber *minor;
@property (nonatomic) NSInteger proximity;
@property (nonatomic) CGFloat accuracy;
@property (nonatomic) NSInteger rssi;

@end
