//
//  BeaconCell.h
//  PMC_PlayyingWithBeacons
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMCBeaconCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbMajor;
@property (weak, nonatomic) IBOutlet UILabel *lbMinor;
@property (weak, nonatomic) IBOutlet UILabel *lbProximity;
@property (weak, nonatomic) IBOutlet UILabel *lbAccuaracy;
@property (weak, nonatomic) IBOutlet UILabel *lbRSSI;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewBeacon;
@end
