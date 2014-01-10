//
//  ViewController.m
//  PMC_IOS_Beacon_Emiter
//
//  Created by PEDRO MUÑOZ CABRERA on 15/12/13.
//  Copyright (c) 2013 Pedro Muñoz Cabrera. All rights reserved.
//

#import "ViewController.h"

#import "BeaconEmitter.h"

#define kConstantKeyboardHidden 237.f

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lbState;
@property (weak, nonatomic) IBOutlet UILabel *lbMajor;
@property (weak, nonatomic) IBOutlet UILabel *lbMinor;
@property (weak, nonatomic) IBOutlet UILabel *lbUUID;

@property (weak, nonatomic) IBOutlet UITextField *textMajor;
@property (weak, nonatomic) IBOutlet UITextField *textMinor;

@property (strong, nonatomic) IBOutlet UISwitch *switchEmitter;

@property (nonatomic) NSInteger minor;
@property (nonatomic) NSInteger major;
@property (nonatomic) NSString *identifier;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrBottom;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.major = 37640;
    self.minor = 51128;
    self.identifier = @"com.sodtpmc.iosbeaconemiter";
    
    self.lbUUID.text = UUIDiBeacon;
    
    self.lbMajor.text = [NSString stringWithFormat:@"%i", self.major];
    self.lbMinor.text = [NSString stringWithFormat:@"%i", self.minor];
    self.textMajor.text = self.lbMajor.text;
    self.textMinor.text = self.lbMinor.text;

    self.lbState.text = @"No Emitting";
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Emitting

-(void)startEmitting {

    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:UUIDiBeacon];
    self.lbState.text = @"Emitting";
    [[BeaconEmitter sharedInstance]startEmittingUUID:proximityUUID
                                               major:self.major minor:self.minor];
}

-(void)stopEmitting {
    
    [[BeaconEmitter sharedInstance] stopEmitting];
     self.lbState.text = @"No Emitting";
}


#pragma mark - Actions

- (IBAction)updateValues:(id)sender {

    self.major = [self.textMajor.text integerValue];
    self.minor = [self.textMinor.text integerValue];
    
    self.lbMajor.text = [NSString stringWithFormat:@"%i", self.major];
    self.lbMinor.text = [NSString stringWithFormat:@"%i", self.minor];
    
    [self.view endEditing:YES];
    
    [self stopEmitting];
    [self startEmitting];

}
- (IBAction)changedEmiting:(UISwitch *)sender {
    
    sender.on ? [self startEmitting] : [self stopEmitting];
    
}
- (IBAction)didTapInView:(id)sender {
    
    [self.view endEditing:YES];
}



#pragma mark - KeyboardDelegate

-(void)keyboardWillShow:(NSNotification *)notification { // UIKeyboardWillShowNotification
    
    NSDictionary *info = [notification userInfo];
    NSValue *keyboardFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat keyboardHeight = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    
    // constrBottom is a constraint defining distance between bottom edge of view and bottom edge of its superview
    self.constrBottom.constant = kConstantKeyboardHidden-keyboardHeight + 40;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification { // UIKeyboardWillHideNotification
    
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.constrBottom.constant = kConstantKeyboardHidden;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
