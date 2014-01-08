//
//  PMCSearchingVC.m
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

#import "PMCSearchingVC.h"
#import "Beacon.h"

#import "PMCBeaconCell.h"

//Constants for major property. Help to determine the kind and color of beacons

static const unsigned short greenBeacon = 37620;
static const unsigned short purpleBeacon = 20096;
static const unsigned short blueBeacon = 47829;
static const unsigned short mbaBeacon = 37630;

#ifndef ESTIMOTE_SDK
    @interface PMCSearchingVC () <CLLocationManagerDelegate>
#else
    @interface PMCSearchingVC () <ESTBeaconManagerDelegate>
#endif


@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopStartSearching;

#ifndef ESTIMOTE_SDK
    @property (nonatomic, strong) CLLocationManager *locManager;
    @property (nonatomic, strong) CLBeaconRegion *beaconRegion;
#else
    @property (nonatomic, strong) ESTBeaconManager *beaconManager;
    @property (nonatomic, strong) ESTBeaconRegion *beaconRegionEst;
#endif


@property (nonatomic, strong) NSMutableArray *beaconsArray;

@property (nonatomic) BOOL isSearching;

@end

@implementation PMCSearchingVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.beaconsArray = [[NSMutableArray alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isSearching) [self startStopSearching:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellBeacon";
    
    PMCBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Beacon *beacon = [self.beaconsArray objectAtIndex:indexPath.row];

    [self configureCell:cell withBeacon:beacon];
    
    return cell;
}


- (PMCBeaconCell *)configureCell:(PMCBeaconCell *)cell withBeacon:(Beacon *)iBeacon{

    NSString *proximityText = nil;
    
    switch (iBeacon.proximity) {
        case 0:
            proximityText = @"0-Unknown";
            break;
        case 1:
            proximityText = @"1-Immediate";
            break;
        case 2:
            proximityText = @"2-Near";
            break;
        case 3:
            proximityText = @"3-Far";
            break;
        default:
            break;
    }
    
    cell.lbMajor.text = [iBeacon.major stringValue];
    cell.lbMinor.text = [iBeacon.minor stringValue];
    cell.lbProximity.text = proximityText;
    cell.lbRSSI.text = [NSString stringWithFormat:@"%d dB", iBeacon.rssi];
    
#ifndef ESTIMOTE_SDK
    cell.lbAccuaracy.text = [NSString stringWithFormat:@"%0.2fm", iBeacon.accuracy];
#else
    ESTBeacon *iBeaconEst = (ESTBeacon *)iBeacon;
    cell.lbAccuaracy.text = [NSString stringWithFormat:@"%0.2fm", [iBeaconEst.distance floatValue]];
#endif
    
    cell.imageView.image = [self imageForBeaconWithMajor:iBeacon.major];
    return cell;
}



#pragma mark - Private

- (UIImage *)imageForBeaconWithMajor:(NSNumber *)major{
    
    switch ([major integerValue]) {
        case greenBeacon:
            return [UIImage imageNamed:@"greenBeacon"];
            break;
        case blueBeacon:
            return [UIImage imageNamed:@"blueBeacon"];
            break;
        case purpleBeacon:
            return [UIImage imageNamed:@"purpleBeacon"];
            break;
        case mbaBeacon:
            return [UIImage imageNamed:@"mbaBeacon"];
            break;
        default:
            return [UIImage imageNamed:@"iosBeacon"];
            break;
    }
}

#pragma mark - Actions


- (IBAction)startStopSearching:(id)sender {
    
    if (self.isSearching) {
        self.isSearching = NO;
        self.stopStartSearching.title = @"Start";
        [self stopSearching];
    } else {
        self.isSearching = YES;
        self.stopStartSearching.title = @"Stop";
        [self startSearching];
    }
}


-(void)startSearching {
    
    
#ifndef ESTIMOTE_SDK
    
    self.locManager = [[CLLocationManager alloc] init];
    [self.locManager setDelegate:self];
    
    if ([CLLocationManager isRangingAvailable]) {
        
        NSLog(@"Beacon ranging available");
        
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:UUIDiBeacon];
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"com.softpmc.beacons"];

        [self.beaconRegion setNotifyEntryStateOnDisplay:YES];
        [self.beaconRegion setNotifyOnEntry:NO];
        [self.beaconRegion setNotifyOnExit:NO];
        
        [self.locManager startMonitoringForRegion:self.beaconRegion];
        
    }
    
#else
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
        
    NSLog(@"Beacon ranging available");
    self.beaconRegionEst = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"com.softpmc.beacons"];
    
    [self.beaconRegionEst setNotifyEntryStateOnDisplay:YES];
    [self.beaconRegionEst setNotifyOnEntry:NO];
    [self.beaconRegionEst setNotifyOnExit:NO];
    
    [self.beaconManager startMonitoringForRegion:self.beaconRegionEst];
        
#endif
    
}


-(void)stopSearching {
    
#ifndef ESTIMOTE_SDK
    if ([CLLocationManager isRangingAvailable]) {
        
        [self.locManager stopMonitoringForRegion:self.beaconRegion];
        self.beaconRegion = nil;
        
    }
    self.locManager = nil;
#else
    [self.beaconManager stopMonitoringForRegion:self.beaconRegionEst];
    self.beaconManager = nil;
    self.beaconRegionEst = nil;
#endif
    
    [self.beaconsArray removeAllObjects];
    [self.tableView reloadData];
    
    
}




#ifndef ESTIMOTE_SDK

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state == CLRegionStateInside) {
        
        [self.locManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    } else {

        [self.locManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSLog(@"Beacons: %@", beacons);
    
    [self.beaconsArray removeAllObjects];
    
    if ([beacons count] != 0) {
        
        for (CLBeacon *beacon in beacons) {
            
                Beacon *newBeaconRecord = [[Beacon alloc] init];
                [newBeaconRecord setProximityUUID:[beacon.proximityUUID UUIDString]];
                [newBeaconRecord setMajor:beacon.major];
                [newBeaconRecord setMinor:beacon.minor];
                [newBeaconRecord setProximity:beacon.proximity];
                [newBeaconRecord setAccuracy:beacon.accuracy];
                [newBeaconRecord setRssi:beacon.rssi];
                
                [self.beaconsArray addObject:newBeaconRecord];
            
        }
    }
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Beacon Ranging Failed");
}

#else

#pragma mark - ESTBeaconManagerDelegate

- (void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(ESTBeaconRegion *)region{
    
    if (state == CLRegionStateInside) {
        
        [self.beaconManager startRangingBeaconsInRegion:region];
    } else {
        
        [self.beaconManager stopRangingBeaconsInRegion: region];
    }
}


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region {
    
    if ([beacons count] != 0) {
        
        self.beaconsArray = [beacons mutableCopy];
    }
    [self.tableView reloadData];
    
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error{
     NSLog(@"Beacon Ranging Failed");
}
#endif


@end
