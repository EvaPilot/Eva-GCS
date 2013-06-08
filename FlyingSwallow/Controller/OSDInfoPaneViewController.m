//
//  OSDInfoPaneViewController.m
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "OSDInfoPaneViewController.h"
#import "Macros.h"


@interface OSDInfoPaneViewController (){
    BOOL infoPaneIsVisible;
}

@end

@implementation OSDInfoPaneViewController
@synthesize osdData = _osdData;

- (void)setOsdData:(EvaOSDData *)osdData{
    [_osdData release];
    _osdData = [osdData retain];
    [self updateUI];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(EvaOSDData *)osdData{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _osdData = [osdData retain];
        infoPaneIsVisible = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_osdData release];
    [rollTextLabel release];
    [longitudeTextLabel release];
    [latitudeTextLabel release];
    [altitudeTextLabel release];
    [pitchTextLabel release];
    [satCountTextLabel release];
    [gpsVelocityXTextLabel release];
    [gpsVelocityYTextLabel release];
    [flightModeTextLabel release];
    [distanceToHomeTextLabel release];
    [mobileSatCount release];
    [headAngleTextLabel release];
    [voltageTextLabel release];
    [currentTextLabel release];
    [consumedCurrentTextLabel release];
    [aileronValueTextLabel release];
    [elevatorValueTextLabel release];
    [throttleValueTextLabel release];
    [yawValueTextLabel release];
    [manualAileronValueTextLabel release];
    [manualThrottleValueTextLabel release];
    [manualYawValueTextLabel release];
    [vibrateStateTextLabel release];
    [shakeStateTextLabel release];
    [manualElevatorValueTextLabel release];
    [rcControlModeTextLabel release];
    [airlineStateTextLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [rollTextLabel release];
    rollTextLabel = nil;
    [longitudeTextLabel release];
    longitudeTextLabel = nil;
    [latitudeTextLabel release];
    latitudeTextLabel = nil;
    [altitudeTextLabel release];
    altitudeTextLabel = nil;
    [pitchTextLabel release];
    pitchTextLabel = nil;
    [satCountTextLabel release];
    satCountTextLabel = nil;
    [gpsVelocityXTextLabel release];
    gpsVelocityXTextLabel = nil;
    [gpsVelocityYTextLabel release];
    gpsVelocityYTextLabel = nil;
    [flightModeTextLabel release];
    flightModeTextLabel = nil;
    [distanceToHomeTextLabel release];
    distanceToHomeTextLabel = nil;
    [mobileSatCount release];
    mobileSatCount = nil;
    [headAngleTextLabel release];
    headAngleTextLabel = nil;
    [voltageTextLabel release];
    voltageTextLabel = nil;
    [currentTextLabel release];
    currentTextLabel = nil;
    [consumedCurrentTextLabel release];
    consumedCurrentTextLabel = nil;
    [aileronValueTextLabel release];
    aileronValueTextLabel = nil;
    [elevatorValueTextLabel release];
    elevatorValueTextLabel = nil;
    [throttleValueTextLabel release];
    throttleValueTextLabel = nil;
    [yawValueTextLabel release];
    yawValueTextLabel = nil;
    [manualAileronValueTextLabel release];
    manualAileronValueTextLabel = nil;
    [manualThrottleValueTextLabel release];
    manualThrottleValueTextLabel = nil;
    [manualYawValueTextLabel release];
    manualYawValueTextLabel = nil;
    [vibrateStateTextLabel release];
    vibrateStateTextLabel = nil;
    [shakeStateTextLabel release];
    shakeStateTextLabel = nil;
    [manualElevatorValueTextLabel release];
    manualElevatorValueTextLabel = nil;
    [rcControlModeTextLabel release];
    rcControlModeTextLabel = nil;
    [airlineStateTextLabel release];
    airlineStateTextLabel = nil;
    [super viewDidUnload];
}

- (void)updateFilghtModeUI:(flight_mode_t)flightMode{
    NSString *flightModeStr = nil;
    
    switch (flightMode) {
        case FlightModeManual:
            flightModeStr = getLocalizeString(@"Manual");
            break;
        case FlightModeAutoHovering :
            flightModeStr = getLocalizeString(@"GPS Hover");
            break;
        case FlightModeAutoNavigation:
            flightModeStr = getLocalizeString(@"Auto Navigation");
            break;
        case FlightModeCirclePosition:
            flightModeStr = getLocalizeString(@"Circle");
            break;
        case FlightModeRealtimeWaypoint:
            flightModeStr = getLocalizeString(@"Target");
            break;
        case FlightModeAutoWaypointCircling:
            flightModeStr = getLocalizeString(@"Auto Waypoint Circling");
            break;
        case FlightModeSemiAutomatic:
            flightModeStr = getLocalizeString(@"Semi Auto");
            break;
        case FlightModeSettingsState:
            flightModeStr = getLocalizeString(@"Setting");
            break;
        case FlightModeZeroGyro:
            flightModeStr = getLocalizeString(@"Zero Gyro");
            break;
        case FlightModeAltitudeError:
            flightModeStr = getLocalizeString(@"Alt Error");
            break;
        case FlightModeAirSpeedError:
            flightModeStr = getLocalizeString(@"Air Speed Error");
            break;
        case FlightModeBackLanding:
            flightModeStr = getLocalizeString(@"Landing");
            break;
        case FlightModeMunualSetAltitude:
            flightModeStr = getLocalizeString(@"Alt Hold");
            break;
        default:
            flightModeStr = getLocalizeString(@"Unknown");
            break;
    }
    
    flightModeTextLabel.text = flightModeStr;
}

- (NSString *)getFlightModeName{
    return flightModeTextLabel.text;
}

- (void)updateUI{
    rollTextLabel.text = [NSString stringWithFormat:@"%.1f", _osdData.roll];
    pitchTextLabel.text = [NSString stringWithFormat:@"%.1f", _osdData.pitch];
    headAngleTextLabel.text = [NSString stringWithFormat:@"%.1f", _osdData.headAngle];
    longitudeTextLabel.text = [NSString stringWithFormat:@"%.2f", _osdData.longitude];
    latitudeTextLabel.text = [NSString stringWithFormat:@"%.2f", _osdData.latitude];
    altitudeTextLabel.text = [NSString stringWithFormat:@"%.2f", _osdData.altitude];
    satCountTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.satCount];
    gpsVelocityXTextLabel.text = [NSString stringWithFormat:@"%.2fm/s", _osdData.gpsVelocityX / 100.0];
    gpsVelocityYTextLabel.text = [NSString stringWithFormat:@"%.2fm/s", _osdData.gpsVelocityY / 100.0];
    [self updateFilghtModeUI:_osdData.flightMode];
    distanceToHomeTextLabel.text = [NSString stringWithFormat:@"%dm", _osdData.distanceToHome];
    mobileSatCount.text = [NSString stringWithFormat:@"%d", _osdData.mobileSatCount];
    
    voltageTextLabel.text = [NSString stringWithFormat:@"%.2fV", _osdData.voltage];
    currentTextLabel.text = [NSString stringWithFormat:@"%dA", _osdData.current];
    consumedCurrentTextLabel.text = [NSString stringWithFormat:@"%dmAH", _osdData.consumedCurrent];
    
    aileronValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.aileronValue];
    elevatorValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.elevatorValue];
    throttleValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.throttleValue];
    yawValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.yawValue];
    
    manualAileronValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.manualAileronValue];
    manualElevatorValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.manualElevatorValue];
    manualThrottleValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.manualThrottleValue];
    manualYawValueTextLabel.text = [NSString stringWithFormat:@"%d", _osdData.manualYawValue];
    
    if (_osdData.physicalRcEnabled) {
        rcControlModeTextLabel.text = getLocalizeString(@"Physical Control");
    }
    else{
        rcControlModeTextLabel.text = getLocalizeString(@"Touch Control");
    }
    
    airlineStateTextLabel.text = [NSString stringWithFormat:@"%d/%d", _osdData.finishedWaypointCount, _osdData.waypointCount];
}

- (IBAction)switchInfoPaneVisibleState:(id)sender {
    [self setInfoPaneVisibleState:!infoPaneIsVisible];
}

- (void)setInfoPaneVisibleState:(BOOL)visible{
    if (visible == infoPaneIsVisible) {
        return;
    }
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGPoint newCenter;
    
    if (visible) {
        newCenter = CGPointMake(appFrame.size.height / 2.0, self.view.center.y - 320);
        
        [UIView animateWithDuration:0.35
                         animations:^{
                             self.view.center = newCenter;
                         } completion:^(BOOL finished){
                             infoPaneIsVisible = YES;
                         }];
    }
    else{
        newCenter = CGPointMake(appFrame.size.height / 2.0, self.view.center.y + 320);
        
        [UIView animateWithDuration:0.35
                         animations:^{
                             self.view.center = newCenter;
                         } completion:^(BOOL finished){
                             infoPaneIsVisible = NO;
                         }];
    }
}

@end
