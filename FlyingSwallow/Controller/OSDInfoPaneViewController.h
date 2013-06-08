//
//  OSDInfoPaneViewController.h
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaOSDData.h"



@interface OSDInfoPaneViewController : UIViewController{
    IBOutlet UILabel *rollTextLabel;
    IBOutlet UILabel *pitchTextLabel;
    IBOutlet UILabel *headAngleTextLabel;
    IBOutlet UILabel *longitudeTextLabel;
    IBOutlet UILabel *latitudeTextLabel;
    IBOutlet UILabel *altitudeTextLabel;
    IBOutlet UILabel *satCountTextLabel;
    IBOutlet UILabel *gpsVelocityXTextLabel;
    IBOutlet UILabel *gpsVelocityYTextLabel;
    IBOutlet UILabel *flightModeTextLabel;
    IBOutlet UILabel *distanceToHomeTextLabel;
    IBOutlet UILabel *mobileSatCount;
    IBOutlet UILabel *voltageTextLabel;
    IBOutlet UILabel *currentTextLabel;
    IBOutlet UILabel *consumedCurrentTextLabel;
    
    IBOutlet UILabel *aileronValueTextLabel;
    IBOutlet UILabel *elevatorValueTextLabel;
    IBOutlet UILabel *throttleValueTextLabel;
    IBOutlet UILabel *yawValueTextLabel;
    
    IBOutlet UILabel *manualAileronValueTextLabel;
    IBOutlet UILabel *manualElevatorValueTextLabel;
    IBOutlet UILabel *manualThrottleValueTextLabel;
    IBOutlet UILabel *manualYawValueTextLabel;
    
    IBOutlet UILabel *vibrateStateTextLabel;
    IBOutlet UILabel *shakeStateTextLabel;
    
    IBOutlet UILabel *rcControlModeTextLabel;
    
    IBOutlet UILabel *airlineStateTextLabel;
    
}

@property(nonatomic, retain) EvaOSDData *osdData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(EvaOSDData *)osdData;

- (void)updateUI;

- (IBAction)switchInfoPaneVisibleState:(id)sender;
- (void)setInfoPaneVisibleState:(BOOL)visible;

- (NSString *)getFlightModeName;


@end
