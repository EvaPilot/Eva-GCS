//
//  HudViewController.h
//  FlyingSwallow
//
//  Created by koupoo on 12-12-21. Email: liaojinhua@angeleyes.it 
//  Copyright (c) 2012年 www.hexairbot.com. All rights reserved.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License V2
//  as published by the Free Software Foundation.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ConfigViewController.h"
#import "Channel.h"
#import "Settings.h"
#import "EvaAirlineUploader.h"
#import "FlightModeViewController.h"
#import "WaypointViewController.h"
#import "WaypointAnnotationView.h"

typedef enum{
	ViewBlockViewINVALID = 0,
    ViewBlockJoyStickHud,
    ViewBlockJoyStickHud2,
    ViewBlockTotalUi,
	ViewBlockViewMAX
}HudViewBlockView;

@interface HudViewController : UIViewController<ConfigViewControllerDelegate,EvaAirlineUploaderDelegate, FlightModeViewControlDelegate, WaypointViewControllerDelegate, WaypointAnnotationViewDelegate, MKMapViewDelegate>{
    IBOutlet UILabel *batteryLevelLabel;
    
    IBOutlet UIImageView *batteryImageView;

    IBOutlet UIButton *configButton;
    IBOutlet UIButton *joystickLeftButton;
    IBOutlet UIButton *joystickRightButton;
    
    IBOutlet UIImageView *joystickLeftThumbImageView;
    IBOutlet UIImageView *joystickLeftBackgroundImageView;
    IBOutlet UIImageView *joystickRightThumbImageView;
    IBOutlet UIImageView *joystickRightBackgroundImageView;
    
    IBOutlet UILabel *statusInfoLabel;
    IBOutlet UILabel *throttleValueLabel;
    IBOutlet UIButton *rudderLockButton;
    
    IBOutlet UIButton *throttleUpButton;
    IBOutlet UIButton *throttleDownButton;
    IBOutlet UIImageView *downIndicatorImageView;
    IBOutlet UIImageView *upIndicatorImageView;
    
    IBOutlet UIButton *followButton;
    
    IBOutlet MKMapView *mapView;    
    
    IBOutlet UILabel *airlineNameTextLabel;
    IBOutlet UILabel *waypointCountTextLabel;
    IBOutlet UILabel *airlineDistanceTextLabel;
    
    IBOutlet UIButton *myLocationLocateButton;
    IBOutlet UIButton *droneLocationLocatButton;
    
    IBOutlet UIImageView *hudDownPartImageView;
    
    IBOutlet UILabel *flightModeTextLabel;
    IBOutlet UILabel *airlineManagementTextLabel;
    IBOutlet UILabel *autoTakeoffTextLabel;
    IBOutlet UILabel *landingTextLabel;
    IBOutlet UILabel *headFreeDisableTextLabel;
    IBOutlet UILabel *headFreeEnableTextLabel;
    IBOutlet UILabel *configTextLabel;
    
    IBOutlet UILabel *mapIsEnableTextLabel;
    
    IBOutlet UIView *airlineManagmentMenu;
    
    IBOutlet UILabel *airlineListTextLabel;
    IBOutlet UILabel *airlineCloseTextLabel;
    IBOutlet UILabel *airlineClearTextLabel;
    IBOutlet UILabel *airineStartTextLabel;
    IBOutlet UILabel *airlineUploadTextLabel;
    IBOutlet UILabel *airlineSaveTextLabel;

    IBOutlet UILabel *droneLocateTextLabel;
    
    IBOutlet UILabel *altIncreaseTextLabel;
    IBOutlet UILabel *altDecreaseTextLabel;
    IBOutlet UILabel *myPositionLocateTextLabel;
    
    IBOutlet UILabel *satCountTextLabel;
    IBOutlet UILabel *satCountValueTextLabel;
    IBOutlet UILabel *voltTextLabel;
    IBOutlet UILabel *voltValueTextLabel;
    IBOutlet UILabel *altTextLabel;
    IBOutlet UILabel *altValueTextLabel;
    IBOutlet UILabel *orientationTextLabel;
    IBOutlet UILabel *orientationValueTextLabel;
    IBOutlet UILabel *droneStatusTextLabel;
    
    IBOutlet UILabel *connectionStatusTextLabel;
    
    IBOutlet UIButton *flightModeButton;
    
    IBOutlet UIButton *airlineManagementButton;

    IBOutlet UIButton *rcControlModeSwitchButton;
    
    IBOutlet UIView *airlineListView;
    IBOutlet UIView *airlineEnableView;
    IBOutlet UIView *airlineDisableView;
    IBOutlet UIView *airlineSaveView;
    IBOutlet UIView *airlineUploadView;
    IBOutlet UIView *airlineClearView;
    IBOutlet UIView *airlineAbandonView;
    IBOutlet UIView *airlineAltitudeChangeView;
    
    IBOutlet UIButton *airlineListButton;
    IBOutlet UIButton *airlineDisableButton;
    IBOutlet UIButton *airlineEnableButton;
    IBOutlet UIButton *airlineSaveButton;
    IBOutlet UIButton *airlineUploadButton;
    IBOutlet UIButton *airlineClearButton;
    IBOutlet UIButton *airlineAbandonButton;
    IBOutlet UIButton *airlineAltitudeChangeButton;
    
    IBOutlet UIView *pointFlightMenu;
    IBOutlet UIView *circleFlightMenu;
    
    IBOutlet UILabel *demoGcsLongitude;
    IBOutlet UILabel *demoGcsLatitude;
}

@property (retain, nonatomic) IBOutlet UITextView *debugTextView;

- (IBAction)joystickButtonDidTouchDown:(id)sender forEvent:(UIEvent *)event;
- (IBAction)josystickButtonDidTouchUp:(id)sender forEvent:(UIEvent *)event;
- (IBAction)joystickButtonDidDrag:(id)sender forEvent:(UIEvent *)event;

- (IBAction)takoffButtonDidTouchDown:(id)sender;
- (IBAction)takeoffButtonDidTouchUp:(id)sender;

- (IBAction)throttleStopButtonDidTouchDown:(id)sender;
- (IBAction)throttleStopButtonDidTouchUp:(id)sender;

- (IBAction)buttonDidTouchDown:(id)sender;
- (IBAction)buttonDidDragEnter:(id)sender;
- (IBAction)buttonDidDragExit:(id)sender;
- (IBAction)buttonDidTouchUpInside:(id)sender;
- (IBAction)buttonDidTouchUpOutside:(id)sender;
- (IBAction)buttonDidTouchCancel:(id)sender;

- (IBAction)unlockMotor:(id)sender;
- (IBAction)autoTakeoff:(id)sender;
- (IBAction)backAndLanding:(id)sender;

- (IBAction)enableFollow:(id)sender;
- (IBAction)enableCarefree:(id)sender;
- (IBAction)disableCarefree:(id)sender;
 
- (IBAction)showAirlineList:(id)sender;
- (IBAction)enterAirlineManagementMenu:(id)sender;
- (IBAction)saveAirline:(id)sender;
- (IBAction)clearAirline:(id)send;
- (IBAction)exitAirlineManagementMenu:(id)sender;
- (IBAction)uploadAndVerifyAirline:(id)sender;
- (IBAction)enableAirline:(id)sender;
- (IBAction)disableAirline:(id)sender;
- (IBAction)changeAltitude:(id)sender;

- (IBAction)locateToMyPosition:(id)sender;
- (IBAction)locateToDronePosition:(id)sender;

- (IBAction)choseFlightMode:(id)sender;

- (IBAction)exitPointFlightMenu:(id)sender;
- (IBAction)cancelPointFlight:(id)sender;
- (IBAction)enterPointFlightMenu:(id)sender;

- (IBAction)exitCirleFlightMenu:(id)sender;
- (IBAction)cancelCircleFlight:(id)sender;
- (IBAction)ernterCircleFlightMenu:(id)sender;

- (IBAction)setMapEnable:(id)sender;

- (IBAction)hideDemoLabel:(id)sender;

- (IBAction)switchRcControlMode:(id)sender;


@end
