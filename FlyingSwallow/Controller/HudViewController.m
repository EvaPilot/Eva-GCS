//
//  HudViewController.m
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

#import "HudViewController.h"
#import <mach/mach_time.h>
#import "Macros.h"
#import "util.h"
#import "BlockViewStyle1.h"
#import "Transmitter.h"
#import "BasicInfoManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OSDInfoPaneViewController.h"
#import "EvaCommand.h"
#import "OSDViewController.h"
#import "AirlineManagmentMenuViewController.h"
#import "WaypointAnnotation.h"
#import "WaypointAnnotationView.h"
#import "WaypointMenuViewController.h"
#import "CSRouteAnnotation.h"
#import "CSRouteView.h"
#import "EvaAirlineFile.h"
#import "WaypointAnnotation.h"
#import "AirlineListViewController.h"
#import "BlockViewStyle1.h"
#import "BlockViewStyle2.h"
#import "ImageAnnotation.h"
#import "ImageAnnotationView.h"
#import "Macros.h"

#define UDP_SERVER_HOST @"192.168.0.1"
#define UDP_SERVER_PORT 6000

#define kThrottleFineTuningStep 0.015

#define kRouteAirline   @"Airline"
#define kRouteTrack     @"Track"
#define kRouteNextTrack @"NextTrack"
#define kImageAnnotationViewDrone                     @"Drone"
#define kImageAnnotationViewMyLocation                @"MyLocation"
#define kImageAnnotationViewCircleFlight              @"CircleFlight"
#define kImageAnnotationViewPointFlight               @"PointFlight"
#define kImageAnnotationViewCircleFlightRealCenter    @"CircleFlightRealCenter"
#define kImageAnnotationViewPointFlightRealTarget     @"PointFlightRealTarget"

#define kImageAnnotationDrone                       0
#define kImageAnnotationMyLocation                  1
#define kImageAnnotationPointFlight                 2
#define kImageAnnotationCircleFlight                3
#define kImageAnnotationPointFlightRealTarget       4
#define kImageAnnotationCircleFlightRealCenter      5

#define kDefaultCoordinateSpan   MKCoordinateSpanMake(0.5 / 111.0, 0.5 / 111.0 * 0.8)

//#define kDefaultCoordinateSpan   MKCoordinateSpanMake(1.0 / 111.0, 0.5 / 111.0)

typedef enum hud_view_alert_dialog{
    hud_view_alert_dialog_eva_command_simple,
    hud_view_alert_dialog_eva_command_follow,
    hud_view_alert_dialog_circle_flight,
    hud_view_alert_dialog_point_flight,
    hud_view_alert_dialog_airline_save,
    hud_view_alert_dialog_airline_file_name_wrong,
    hud_view_alert_dialog_airline_create,
    hud_view_alert_dialog_airline_empty,
    hud_view_alert_dialog_airline_management_exit,
    hud_view_alert_dialog_airline_clear,
    hud_view_alert_dialog_airline_enable,
    hud_view_alert_dialog_airline_disable,
    hub_view_alert_dialog_airline_upload_and_verify,
    hub_view_alert_dialog_airline_upload_cancel,
    hub_view_alert_dialog_airline_upload_success,
    hub_view_alert_dialog_enter_config,
    hub_view_alert_dialog_waypoint_count_limit,
    hud_view_alert_dialog_gps_count_not_enough,
    hud_view_alert_dialog_exit_circle_flight,
    hud_view_alert_dialog_exit_point_flight,
    hud_view_alert_dialog_point_flight_distance_larger_than_100m,
    hud_view_alert_dialog_circle_flight_distance_larger_than_100m,
    hud_view_alert_dialog_i_known
}hud_view_alert_dialog_t;

typedef enum hud_state{
    hud_state_normal,
    hud_state_flight_mode,
    hud_state_circle_flight,
    hud_state_point_flight,
    hud_state_airline_management,
}hud_state_t;

typedef enum touch_rc_state{
    touch_rc_state_diable,
    touch_rc_state_enable
} touch_rc_state_t;

typedef enum airline_managment_state{
    airline_managment_state_edit,      //编辑模式，航点未上传验证
    airline_managment_state_uploading, //上传航线中
    airline_managment_state_uploaded,  //航点已经上传验证过
    airline_managment_state_enable,    //执行航线中
}airline_managment_state_t;

@interface HudViewController (){
    CGPoint joystickRightCurrentPosition, joystickLeftCurrentPosition;
    CGPoint joystickRightInitialPosition, joystickLeftInitialPosition;
    BOOL buttonRightPressed, buttonLeftPressed;
    CGPoint rightCenter, leftCenter;
    
    float joystickAlpha;
    
    BOOL isLeftHanded;
    
    float rightJoyStickOperableRadius;
    float leftJoyStickOperableRadius;
    
    BOOL isTransmitting;
    
    BOOL rudderIsLocked;
    BOOL throttleIsLocked;
    
    CGPoint rudderLockButtonCenter;
    CGPoint throttleUpButtonCenter;
    CGPoint throttleDownButtonCenter;
    CGPoint upIndicatorImageViewCenter;
    CGPoint downIndicatorImageViewCenter;
    
    CGPoint leftHandedRudderLockButtonCenter;
    CGPoint leftHandedThrottleUpButtonCenter;
    CGPoint leftHandedThrottleDownButtonCenter;
    CGPoint leftHandedUpIndicatorImageViewCenter;
    CGPoint leftHandedDownIndicatorImageViewCenter;
    
    NSMutableDictionary *blockViewDict;
    
    OSDInfoPaneViewController *osdInfoPaneVC;
    
    OSDViewController *osdVC;
    
    FlightModeViewController *flightModeVC;
//    
//    GCDAsyncUdpSocket *udpSocket;
    
    eva_simple_command_t evaCommand;
    
    //航线相关
    NSMutableArray *waypointAnnotationList;
    
    CSRouteAnnotation *airlineRouteAnnotation;
    CSRouteView *airlineRouteAnnotationView;
    
    CSRouteAnnotation *trackAnnotation ; //飞行器的实际飞行路线
    CSRouteView *trackAnnotationView ;
    
    CSRouteAnnotation *nextTrackAnnotation ; //飞行器当前位置到下一个航点的路线
    CSRouteView *nextTrackAnnotationView;
    
    ImageAnnotation *droneAnnotation;
    ImageAnnotationView *droneAnnotationView;
    
    ImageAnnotation *myLocationAnnotation;
    ImageAnnotationView *myLocationAnnotationView;
    
    NSString *airlineFileName;
    
    WaypointAnnotation *selectedWaypoint;
    WaypointViewController *waypointVC;
    AirlineListViewController *airlineListVC;
    
    EvaAirlineUploader *airlineUploader;
    
    hud_state_t hudState;
    
    airline_managment_state_t airlineManagmentState;
    
    BOOL isMapMode;
    
    ImageAnnotation *circleFlightCenterAnnotation;
    ImageAnnotation *pointFlightTargetAnnotation;
    
    ImageAnnotation *circleFlightRealCenterAnnotation;
    ImageAnnotation *pointFlightRealTargetAnnotation;
}

@property(nonatomic, retain) Channel *aileronChannel;
@property(nonatomic, retain) Channel *elevatorChannel;
@property(nonatomic, retain) Channel *rudderChannel;
@property(nonatomic, retain) Channel *throttleChannel;

@property(nonatomic, retain) Settings *settings;

@property(nonatomic, retain) ConfigViewController *configVC;

@property (nonatomic, retain) UIPopoverController *airlineManagmentMenuPopoverVC;
@property (nonatomic, retain) UIPopoverController *waypointMenuPopoverVC;

@end


@implementation HudViewController
@synthesize debugTextView;
@synthesize aileronChannel = _aileronChannel;
@synthesize elevatorChannel = _elevatorChannel;
@synthesize rudderChannel = _rudderChannel;
@synthesize throttleChannel = _throttleChannel;

@synthesize settings = _settings;

@synthesize configVC = _configVC;

@synthesize airlineManagmentMenuPopoverVC = _airlineManagmentMenuPopoverVC;
@synthesize waypointMenuPopoverVC = _waypointMenuPopoverVC;

#pragma mark BlockView Methods

-(void)blockTotalUI{
   CGRect appFrame = [[UIScreen mainScreen] bounds];
    
    CGRect blockViewPart1Frame = CGRectMake(0, 0, appFrame.size.height, appFrame.size.width);
    blockViewPart1Frame.origin.x = 0;
    blockViewPart1Frame.origin.y = 0;
    
	BlockViewStyle1 *blockViewPart1 = [[BlockViewStyle1 alloc] initWithFrame:blockViewPart1Frame];
	blockViewPart1.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
	blockViewPart1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	BlockViewStyle2 *blockViewPart2 = [[BlockViewStyle2 alloc] initWithFrame:CGRectMake(0, 0, 150, 100)
															  indicatorTitle:@"上传航线中..."];
	blockViewPart2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
	|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	blockViewPart2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
	[blockViewPart2.indicatorLabel setFont:[UIFont systemFontOfSize:11]];
	[blockViewPart2.indicatorLabel setTextColor:[UIColor whiteColor]];
	blockViewPart2.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[blockViewPart2.activityIndicatorView startAnimating];
	
	blockViewPart2.center = CGPointMake(blockViewPart1.frame.size.width / 2, blockViewPart1.frame.size.height / 2);
	[blockViewPart1 addSubview:blockViewPart2];
	
	[blockViewPart2 release];
	
	UIView *blockView = blockViewPart1;
    
	[self.view addSubview:blockView];
	[blockViewDict setValue:blockView forKey:[NSString stringWithFormat:@"%d", ViewBlockTotalUi]];
	
	[blockViewPart1 release];
}

- (void)unblockTotalUIAnimated:(NSNumber *)animated_{
    BOOL animated = [animated_ boolValue];
    
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d", ViewBlockTotalUi];
	UIView *blockView = [blockViewDict valueForKey:blockViewIdentifier];
	
	if(blockView == nil)
		return;
	
	if (animated == YES) {
		[UIView animateWithDuration:1
						 animations:^{
							 blockView.alpha = 0;
						 } completion:^(BOOL finished){
							 [blockView removeFromSuperview];
							 [blockViewDict removeObjectForKey:blockViewIdentifier];
						 }
		 ];
	}
	else {
		[blockView removeFromSuperview];
		[blockViewDict removeObjectForKey:blockViewIdentifier];
	}
}

#pragma mark BlockView Methods End

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCoinfigView) name:kNotificationDismissConfigView object:nil];
        
        NSString *documentsDir= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *userSettingsFilePath = [documentsDir stringByAppendingPathComponent:@"Settings.plist"];
        
        _settings = [[[Settings alloc] initWithSettingsFile:userSettingsFilePath] retain];
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [device addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:nil];  
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    rudderLockButtonCenter = rudderLockButton.center;
    throttleUpButtonCenter = throttleUpButton.center;
    throttleDownButtonCenter = throttleDownButton.center;
    upIndicatorImageViewCenter = upIndicatorImageView.center;
    downIndicatorImageViewCenter = downIndicatorImageView.center;
    
    float hudFrameWidth = [[UIScreen mainScreen] bounds].size.height;
    
    leftHandedRudderLockButtonCenter = CGPointMake(hudFrameWidth - rudderLockButtonCenter.x, rudderLockButtonCenter.y);
    leftHandedThrottleUpButtonCenter = CGPointMake(hudFrameWidth - throttleUpButtonCenter.x, throttleUpButtonCenter.y);
    leftHandedThrottleDownButtonCenter = CGPointMake(hudFrameWidth - throttleDownButtonCenter.x, throttleDownButtonCenter.y);
    leftHandedUpIndicatorImageViewCenter = CGPointMake(hudFrameWidth - upIndicatorImageViewCenter.x, upIndicatorImageViewCenter.y);
    leftHandedDownIndicatorImageViewCenter = CGPointMake(hudFrameWidth - downIndicatorImageViewCenter.x, downIndicatorImageViewCenter.y);

    rightJoyStickOperableRadius =  joystickRightBackgroundImageView.frame.size.width / 2.0;
    leftJoyStickOperableRadius  =  joystickLeftBackgroundImageView.frame.size.width / 2.0;
    
    _aileronChannel = [[_settings channelByName:kChannelNameAileron] retain];
    _elevatorChannel = [[_settings channelByName:kChannelNameElevator] retain];
    _rudderChannel = [[_settings channelByName:kChannelNameRudder] retain];
    _throttleChannel = [[_settings channelByName:kChannelNameThrottle] retain];
    
    BasicInfoManager *infoManager = [BasicInfoManager sharedManager];
    [infoManager setAileronChannel:_aileronChannel];
    [infoManager setElevatorChannel:_elevatorChannel];
    [infoManager setRudderChannel:_rudderChannel];
    [infoManager setThrottleChannel:_throttleChannel];
    [infoManager setChannel5:[_settings channelAtIndex:4]];
    [infoManager setChannel6:[_settings channelAtIndex:5]];

	rightCenter = CGPointMake(joystickRightThumbImageView.frame.origin.x + (joystickRightThumbImageView.frame.size.width / 2), joystickRightThumbImageView.frame.origin.y + (joystickRightThumbImageView.frame.size.height / 2));
	joystickRightInitialPosition = CGPointMake(rightCenter.x - (joystickRightBackgroundImageView.frame.size.width / 2), rightCenter.y - (joystickRightBackgroundImageView.frame.size.height / 2));
	leftCenter = CGPointMake(joystickLeftThumbImageView.frame.origin.x + (joystickLeftThumbImageView.frame.size.width / 2), joystickLeftThumbImageView.frame.origin.y + (joystickLeftThumbImageView.frame.size.height / 2));
	joystickLeftInitialPosition = CGPointMake(leftCenter.x - (joystickLeftBackgroundImageView.frame.size.width / 2), leftCenter.y - (joystickLeftBackgroundImageView.frame.size.height / 2));
    
	joystickLeftCurrentPosition = joystickLeftInitialPosition;
	joystickRightCurrentPosition = joystickRightInitialPosition;
	
	joystickAlpha = MIN(joystickRightBackgroundImageView.alpha, joystickRightThumbImageView.alpha);
	joystickRightBackgroundImageView.alpha = joystickRightThumbImageView.alpha = joystickAlpha;
	joystickLeftBackgroundImageView.alpha = joystickLeftThumbImageView.alpha = joystickAlpha;
	
	[self setBattery:(int)([UIDevice currentDevice].batteryLevel * 100)];
    
    [self updateJoystickCenter];
    
    [self updateStatusInfoLabel];
    [self updateThrottleValueLabel];
    
    if(blockViewDict == nil){
        blockViewDict = [[NSMutableDictionary alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTransmitterState) name:kNotificationTransmitterStateDidChange object:nil];
    
    [[BasicInfoManager sharedManager] setDebugTextView:debugTextView];
 
    if (osdInfoPaneVC == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            osdInfoPaneVC = [[OSDInfoPaneViewController alloc] initWithNibName:@"OSDInfoPaneViewController" bundle:nil data:[Transmitter sharedTransmitter].osdData];
            
            CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
            
            osdInfoPaneVC.view.center = CGPointMake(appFrame.size.height / 2.0, 518);
        }
        else{
            osdInfoPaneVC = [[OSDInfoPaneViewController alloc] initWithNibName:@"OSDInfoPaneViewController_iPhone" bundle:nil data:[Transmitter sharedTransmitter].osdData];
            
            CGRect frame = osdInfoPaneVC.view.frame;
            
            osdInfoPaneVC.view.frame = CGRectMake(10, 30, frame.size.width, frame.size.height);
        }
        
        [self.view insertSubview:osdInfoPaneVC.view belowSubview:hudDownPartImageView];
        
        [[BasicInfoManager sharedManager] setOsdInfoPaneVC:osdInfoPaneVC];
    }
    
    if (osdVC == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            osdVC = [[OSDViewController alloc] initWithNibName:@"OSDViewController" bundle:nil
                                                          data:[Transmitter sharedTransmitter].osdData];
            osdVC.view.center = CGPointMake(self.view.frame.size.width - osdVC.view.frame.size.width / 2.0 - 10, 200);
        }
        else{
           // osdVC = [[OSDViewController alloc] initWithNibName:@"OSDViewController_iPhone" bundle:nil
            //                                              data:[Transmitter sharedTransmitter].osdData];
           // osdVC.view.center = CGPointMake(self.view.frame.size.width / 2.0 - 10, 100);
        }

        [self.view insertSubview:osdVC.view belowSubview:hudDownPartImageView];
        
        [[BasicInfoManager sharedManager] setOsdVC:osdVC];
    }

    if (flightModeVC == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            flightModeVC = [[FlightModeViewController alloc] initWithNibName:@"FlightModeViewController"  bundle:nil];
            flightModeVC.view.center = CGPointMake(flightModeVC.view.frame.size.width / 2.0 + 10, 210);
        }
        else{
//            flightModeVC = [[FlightModeViewControl alloc] initWithNibName:@"FlightModeViewController_iPhone"  bundle:nil];
//            
//            CGRect frame = flightModeVC.view.frame;
//            
//            flightModeVC.view.frame = CGRectMake(10, 30, frame.size.width, frame.size.height);
        }
        
        flightModeVC.delegate = self;
    }
    
    [[BasicInfoManager sharedManager] setIsConnected:YES];
    
    if(isTransmitting == NO){
        [self startTransmission];
    }
    
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;
    [self updateRcControlModeButton:osdData.physicalRcEnabled];

    [self configViewController:nil interfaceOpacityValueDidChange:[[[Transmitter sharedTransmitter] config] interfaceOpacity]];
    [self configViewController:nil leftHandedValueDidChange:[[[Transmitter sharedTransmitter] config] isLeftHandMode]];
    
    if (waypointAnnotationList == nil) {
        EvaConfig *config = [[Transmitter sharedTransmitter] config];
        
        switch (config.mapMode) {
            case map_mode_standard:
                [mapView setMapType: MKMapTypeStandard];
                break;
            case map_mode_satellite:
                [mapView setMapType: MKMapTypeSatellite];
                break;
            case map_mode_hybrid:
                [mapView setMapType: MKMapTypeHybrid];
                break;
            default:
                [mapView setMapType: MKMapTypeHybrid];
                break;
        }

        mapView.showsUserLocation = NO;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(22.5453770000, 114.0789370000);
        MKCoordinateSpan span = kDefaultCoordinateSpan;  //一度纬度约111km, 赤道上的一个经度约111km
        
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
        
        [mapView setRegion:region animated:NO];
        
        waypointAnnotationList = [[NSMutableArray alloc] init];
        UITapGestureRecognizer *tapGesReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapDidTap:)];
        tapGesReco.numberOfTapsRequired = 1;
        [mapView addGestureRecognizer:tapGesReco];
        [tapGesReco release];
                
        airlineRouteAnnotation = [[CSRouteAnnotation alloc] initWithPoints];
        airlineRouteAnnotation.routeID = kRouteAirline;
        airlineRouteAnnotation.lineColor = [UIColor redColor];
        [mapView addAnnotation:airlineRouteAnnotation];
                
        trackAnnotation = [[CSRouteAnnotation alloc] initWithPoints] ;
        trackAnnotation.routeID = kRouteTrack;
        trackAnnotation.lineColor = [UIColor yellowColor];
        [mapView addAnnotation:trackAnnotation];

        nextTrackAnnotation = [[CSRouteAnnotation alloc] initWithPoints] ;
        nextTrackAnnotation.routeID = kRouteNextTrack;
        nextTrackAnnotation.lineColor = [UIColor greenColor];
        [mapView addAnnotation:nextTrackAnnotation];
        
        droneAnnotation = [[ImageAnnotation alloc] init];
        droneAnnotation.imagePath = [[NSBundle mainBundle] pathForResource:@"plane" ofType:@"png"];
//        droneAnnotation.latitude = 39.95000;
//        droneAnnotation.longitude = 116.494000;
        droneAnnotation.typeId = kImageAnnotationDrone;
        [mapView addAnnotation:droneAnnotation];
        
        myLocationAnnotation = [[ImageAnnotation alloc] init];
        myLocationAnnotation.imagePath = [[NSBundle mainBundle] pathForResource:@"flag" ofType:@"png"];
//        myLocationAnnotation.latitude = 39.95000;
//        myLocationAnnotation.longitude = 116.494000;
        myLocationAnnotation.typeId = kImageAnnotationMyLocation;
        [mapView addAnnotation:myLocationAnnotation];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
        
        hudState = hud_state_normal;
    }
}

- (void)viewDidUnload
{
    [configButton release];
    configButton = nil;
    [joystickLeftButton release];
    joystickLeftButton = nil;
    [joystickRightButton release];
    joystickRightButton = nil;
    [joystickLeftThumbImageView release];
    joystickLeftThumbImageView = nil;
    [joystickLeftBackgroundImageView release];
    joystickLeftBackgroundImageView = nil;
    [joystickRightThumbImageView release];
    joystickRightThumbImageView = nil;
    [joystickRightBackgroundImageView release];
    joystickRightBackgroundImageView = nil;
    [batteryLevelLabel release];
    batteryLevelLabel = nil;
    [batteryImageView release];
    batteryImageView = nil;
    [_configVC release];
    _configVC = nil;
    [rudderLockButton release];
    rudderLockButton = nil;
    [statusInfoLabel release];
    statusInfoLabel = nil;
    [throttleUpButton release];
    throttleUpButton = nil;
    [throttleDownButton release];
    throttleDownButton = nil;
    [downIndicatorImageView release];
    downIndicatorImageView = nil;
    [upIndicatorImageView release];
    upIndicatorImageView = nil;
    [throttleValueLabel release];
    throttleValueLabel = nil;
    [self setDebugTextView:nil];
    [followButton release];
    followButton = nil;
    [mapView release];
    mapView = nil;
    [airlineNameTextLabel release];
    airlineNameTextLabel = nil;
    [myLocationLocateButton release];
    myLocationLocateButton = nil;
    [droneLocationLocatButton release];
    droneLocationLocatButton = nil;
    [hudDownPartImageView release];
    hudDownPartImageView = nil;
    [mapIsEnableTextLabel release];
    mapIsEnableTextLabel = nil;
    [airlineManagmentMenu release];
    airlineManagmentMenu = nil;
    [airlineListTextLabel release];
    airlineListTextLabel = nil;
    [airlineCloseTextLabel release];
    airlineCloseTextLabel = nil;
    [airlineClearTextLabel release];
    airlineClearTextLabel = nil;
    [airineStartTextLabel release];
    airineStartTextLabel = nil;
    [airlineUploadTextLabel release];
    airlineUploadTextLabel = nil;
    [airlineSaveTextLabel release];
    airlineSaveTextLabel = nil;
    [flightModeTextLabel release];
    flightModeTextLabel = nil;
    [airlineManagementTextLabel release];
    airlineManagementTextLabel = nil;
    [autoTakeoffTextLabel release];
    autoTakeoffTextLabel = nil;
    [landingTextLabel release];
    landingTextLabel = nil;
    [headFreeDisableTextLabel release];
    headFreeDisableTextLabel = nil;
    [headFreeEnableTextLabel release];
    headFreeEnableTextLabel = nil;
    [configTextLabel release];
    configTextLabel = nil;
    [droneLocateTextLabel release];
    droneLocateTextLabel = nil;
    [altDecreaseTextLabel release];
    altDecreaseTextLabel = nil;
    [altIncreaseTextLabel release];
    altIncreaseTextLabel = nil;
    [myPositionLocateTextLabel release];
    myPositionLocateTextLabel = nil;
    [satCountTextLabel release];
    satCountTextLabel = nil;
    [satCountValueTextLabel release];
    satCountValueTextLabel = nil;
    [voltTextLabel release];
    voltTextLabel = nil;
    [voltValueTextLabel release];
    voltValueTextLabel = nil;
    [droneStatusTextLabel release];
    droneStatusTextLabel = nil;
    [altTextLabel release];
    altTextLabel = nil;
    [altValueTextLabel release];
    altValueTextLabel = nil;
    [orientationTextLabel release];
    orientationTextLabel = nil;
    [orientationValueTextLabel release];
    orientationValueTextLabel = nil;
    [connectionStatusTextLabel release];
    connectionStatusTextLabel = nil;
    [flightModeButton release];
    flightModeButton = nil;
    [airlineManagementButton release];
    airlineManagementButton = nil;
    [demoGcsLongitude release];
    demoGcsLongitude = nil;
    [demoGcsLatitude release];
    demoGcsLatitude = nil;
    [rcControlModeSwitchButton release];
    rcControlModeSwitchButton = nil;
    [airlineListView release];
    airlineListView = nil;
    [airlineEnableView release];
    airlineEnableView = nil;
    [airlineDisableView release];
    airlineDisableView = nil;
    [airlineSaveView release];
    airlineSaveView = nil;
    [airlineUploadView release];
    airlineUploadView = nil;
    [airlineClearView release];
    airlineClearView = nil;
    [airlineAbandonView release];
    airlineAbandonView = nil;
    [airlineAltitudeChangeView release];
    airlineAltitudeChangeView = nil;
    [airlineListButton release];
    airlineListButton = nil;
    [airlineDisableButton release];
    airlineDisableButton = nil;
    [airlineEnableButton release];
    airlineEnableButton = nil;
    [airlineSaveButton release];
    airlineSaveButton = nil;
    [airlineUploadButton release];
    airlineUploadButton = nil;
    [airlineClearButton release];
    airlineClearButton = nil;
    [airlineAbandonButton release];
    airlineAbandonButton = nil;
    [airlineAltitudeChangeButton release];
    airlineAltitudeChangeButton = nil;
    [waypointCountTextLabel release];
    waypointCountTextLabel = nil;
    [airlineDistanceTextLabel release];
    airlineDistanceTextLabel = nil;
    [pointFlightMenu release];
    pointFlightMenu = nil;
    [circleFlightMenu release];
    circleFlightMenu = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef __DEMO__
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
#else
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
#endif
}

- (NSUInteger)supportedInterfaceOrientations{
#ifdef __DEMO__
    return UIInterfaceOrientationMaskPortrait;
#else
    return UIInterfaceOrientationMaskLandscapeLeft;
#endif
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if ([_configVC.view superview] == nil) {
        [_configVC release], _configVC = nil;
        [[BasicInfoManager sharedManager] setConfigVC:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDismissConfigView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationTransmitterStateDidChange object:nil];
    
    if(_airlineManagmentMenuPopoverVC != nil){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectAirlineManagmentMenuItem object:nil];
        [_airlineManagmentMenuPopoverVC dismissPopoverAnimated:NO];
        [_airlineManagmentMenuPopoverVC release];
    }
    
    if(_waypointMenuPopoverVC != nil){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectWaypointMenuItem object:nil];
        [_waypointMenuPopoverVC dismissPopoverAnimated:NO];
        [_waypointMenuPopoverVC release];
    }
    
    [self stopTransmission];
    
    [osdInfoPaneVC release];
    [osdVC release];
    [flightModeVC release];
    
    [_aileronChannel release];
    [_elevatorChannel release];
    [_rudderChannel release];
    [_throttleChannel release];
    [_settings release];
    [configButton release];
    [joystickLeftButton release];
    [joystickRightButton release];
    [joystickLeftThumbImageView release];
    [joystickLeftBackgroundImageView release];
    [joystickRightThumbImageView release];
    [joystickRightBackgroundImageView release];
    [batteryLevelLabel release];
    [batteryImageView release];
    [_configVC release];
    [blockViewDict release];
    [rudderLockButton release];
    [statusInfoLabel release];
    [throttleUpButton release];
    [throttleDownButton release];
    [downIndicatorImageView release];
    [upIndicatorImageView release];
    [throttleValueLabel release];
    [debugTextView release];
    [followButton release];
    [mapView release];
    [waypointAnnotationList release];
    [airlineRouteAnnotation release];
    [airlineFileName release];
    [airlineNameTextLabel release];
    [trackAnnotation release];
    [nextTrackAnnotation release];
    [droneAnnotation release];
    [myLocationAnnotation release];
    [airlineRouteAnnotationView release];
    [trackAnnotationView release];
    [nextTrackAnnotationView release];
    [droneAnnotationView release];
    [myLocationAnnotationView release];
    [myLocationLocateButton release];
    [droneLocationLocatButton release];
    [hudDownPartImageView release];
    [mapIsEnableTextLabel release];
    [airlineManagmentMenu release];
    [airlineListTextLabel release];
    [airlineCloseTextLabel release];
    [airlineClearTextLabel release];
    [airineStartTextLabel release];
    [airlineUploadTextLabel release];
    [airlineSaveTextLabel release];
    [flightModeTextLabel release];
    [airlineManagementTextLabel release];
    [autoTakeoffTextLabel release];
    [landingTextLabel release];
    [headFreeDisableTextLabel release];
    [headFreeEnableTextLabel release];
    [configTextLabel release];
    [droneLocateTextLabel release];
    [altDecreaseTextLabel release];
    [altIncreaseTextLabel release];
    [myPositionLocateTextLabel release];
    [satCountTextLabel release];
    [satCountValueTextLabel release];
    [voltTextLabel release];
    [voltValueTextLabel release];
    [droneStatusTextLabel release];
    [altTextLabel release];
    [altValueTextLabel release];
    [orientationTextLabel release];
    [orientationValueTextLabel release];
    [connectionStatusTextLabel release];
    [flightModeButton release];
    [airlineManagementButton release];
    [demoGcsLongitude release];
    [demoGcsLatitude release];
    [rcControlModeSwitchButton release];
    [airlineListView release];
    [airlineEnableView release];
    [airlineDisableView release];
    [airlineSaveView release];
    [airlineUploadView release];
    [airlineClearView release];
    [airlineAbandonView release];
    [airlineAltitudeChangeView release];
    [airlineListButton release];
    [airlineDisableButton release];
    [airlineEnableButton release];
    [airlineSaveButton release];
    [airlineUploadButton release];
    [airlineClearButton release];
    [airlineAbandonButton release];
    [airlineAltitudeChangeButton release];
    [waypointCountTextLabel release];
    [airlineDistanceTextLabel release];
    [pointFlightMenu release];
    [circleFlightMenu release];
    [circleFlightCenterAnnotation release];
    [pointFlightTargetAnnotation release];
    [circleFlightRealCenterAnnotation release];
    [pointFlightRealTargetAnnotation release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"batteryLevel"] || [object isEqual:[UIDevice currentDevice]]) {  
        [self setBattery:(int)([UIDevice currentDevice].batteryLevel * 100)]; 
    }  
}

#pragma mark ConfigViewControllerDelegate Methods

- (void)configViewController:(ConfigViewController *)ctrl interfaceOpacityValueDidChange:(float)newValue{
    joystickAlpha = newValue;
    joystickLeftBackgroundImageView.alpha = joystickAlpha;
    joystickLeftThumbImageView.alpha = joystickAlpha;
    joystickRightBackgroundImageView.alpha = joystickAlpha;
    joystickRightThumbImageView.alpha = joystickAlpha;

}

- (void)configViewController:(ConfigViewController *)ctrl leftHandedValueDidChange:(BOOL)enabled{
    isLeftHanded = enabled;
    
    [self josystickButtonDidTouchUp:joystickLeftButton forEvent:nil];
    [self josystickButtonDidTouchUp:joystickRightButton forEvent:nil];

    if(isLeftHanded){
        joystickLeftThumbImageView.image = [UIImage imageNamed:@"Joystick_Manuel_RETINA.png"];
        joystickRightThumbImageView.image = [UIImage imageNamed:@"Joystick_Gyro_RETINA.png"];
        
        rudderLockButton.center       = leftHandedRudderLockButtonCenter;
        throttleUpButton.center       = leftHandedThrottleUpButtonCenter;
        throttleDownButton.center     = leftHandedThrottleDownButtonCenter;
        upIndicatorImageView.center   = leftHandedUpIndicatorImageViewCenter;
        downIndicatorImageView.center = leftHandedDownIndicatorImageViewCenter; 
    }
    else{
        joystickLeftThumbImageView.image = [UIImage imageNamed:@"Joystick_Gyro_RETINA.png"];
        joystickRightThumbImageView.image = [UIImage imageNamed:@"Joystick_Manuel_RETINA.png"];
        
        rudderLockButton.center       = rudderLockButtonCenter;
        throttleUpButton.center       = throttleUpButtonCenter;
        throttleDownButton.center     = throttleDownButtonCenter;
        upIndicatorImageView.center   = upIndicatorImageViewCenter;
        downIndicatorImageView.center = downIndicatorImageViewCenter; 
    }
}

- (void)configViewController:(ConfigViewController *)ctrl mapModeDidChange:(map_mode_t)mapMode{
    switch (mapMode) {
        case map_mode_standard:
            mapView.mapType = MKMapTypeStandard;
            break;
        case map_mode_satellite:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case map_mode_hybrid:
            mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}


#pragma mark ConfigViewControllerDelegate Methods end

-(void)blockJoystickHudForTakingOff{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud];
	
	if([blockViewDict valueForKey:blockViewIdentifier] != nil)
		return;
    
    CGRect blockViewPart1Frame = self.view.frame;
    blockViewPart1Frame.origin.x = 0;
    blockViewPart1Frame.origin.y = 0;
    blockViewPart1Frame.size.width = [[UIScreen mainScreen] bounds].size.height;
    blockViewPart1Frame.size.height = joystickLeftButton.frame.origin.y + joystickLeftButton.frame.size.height;
    
	BlockViewStyle1 *blockViewPart1 = [[BlockViewStyle1 alloc] initWithFrame:blockViewPart1Frame];
	blockViewPart1.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
	blockViewPart1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	UIView *blockView = blockViewPart1;
    
	[self.view addSubview:blockView];
	[blockViewDict setValue:blockView forKey:[NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud]];
	
	[blockViewPart1 release];
}

- (void)unblockJoystickHudForTakingOff:(BOOL)animated{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud];
	UIView *blockView = [blockViewDict valueForKey:blockViewIdentifier];
	
	if(blockView == nil)
		return;
	
	if (animated == YES) {
		[UIView animateWithDuration:1
						 animations:^{
							 blockView.alpha = 0;
						 } completion:^(BOOL finished){
							 [blockView removeFromSuperview];
							 [blockViewDict removeObjectForKey:blockViewIdentifier];
						 }
		 ];
	}
	else {
		[blockView removeFromSuperview];
		[blockViewDict removeObjectForKey:blockViewIdentifier];
	}
}

-(void)blockJoystickHudForStopping{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud2];
	
	if([blockViewDict valueForKey:blockViewIdentifier] != nil)
		return;
    
    CGRect blockViewPart1Frame = self.view.frame;
    blockViewPart1Frame.origin.x = 0;
    blockViewPart1Frame.origin.y = joystickLeftButton.frame.origin.y;
    blockViewPart1Frame.size.width = [[UIScreen mainScreen] bounds].size.height;
    blockViewPart1Frame.size.height = joystickLeftButton.frame.origin.y + joystickLeftButton.frame.size.height - joystickLeftButton.frame.origin.y;
    
	BlockViewStyle1 *blockViewPart1 = [[BlockViewStyle1 alloc] initWithFrame:blockViewPart1Frame];
	blockViewPart1.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
	blockViewPart1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	UIView *blockView = blockViewPart1;
    
	[self.view addSubview:blockView];
	[blockViewDict setValue:blockView forKey:[NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud2]];
	
	[blockViewPart1 release];
}

- (void)unblockJoystickHudForStopping:(BOOL)animated{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockJoyStickHud2];
	UIView *blockView = [blockViewDict valueForKey:blockViewIdentifier];
	
	if(blockView == nil)
		return;
	
	if (animated == YES) {
		[UIView animateWithDuration:1
						 animations:^{
							 blockView.alpha = 0;
						 } completion:^(BOOL finished){
							 [blockView removeFromSuperview];
							 [blockViewDict removeObjectForKey:blockViewIdentifier];
						 }
		 ];
	}
	else {
		[blockView removeFromSuperview];
		[blockViewDict removeObjectForKey:blockViewIdentifier];
	}
}

- (void)updateStatusInfoLabel{
    if(throttleIsLocked){
        if(rudderIsLocked){
            statusInfoLabel.text = getLocalizeString(@"Throttle Rudder Locked");
        }
        else {
            statusInfoLabel.text = getLocalizeString(@"Throttle Locked");
        }
    }
    else {
        if(rudderIsLocked){
            statusInfoLabel.text = getLocalizeString(@"Rudder Locked");
        }
        else {
            statusInfoLabel.text = @"";
        }
    }
}

- (void)updateJoystickCenter{
    rightCenter = CGPointMake(joystickRightInitialPosition.x + (joystickRightBackgroundImageView.frame.size.width / 2), joystickRightInitialPosition.y +  (joystickRightBackgroundImageView.frame.size.height / 2));
    leftCenter = CGPointMake(joystickLeftInitialPosition.x + (joystickLeftBackgroundImageView.frame.size.width / 2), joystickLeftInitialPosition.y +  (joystickLeftBackgroundImageView.frame.size.height / 2));
    
    if(isLeftHanded){
        joystickLeftThumbImageView.center = CGPointMake(leftCenter.x, leftCenter.y - _throttleChannel.value * leftJoyStickOperableRadius);
    }
    else{
        joystickRightThumbImageView.center = CGPointMake(rightCenter.x, rightCenter.y - _throttleChannel.value * rightJoyStickOperableRadius);
    }
}

- (void)checkTransmitterState{
    TransmitterState inputState = [[Transmitter sharedTransmitter] inputState];
    TransmitterState outputState = [[Transmitter sharedTransmitter] outputState];
    
    if ((inputState == TransmitterStateOk) && (outputState == TransmitterStateOk)) {
        connectionStatusTextLabel.text = getLocalizeString(@"connected");
        connectionStatusTextLabel.textColor = [altValueTextLabel textColor];
        [[BasicInfoManager sharedManager] setIsConnected:YES];
        _configVC.isConnected = YES;
    }
    else if((inputState == TransmitterStateOk) && (outputState != TransmitterStateOk)){
        connectionStatusTextLabel.text = getLocalizeString(@"can't sentd data");
        connectionStatusTextLabel.textColor = [UIColor redColor];

        [[BasicInfoManager sharedManager] setIsConnected:NO];
        _configVC.isConnected = NO;
    }
    else if((inputState != TransmitterStateOk) && (outputState == TransmitterStateOk)){
        connectionStatusTextLabel.text = getLocalizeString(@"can't get data");
        connectionStatusTextLabel.textColor = [UIColor redColor];
        
        [[BasicInfoManager sharedManager] setIsConnected:NO];
        _configVC.isConnected = NO;
    }
    else {
        connectionStatusTextLabel.text = getLocalizeString(@"not connected");
        connectionStatusTextLabel.textColor = [UIColor redColor];
        
        [[BasicInfoManager sharedManager] setIsConnected:NO];
        _configVC.isConnected = NO;
    }
}

- (OSStatus) startTransmission {
    enum PpmPolarity polarity = PPM_POLARITY_POSITIVE;
    
    if(_settings.ppmPolarityIsNegative){
        polarity = PPM_POLARITY_NEGATIVE;
    }
    
    BOOL s = [[Transmitter sharedTransmitter] start];
    
    isTransmitting = s;
    
    osdInfoPaneVC.osdData = [[Transmitter sharedTransmitter] osdData];
    osdVC.osdData = [[Transmitter sharedTransmitter] osdData];
    
    return s;
}

- (OSStatus) stopTransmission {
    if (isTransmitting) {
        BOOL s = [[Transmitter sharedTransmitter] stop];
        isTransmitting = !s;
        return !s;
    } else {
        return 0;
    }
}

- (void)dismissCoinfigView{
    if(_configVC.view != nil)
        [_configVC.view removeFromSuperview];
    //[[Transmitter sharedTransmitter] setNeedsTransmmitPpmPackage:YES];
}

- (void)hideBatteryLevelUI
{
	batteryLevelLabel.hidden = YES;
	batteryImageView.hidden = YES;	
}

- (void)showBatteryLevelUI
{
	batteryLevelLabel.hidden = NO;
	batteryImageView.hidden = NO;
}


- (void)setBattery:(int)percent
{
    static int prevImage = -1;
    static int prevPercent = -1;
    static BOOL wasHidden = NO;
	if(percent < 0 && !wasHidden)
	{
		[self performSelectorOnMainThread:@selector(hideBatteryLevelUI) withObject:nil waitUntilDone:YES];		
        wasHidden = YES;
	}
	else if (percent >= 0)
	{
        if (wasHidden)
        {
            [self performSelectorOnMainThread:@selector(showBatteryLevelUI) withObject:nil waitUntilDone:YES];
            wasHidden = NO;
        }
        int imageNumber = ((percent < 10) ? 0 : (int)((percent / 33.4) + 1));
        if (prevImage != imageNumber)
        {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Btn_Battery_%d_RETINA.png", imageNumber]];
            [batteryImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
            prevImage = imageNumber;
        }
        if (prevPercent != percent)
        {
            prevPercent = percent;
            [batteryLevelLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d%%", percent] waitUntilDone:YES];
        }
	}
}

- (void)refreshJoystickRight
{
	CGRect frame = joystickRightBackgroundImageView.frame;
	frame.origin = joystickRightCurrentPosition;
	joystickRightBackgroundImageView.frame = frame;
}    

- (void)refreshJoystickLeft
{
	CGRect frame = joystickLeftBackgroundImageView.frame;
	frame.origin = joystickLeftCurrentPosition;
	joystickLeftBackgroundImageView.frame = frame;
}

//更新摇杆点（joystickRightThumbImageView或joystickLeftThumbImageView）的位置，point是当前触摸点的位置
- (void)updateVelocity:(CGPoint)point isRight:(BOOL)isRight
{
    static BOOL _runOnce = YES;
    static float leftThumbWidth = 0.0;
    static float rightThumbWidth = 0.0;
    static float leftThumbHeight = 0.0;
    static float rightThumbHeight = 0.0;
    static float leftRadius = 0.0;
    static float rightRadius = 0.0;
    
    if (_runOnce)
    {
        leftThumbWidth = joystickLeftThumbImageView.frame.size.width;
        rightThumbWidth = joystickRightThumbImageView.frame.size.width;
        leftThumbHeight = joystickLeftThumbImageView.frame.size.height;
        rightThumbHeight = joystickRightThumbImageView.frame.size.height;
        leftRadius = joystickLeftBackgroundImageView.frame.size.width / 2.0;
        rightRadius = joystickRightBackgroundImageView.frame.size.width / 2.0;
        _runOnce = NO;
    }
    
	CGPoint nextpoint = CGPointMake(point.x, point.y);
	CGPoint center = (isRight ? rightCenter : leftCenter);
	UIImageView *thumbImage = (isRight ? joystickRightThumbImageView : joystickLeftThumbImageView);
	
	float dx = nextpoint.x - center.x;
	float dy = nextpoint.y - center.y;
    
    float thumb_radius = isRight ? rightJoyStickOperableRadius : leftJoyStickOperableRadius;
	
    if(fabsf(dx) > thumb_radius){
        if (dx > 0) {
            nextpoint.x = center.x + rightJoyStickOperableRadius;
        }
        else {
            nextpoint.x = center.x - rightJoyStickOperableRadius;
        }
    }
    
    if(fabsf(dy) > thumb_radius){
        if(dy > 0){
            nextpoint.y = center.y + rightJoyStickOperableRadius;
        }
        else {
            nextpoint.y = center.y - rightJoyStickOperableRadius;
        }
    }

	CGRect frame = thumbImage.frame;
	frame.origin.x = nextpoint.x - (thumbImage.frame.size.width / 2);
	frame.origin.y = nextpoint.y - (thumbImage.frame.size.height / 2);	
	thumbImage.frame = frame;
}

- (void)updateThrottleValueLabel{
    float takeOffValue = clip(-1 + _settings.takeOffThrottle * 2 + _throttleChannel.trimValue, -1.0, 1.0); 
    
    if (_throttleChannel.isReversing) {
        takeOffValue = -takeOffValue;
    }
    
    throttleValueLabel.text = [NSString stringWithFormat:@"%d", (int)(1500 + 500 * _throttleChannel.value)];
}

- (IBAction)joystickButtonDidTouchDown:(id)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:sender] anyObject];
	CGPoint current_location = [touch locationInView:self.view];
    static CGPoint previous_location;
    
    previous_location = current_location;
    
	if(sender == joystickRightButton)
	{
        static uint64_t right_press_previous_time = 0;
        if(right_press_previous_time == 0) right_press_previous_time = mach_absolute_time();
        
        uint64_t current_time = mach_absolute_time();
        static mach_timebase_info_data_t sRightPressTimebaseInfo;
        uint64_t elapsedNano;
        float dt = 0;
        
        //dt calculus function of real elapsed time
        if(sRightPressTimebaseInfo.denom == 0) (void) mach_timebase_info(&sRightPressTimebaseInfo);
        elapsedNano = (current_time-right_press_previous_time)*(sRightPressTimebaseInfo.numer / sRightPressTimebaseInfo.denom);
        dt = elapsedNano/1000000000.0;
        
        right_press_previous_time = current_time;
        
        if(dt > 0.1 && dt < 0.3){  //双击加油门
            if(_throttleChannel.value + kThrottleFineTuningStep > 1){
                _throttleChannel.value = 1;
            }
            else {
                _throttleChannel.value += kThrottleFineTuningStep;
            }
            [self updateJoystickCenter];
        }

		buttonRightPressed = YES;

		joystickRightBackgroundImageView.alpha = joystickRightThumbImageView.alpha = 1.0;
        
        joystickRightCurrentPosition.x = current_location.x - (joystickRightBackgroundImageView.frame.size.width / 2);
        
        CGPoint thumbCurrentLocation = CGPointZero;
        
        if(isLeftHanded){
            joystickRightCurrentPosition.y = current_location.y - (joystickRightBackgroundImageView.frame.size.height / 2);
            
            [self refreshJoystickRight];
            
            //摇杆中心点
            rightCenter = CGPointMake(joystickRightBackgroundImageView.frame.origin.x + (joystickRightBackgroundImageView.frame.size.width / 2), joystickRightBackgroundImageView.frame.origin.y + (joystickRightBackgroundImageView.frame.size.height / 2));
            
            thumbCurrentLocation = rightCenter;
        }
        else{
            float throttleValue = [_throttleChannel value];
            
            //NSLog(@"throttle value:%f", throttleValue);

            joystickRightCurrentPosition.y = current_location.y - (joystickRightBackgroundImageView.frame.size.height / 2) + throttleValue * rightJoyStickOperableRadius;
            
            [self refreshJoystickRight];
            
            //摇杆中心点
            rightCenter = CGPointMake(joystickRightBackgroundImageView.frame.origin.x + (joystickRightBackgroundImageView.frame.size.width / 2), joystickRightBackgroundImageView.frame.origin.y + (joystickRightBackgroundImageView.frame.size.height / 2));
            
            thumbCurrentLocation = CGPointMake(rightCenter.x, current_location.y);
        }
        
        //更新摇杆点（joystickRightThumbImageView或joystickLeftThumbImageView）的位置
        [self updateVelocity:thumbCurrentLocation isRight:YES];
	}
	else if(sender == joystickLeftButton)
	{
        static uint64_t left_press_previous_time = 0;
        if(left_press_previous_time == 0) left_press_previous_time = mach_absolute_time();
        
        uint64_t current_time = mach_absolute_time();
        static mach_timebase_info_data_t sLeftPressTimebaseInfo;
        uint64_t elapsedNano;
        float dt = 0;
        
        //dt calculus function of real elapsed time
        if(sLeftPressTimebaseInfo.denom == 0) (void) mach_timebase_info(&sLeftPressTimebaseInfo);
        elapsedNano = (current_time-left_press_previous_time)*(sLeftPressTimebaseInfo.numer / sLeftPressTimebaseInfo.denom);
        dt = elapsedNano/1000000000.0;
        
        left_press_previous_time = current_time;
        
        if(dt > 0.1 && dt < 0.3){  //双击减油门
            if(_throttleChannel.value - kThrottleFineTuningStep < -1){
                _throttleChannel.value = -1;
            }
            else {
                _throttleChannel.value -= kThrottleFineTuningStep;
            }
            [self updateJoystickCenter];
        }
        
		buttonLeftPressed = YES;
        
        joystickLeftBackgroundImageView.alpha = joystickLeftThumbImageView.alpha = 1.0;
		
		joystickLeftCurrentPosition.x = current_location.x - (joystickLeftBackgroundImageView.frame.size.width / 2);
        
        CGPoint thumbCurrentLocation = CGPointZero;
        
        if(isLeftHanded){
            float throttleValue = [_throttleChannel value];
            
            joystickLeftCurrentPosition.y = current_location.y - (joystickLeftBackgroundImageView.frame.size.height / 2) + throttleValue * leftJoyStickOperableRadius;
            
            [self refreshJoystickLeft];
            
            //摇杆中心点
            leftCenter = CGPointMake(joystickLeftBackgroundImageView.frame.origin.x + (joystickLeftBackgroundImageView.frame.size.width / 2),
                                     joystickLeftBackgroundImageView.frame.origin.y + (joystickLeftBackgroundImageView.frame.size.height / 2));
            
            thumbCurrentLocation = CGPointMake(leftCenter.x, current_location.y);
        }
        else{
            joystickLeftCurrentPosition.y = current_location.y - (joystickLeftBackgroundImageView.frame.size.height / 2);
            
            [self refreshJoystickLeft];
            
            //摇杆中心点
            leftCenter = CGPointMake(joystickLeftBackgroundImageView.frame.origin.x + (joystickLeftBackgroundImageView.frame.size.width / 2), joystickLeftBackgroundImageView.frame.origin.y + (joystickLeftBackgroundImageView.frame.size.height / 2));
            
            thumbCurrentLocation = leftCenter;
        }

		[self updateVelocity:thumbCurrentLocation isRight:NO];
	}
}

- (IBAction)josystickButtonDidTouchUp:(id)sender forEvent:(UIEvent *)event {
	if(sender == joystickRightButton)
	{
		buttonRightPressed = NO;

		joystickRightCurrentPosition = joystickRightInitialPosition;
		joystickRightBackgroundImageView.alpha = joystickRightThumbImageView.alpha = joystickAlpha;
		
		[self refreshJoystickRight];
        
        if (isLeftHanded) {
            [_aileronChannel setValue:0.0];
            [_elevatorChannel setValue:0.0];
            
            rightCenter = CGPointMake(joystickRightBackgroundImageView.frame.origin.x + (joystickRightBackgroundImageView.frame.size.width / 2), joystickRightBackgroundImageView.frame.origin.y + (joystickRightBackgroundImageView.frame.size.height / 2));
        }
        else{
            [_rudderChannel setValue:0.0];
            
            float throttleValue = [_throttleChannel value];
            
            rightCenter = CGPointMake(joystickRightBackgroundImageView.frame.origin.x + (joystickRightBackgroundImageView.frame.size.width / 2), 
                                      joystickRightBackgroundImageView.frame.origin.y + (joystickRightBackgroundImageView.frame.size.height / 2) - throttleValue * rightJoyStickOperableRadius);
        }

		[self updateVelocity:rightCenter isRight:YES];
	}
	else if(sender == joystickLeftButton)
	{
		buttonLeftPressed = NO;

		joystickLeftCurrentPosition = joystickLeftInitialPosition;
		joystickLeftBackgroundImageView.alpha = joystickLeftThumbImageView.alpha = joystickAlpha;
		
		[self refreshJoystickLeft];
        
        if (isLeftHanded) {
            [_rudderChannel setValue:0.0];
            
            float throttleValue = [_throttleChannel value];
            
            leftCenter = CGPointMake(joystickLeftBackgroundImageView.frame.origin.x + (joystickLeftBackgroundImageView.frame.size.width / 2), 
                                      joystickLeftBackgroundImageView.frame.origin.y + (joystickLeftBackgroundImageView.frame.size.height / 2) - throttleValue * rightJoyStickOperableRadius);
        }
        else{
            [_aileronChannel setValue:0.0];
            [_elevatorChannel setValue:0.0];
            
            leftCenter = CGPointMake(joystickLeftBackgroundImageView.frame.origin.x + (joystickLeftBackgroundImageView.frame.size.width / 2), joystickLeftBackgroundImageView.frame.origin.y + (joystickLeftBackgroundImageView.frame.size.height / 2));
        }
		
		[self updateVelocity:leftCenter isRight:NO];
	}
}

- (IBAction)joystickButtonDidDrag:(id)sender forEvent:(UIEvent *)event {
    BOOL _runOnce = YES;
    static float rightBackgoundWidth = 0.0;
    static float rightBackgoundHeight = 0.0;
    static float leftBackgoundWidth = 0.0;
    static float leftBackgoundHeight = 0.0;
    if (_runOnce)
    {
        rightBackgoundWidth = joystickRightBackgroundImageView.frame.size.width;
        rightBackgoundHeight = joystickRightBackgroundImageView.frame.size.height;
        leftBackgoundWidth = joystickLeftBackgroundImageView.frame.size.width;
        leftBackgoundHeight = joystickLeftBackgroundImageView.frame.size.height;
        _runOnce = NO;
    }
    
	UITouch *touch = [[event touchesForView:sender] anyObject];
	CGPoint point = [touch locationInView:self.view];
    
    float aileronElevatorValidBandRatio = 0.5 - _settings.aileronDeadBand / 2.0;
    
    float rudderValidBandRatio = 0.5 - _settings.rudderDeadBand / 2.0;
	
	if(sender == joystickRightButton && buttonRightPressed)
	{
        float rightJoystickXInput, rightJoystickYInput; 
        
        float rightJoystickXValidBand;  //右边摇杆x轴的无效区
        float rightJoystickYValidBand;  //右边摇杆y轴的无效区
        
        if(isLeftHanded){
            rightJoystickXValidBand = aileronElevatorValidBandRatio; //X轴操作是Aileron
            rightJoystickYValidBand = aileronElevatorValidBandRatio; //Y轴操作是Elevator
        }
        else{
            rightJoystickXValidBand = rudderValidBandRatio;    
            rightJoystickYValidBand = 0.5;   //Y轴操作是油门
        }
        
        if(!isLeftHanded && rudderIsLocked){  
            rightJoystickXInput = 0.0;  
        }
        //左右操作 (controlRatio * rightBackgoundWidth)是控制的有效区域，所以((rightBackgoundWidth / 2) - (controlRatio * rightBackgoundWidth))就是盲区了
        else if((rightCenter.x - point.x) > ((rightBackgoundWidth / 2) - (rightJoystickXValidBand * rightBackgoundWidth)))   
        {
            float percent = ((rightCenter.x - point.x) - ((rightBackgoundWidth / 2) - (rightJoystickXValidBand * rightBackgoundWidth))) / ((rightJoystickXValidBand * rightBackgoundWidth));
            if(percent > 1.0)
                percent = 1.0;
            
            rightJoystickXInput = -percent;
        }
        else if((point.x - rightCenter.x) > ((rightBackgoundWidth / 2) - (rightJoystickXValidBand * rightBackgoundWidth)))
        {
            float percent = ((point.x - rightCenter.x) - ((rightBackgoundWidth / 2) - (rightJoystickXValidBand * rightBackgoundWidth))) / ((rightJoystickXValidBand * rightBackgoundWidth));
            if(percent > 1.0)
                percent = 1.0;
            
            rightJoystickXInput = percent;
        }
        else
        {
            rightJoystickXInput = 0.0;
        }
        
        //NSLog(@"right x input:%.3f",rightJoystickXInput);
        
        if (isLeftHanded) {
            [_aileronChannel setValue:rightJoystickXInput];
        }
        else {
            [_rudderChannel setValue:rightJoystickXInput];
        }
        
        if(throttleIsLocked && !isLeftHanded){
            rightJoystickYInput = _throttleChannel.value;
        }
        //上下操作
        else if((point.y - rightCenter.y) > ((rightBackgoundHeight / 2) - (rightJoystickYValidBand * rightBackgoundHeight)))
        {
            float percent = ((point.y - rightCenter.y) - ((rightBackgoundHeight / 2) - (rightJoystickYValidBand * rightBackgoundHeight))) / ((rightJoystickYValidBand * rightBackgoundHeight));
            if(percent > 1.0)
                percent = 1.0;
            
            rightJoystickYInput = -percent;
            
        }
        else if((rightCenter.y - point.y) > ((rightBackgoundHeight / 2) - (rightJoystickYValidBand * rightBackgoundHeight)))
        {
            float percent = ((rightCenter.y - point.y) - ((rightBackgoundHeight / 2) - (rightJoystickYValidBand * rightBackgoundHeight))) / ((rightJoystickYValidBand * rightBackgoundHeight));
            if(percent > 1.0)
                percent = 1.0;
            
            rightJoystickYInput = percent;
        }
        else
        {
            rightJoystickYInput = 0.0;
        }
        
        //NSLog(@"right y input:%.3f",rightJoystickYInput);
        
        if (isLeftHanded) {
            [_elevatorChannel setValue:rightJoystickYInput];
        }
        else {
            [_throttleChannel setValue:rightJoystickYInput];
            [self updateThrottleValueLabel];
        }
	}
	else if(sender == joystickLeftButton
            && buttonLeftPressed)
	{
        float leftJoystickXInput, leftJoystickYInput;
        
        float leftJoystickXValidBand;  //左边摇杆x轴的无效区
        float leftJoystickYValidBand;  //左边摇杆y轴的无效区
        
        if(isLeftHanded){
            leftJoystickXValidBand = rudderValidBandRatio;    
            leftJoystickYValidBand = 0.5;   //Y轴操作是油门
        }
        else{
            leftJoystickXValidBand = aileronElevatorValidBandRatio; //X轴操作是Aileron
            leftJoystickYValidBand = aileronElevatorValidBandRatio; //Y轴操作是Elevator
        }
        
        if(isLeftHanded && rudderIsLocked){
            leftJoystickXInput = 0.0;
        }
		else if((leftCenter.x - point.x) > ((leftBackgoundWidth / 2) - (leftJoystickXValidBand * leftBackgoundWidth)))
		{
			float percent = ((leftCenter.x - point.x) - ((leftBackgoundWidth / 2) - (leftJoystickXValidBand * leftBackgoundWidth))) / ((leftJoystickXValidBand * leftBackgoundWidth));
			if(percent > 1.0)
				percent = 1.0;
            
            leftJoystickXInput = -percent;
            
		}
		else if((point.x - leftCenter.x) > ((leftBackgoundWidth / 2) - (leftJoystickXValidBand * leftBackgoundWidth)))
		{
			float percent = ((point.x - leftCenter.x) - ((leftBackgoundWidth / 2) - (leftJoystickXValidBand * leftBackgoundWidth))) / ((leftJoystickXValidBand * leftBackgoundWidth));
			if(percent > 1.0)
				percent = 1.0;

            leftJoystickXInput = percent;
		}
		else
		{
            leftJoystickXInput = 0.0;
		}	
        
       //NSLog(@"left x input:%.3f",leftJoystickXInput);
		
        if(isLeftHanded){
            [_rudderChannel setValue:leftJoystickXInput];
        }
        else{
            [_aileronChannel setValue:leftJoystickXInput];
        }
        
        if(throttleIsLocked && isLeftHanded){
            leftJoystickYInput = _throttleChannel.value;
        }
		else if((point.y - leftCenter.y) > ((leftBackgoundHeight / 2) - (leftJoystickYValidBand * leftBackgoundHeight)))
		{
			float percent = ((point.y - leftCenter.y) - ((leftBackgoundHeight / 2) - (leftJoystickYValidBand * leftBackgoundHeight))) / ((leftJoystickYValidBand * leftBackgoundHeight));
			if(percent > 1.0)
				percent = 1.0;
            
            leftJoystickYInput = -percent;
		}
		else if((leftCenter.y - point.y) > ((leftBackgoundHeight / 2) - (leftJoystickYValidBand * leftBackgoundHeight)))
		{
			float percent = ((leftCenter.y - point.y) - ((leftBackgoundHeight / 2) - (leftJoystickYValidBand * leftBackgoundHeight))) / ((leftJoystickYValidBand * leftBackgoundHeight));
			if(percent > 1.0)
				percent = 1.0;
            
            leftJoystickYInput = percent;
		}
		else
		{  
            leftJoystickYInput = 0.0;
		}		
        
        //NSLog(@"left y input:%.3f",leftJoystickYInput);
        
        if(isLeftHanded){
            [_throttleChannel setValue:leftJoystickYInput];
            [self updateThrottleValueLabel];
        }
        else{
            [_elevatorChannel setValue:leftJoystickYInput];
        }
	}
    
    BOOL isRight = (sender == joystickRightButton);
    if ((isRight && buttonRightPressed) ||
        (!isRight && buttonLeftPressed))
    {
        [self updateVelocity:point isRight:isRight];
    }
}

- (void)showConfigView{
    //[[Transmitter sharedTransmitter] setNeedsTransmmitPpmPackage:NO];
    
    [_configVC release], _configVC = nil;
    
    EvaConfig *config = [[Transmitter sharedTransmitter] config];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _configVC = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil config:config];
        _configVC.osdData = [[Transmitter sharedTransmitter] osdData];
    } else {
        _configVC = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController_iPhone" bundle:nil config:config];
        _configVC.osdData = [[Transmitter sharedTransmitter] osdData];
    }
    _configVC.delegate = self;
    
    [[BasicInfoManager sharedManager] setConfigVC:_configVC];
    [self.view addSubview:_configVC.view];
}

#pragma mark Airline Management Methods
- (void)showAirlineManagmentMenu{
    if (airlineManagmentMenu.superview == nil) {
        airlineManagmentMenu.center = CGPointMake(390, 145);
        [self.view addSubview:airlineManagmentMenu];
    }
}

- (void)hideAirlineManagmentMenu{
    if (airlineManagmentMenu.superview != nil) {
        [airlineManagmentMenu removeFromSuperview];
    }
}

- (void)abandonCurrentAirline{
    [airlineFileName release];
    airlineFileName = nil;
    [self clearCurrentAirline];
}

- (void)clearCurrentAirline{
    [mapView removeAnnotations:waypointAnnotationList];
    [waypointAnnotationList removeAllObjects];
    
    [self updateWaypointRoute];
    [airlineRouteAnnotationView regionChanged];
    
    [trackAnnotation.points removeAllObjects];
    [nextTrackAnnotation.points removeAllObjects];
    
    [trackAnnotationView regionChanged];
    [nextTrackAnnotationView regionChanged];
}

- (void)activeMapViewForAirlineManagement:(BOOL)active{
    joystickLeftButton.hidden = active;
    joystickRightButton.hidden = active;
    joystickLeftBackgroundImageView.hidden = active;
    joystickLeftThumbImageView.hidden = active;
    joystickRightBackgroundImageView.hidden = active;
    joystickRightThumbImageView.hidden = active;
    
    airlineNameTextLabel.hidden = !active;

    if (active) {
        [osdVC setOsdViewVisibleState:!active];
        [osdInfoPaneVC setInfoPaneVisibleState:!active];
        [self closeFlightModeView];
        [self showAirlineManagmentMenu];
    }
    else{
        [self hideAirlineManagmentMenu];
    }
    
    flightModeButton.enabled = !active;
}

- (void)activeMapViewForPointFlight:(BOOL)active{
    joystickLeftButton.hidden = active;
    joystickRightButton.hidden = active;
    joystickLeftBackgroundImageView.hidden = active;
    joystickLeftThumbImageView.hidden = active;
    joystickRightBackgroundImageView.hidden = active;
    joystickRightThumbImageView.hidden = active;
    
    airlineNameTextLabel.hidden = !active;
    
    if (active) {
        [osdVC setOsdViewVisibleState:!active];
        [osdInfoPaneVC setInfoPaneVisibleState:!active];
     //   [self closeFlightModeView];
        [self showPointFlightMenu];
    }
    else{
        [self hidePointFlightMenu];
    }
    
    airlineManagementButton.enabled = !active;
}

- (void)activeMapViewForCircleFlight:(BOOL)active{
    joystickLeftButton.hidden = active;
    joystickRightButton.hidden = active;
    joystickLeftBackgroundImageView.hidden = active;
    joystickLeftThumbImageView.hidden = active;
    joystickRightBackgroundImageView.hidden = active;
    joystickRightThumbImageView.hidden = active;
    
    airlineNameTextLabel.hidden = !active;
    
    if (active) {
        [osdVC setOsdViewVisibleState:!active];
        [osdInfoPaneVC setInfoPaneVisibleState:!active];
       // [self closeFlightModeView];
        [self showCircleFlightMenu];
    }
    else{
        [self hideCircleFlightMenu];
    }
    
    airlineManagementButton.enabled = !active;
}

- (void)handleAirlineOpenNotification:(NSNotification *)notification{
    [self closeAirlineListView];
    
    NSString *airlineFileName_ = [[notification userInfo] objectForKey:kAirlineKeyFileName];
    
    airlineNameTextLabel.text = airlineFileName_;
    
    NSArray *waypointList = nil;
    
    waypointList = [EvaAirlineFile loadAirlineFromFile:airlineFileName_];
    
    [mapView removeAnnotations:waypointAnnotationList];
    [waypointAnnotationList removeAllObjects];
    
    float maxLongitude = 0;
    float minLongitude = 0;
    float minLatitude = 0;
    float maxLatitude = 0;

    WaypointAnnotation *waypoint = [waypointList objectAtIndex:0];
    
    if(waypoint != nil){
        maxLongitude = waypoint.coordinate.longitude;
        minLongitude = waypoint.coordinate.longitude;
        maxLatitude = waypoint.coordinate.latitude;
        minLatitude = waypoint.coordinate.latitude;
    }

    for(WaypointAnnotation *waypoint in waypointList) {
        if(waypoint.coordinate.longitude < minLongitude){
            minLongitude = waypoint.coordinate.longitude;
        }
        if(waypoint.coordinate.longitude > maxLongitude){
            maxLongitude = waypoint.coordinate.longitude;
        }
        if (waypoint.coordinate.latitude < minLatitude) {
            minLatitude = waypoint.coordinate.latitude;
        }
        if(waypoint.coordinate.latitude > maxLatitude){
            maxLatitude = waypoint.coordinate.latitude;
        }
        
        [mapView addAnnotation:waypoint];
        [waypointAnnotationList addObject:waypoint];
    }
    
    NSLog(@"***max lat:%f min lat:%f", maxLatitude, minLatitude);
    NSLog(@"***max long:%f min long:%f", maxLongitude, minLongitude);
    
    float midLongitude = (minLongitude + maxLongitude) / 2.0;
    float midLatitude = (minLatitude + maxLatitude) / 2.0;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(midLatitude, midLongitude);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLatitude - minLatitude), (maxLongitude - minLongitude));
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:region animated:NO];

    [self updateWaypointRoute];
    [airlineRouteAnnotationView regionChanged];
    
    [self activeMapViewForAirlineManagement:YES];
    [airlineFileName release];
    airlineFileName = [airlineFileName_ retain];
    
    [self switchAirlineManagmentState:airline_managment_state_edit];
}

- (void)updateWaypointRoute{
    [airlineRouteAnnotation.points removeAllObjects];
    for(int idx = 0; idx < waypointAnnotationList.count; idx++){
        WaypointAnnotation *waypointAnnotation =[waypointAnnotationList objectAtIndex:idx];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypointAnnotation.coordinate.latitude, waypointAnnotation.coordinate.longitude);
        
        [airlineRouteAnnotation addPoint:coordinate];
    }
}

- (void)handleMapDidTap:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];//这里touchPoint是点击的某点在地图控件中的位置
    CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    if (hudState == hud_state_airline_management) {
        if (airlineManagmentState == airline_managment_state_uploading || airlineManagmentState == airline_managment_state_enable) {
            return;
        }
        
        if (waypointAnnotationList.count == 99) {
            [self showAlertViewWithTitle:getLocalizeString(@"Add Waypoint") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"The max count of waypoints is 99.") tag:hub_view_alert_dialog_waypoint_count_limit];
            return;
        }
        
        WaypointAnnotation *wayPointAnnotation = [[WaypointAnnotation alloc] init];
        wayPointAnnotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
        wayPointAnnotation.no = waypointAnnotationList.count + 1;
        wayPointAnnotation.altitude   = 9999;
        wayPointAnnotation.speed      = (int)(25 *3.6);
        wayPointAnnotation.panxuan    = 90;
        wayPointAnnotation.hoverTime  = 0;
                
        wayPointAnnotation.style      = waypoint_style_red;
        wayPointAnnotation.isUploaded = NO;
        
        [mapView addAnnotation:wayPointAnnotation];
        
        [waypointAnnotationList addObject:wayPointAnnotation];
        
        [wayPointAnnotation release];
        
        [self updateWaypointRoute];
        [airlineRouteAnnotationView regionChanged];
        
        [self switchAirlineManagmentState:airline_managment_state_edit];
        
        [self updateAirlineStateUI];
    }
    else if(hudState == hud_state_circle_flight){
        if (circleFlightCenterAnnotation == nil) {
            circleFlightCenterAnnotation = [[ImageAnnotation alloc] init];
            circleFlightCenterAnnotation.imagePath = [[NSBundle mainBundle] pathForResource:@"smile_face" ofType:@"png"];
            circleFlightCenterAnnotation.typeId = kImageAnnotationCircleFlight;
            circleFlightCenterAnnotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
            [mapView addAnnotation:circleFlightCenterAnnotation];
        }
        else{
            [mapView removeAnnotation:circleFlightCenterAnnotation];
            circleFlightCenterAnnotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
            [mapView addAnnotation:circleFlightCenterAnnotation];
        }
    }
    else if(hudState == hud_state_point_flight){
        if (pointFlightTargetAnnotation == nil) {
            pointFlightTargetAnnotation = [[ImageAnnotation alloc] init];
            pointFlightTargetAnnotation.imagePath = [[NSBundle mainBundle] pathForResource:@"smile_face" ofType:@"png"];
            pointFlightTargetAnnotation.typeId = kImageAnnotationPointFlight;
            pointFlightTargetAnnotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
            [mapView addAnnotation:pointFlightTargetAnnotation];
        }
        else{
            [mapView removeAnnotation:pointFlightTargetAnnotation];
            pointFlightTargetAnnotation.coordinate = CLLocationCoordinate2DMake(touchMapCoordinate.latitude, touchMapCoordinate.longitude);
            [mapView addAnnotation:pointFlightTargetAnnotation];
        }
    }
    else{
        return;
    }
}

- (void)closeWaypointView{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [waypointVC.view.superview removeFromSuperview];
        [waypointVC release];
        waypointVC = nil;
    }
}

- (void)closeAirlineListView{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationAirlineOpen object:nil];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [airlineListVC.view.superview removeFromSuperview];
        [airlineListVC release];
        airlineListVC = nil;
    }
}

- (void)handleWaypointMenuItemDidSelect:(NSNotification *)notification{
    [_waypointMenuPopoverVC dismissPopoverAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectWaypointMenuItem object:nil];
    [_waypointMenuPopoverVC release];
    _waypointMenuPopoverVC = nil;
    
    waypoint_menu_item_t menuItem = [[[notification userInfo] valueForKey:kWaypointMenuKeyItem] intValue];
    
    if (menuItem == waypoint_menu_item_edit) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            WaypointViewController *_waypointVC = [[WaypointViewController alloc]  initWithNibName:@"WaypointViewController"
                                                  bundle:nil
                                                  waypoint:selectedWaypoint];
            CGRect bounds = _waypointVC.view.frame;
            
            _waypointVC.navBar.topItem.rightBarButtonItem.action = @selector(closeWaypointView);
            _waypointVC.navBar.topItem.rightBarButtonItem.target = self;
            _waypointVC.modalPresentationStyle = UIModalPresentationFormSheet;
            _waypointVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            _waypointVC.delegate = self;
            
            [self presentModalViewController:_waypointVC animated:YES];
            
            self.modalViewController.view.superview.bounds = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
            
            [_waypointVC release];
        }
        else{
            waypointVC = [[WaypointViewController alloc]
                                        initWithNibName:@"WaypointViewController"
                                                  bundle:nil
                                                waypoint:selectedWaypoint];

            [waypointVC view];
            waypointVC.navBar.topItem.rightBarButtonItem.action = @selector(closeWaypointView);
            waypointVC.navBar.topItem.rightBarButtonItem.target = self;
            waypointVC.delegate = self;
            
            UIView *blockView = [[UIView alloc] initWithFrame:self.view.frame];
            
            [blockView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
            
            waypointVC.view.center = CGPointMake(blockView.bounds.size.width / 2.0, blockView.bounds.size.height / 2.0);
            [blockView addSubview:waypointVC.view];
            
            [self.view addSubview:blockView];
            
            [blockView release];
        }
    }
    else if(menuItem == waypoint_menu_item_delete){
        [mapView removeAnnotation:selectedWaypoint];
        [waypointAnnotationList removeObject:selectedWaypoint];
        selectedWaypoint = nil;
        
        for (int waypointIdx = 0; waypointIdx < waypointAnnotationList.count; waypointIdx++) {
            WaypointAnnotation *waypointAnnotation = [waypointAnnotationList objectAtIndex:waypointIdx];

            waypointAnnotation.no = waypointIdx + 1;
            
            waypointAnnotation.isUploaded = NO;
            waypointAnnotation.style = waypoint_style_red;
            
            [mapView removeAnnotation:waypointAnnotation];
            [mapView addAnnotation:waypointAnnotation];
        }
        
        [self updateWaypointRoute];
        [airlineRouteAnnotationView regionChanged];
        
        [self switchAirlineManagmentState:airline_managment_state_edit];
        [self updateAirlineStateUI];
    }
    else if(menuItem == waypoint_menu_item_flight_to){
        int waypointNo = selectedWaypoint.no;
        
        NSData *cmdData = [EvaCommand getWaypointFlightToCommand:waypointNo];
        [[Transmitter sharedTransmitter] transmmitData:cmdData];
    }
    else
        ;
}

- (void)updateNextTrackAnnotationView:(int)nextWaypointNo withDroneCoordinate:(CLLocationCoordinate2D)droneCoordinate{
    if(nextWaypointNo <= waypointAnnotationList.count){
        CLLocationCoordinate2D nextWaypointCoordinate ;
        WaypointAnnotation *waypoint = [waypointAnnotationList objectAtIndex:nextWaypointNo - 1];
        nextWaypointCoordinate.latitude = waypoint.coordinate.latitude;
        nextWaypointCoordinate.longitude = waypoint.coordinate.longitude;
        
        [nextTrackAnnotation.points removeAllObjects];
        [nextTrackAnnotation addPoint:nextWaypointCoordinate];
        [nextTrackAnnotation addPoint:droneCoordinate];
    }
    else{
        [nextTrackAnnotation.points removeAllObjects];
    }
    
    [nextTrackAnnotationView regionChanged];
}

- (void)updateTrackAnnotationViewWithDroneCoordinate:(CLLocationCoordinate2D)droneCoordinate{
    if(trackAnnotation.points.count > 120){  //最多120飞行器位置的点
        [trackAnnotation.points removeObjectAtIndex:0];
    }
    [trackAnnotation addPoint:droneCoordinate];
    [trackAnnotationView regionChanged];
}

- (void)updateMapView{
    EvaOSDData *osdData = [[Transmitter sharedTransmitter] osdData];
    
    float droneLatitude = [osdData latitude];
    float droneLongitude = [osdData longitude];
    float headAngle = [osdData headAngle];

    CLLocationCoordinate2D droneCoordinate;
    droneCoordinate.latitude = droneLatitude;
    droneCoordinate.longitude = droneLongitude;
    
    droneAnnotation.coordinate = CLLocationCoordinate2DMake(droneLatitude, droneLongitude);
    droneAnnotation.rotation = headAngle * M_PI / 180.0;
    
    [droneAnnotationView setNeedsDisplay];
    
    BasicInfoManager *infoManager = [BasicInfoManager sharedManager];
    
    CLLocationCoordinate2D myLocation = [infoManager location];

    myLocationAnnotation.coordinate = CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude);
    
    [myLocationAnnotationView setNeedsDisplay];

    [self updateTrackAnnotationViewWithDroneCoordinate:droneCoordinate];
    
    Byte nextWaypointNo = [osdData finishedWaypointCount] + 1;
    
    [self updateNextTrackAnnotationView:nextWaypointNo withDroneCoordinate:droneCoordinate];
    
    if (hudState == hud_state_point_flight) {
        if (pointFlightRealTargetAnnotation == nil) {
            pointFlightRealTargetAnnotation = [[ImageAnnotation alloc] init];
            pointFlightRealTargetAnnotation.imagePath = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"png"];
            pointFlightRealTargetAnnotation.typeId = kImageAnnotationPointFlightRealTarget;
            pointFlightRealTargetAnnotation.coordinate = [[BasicInfoManager sharedManager] pointFlightTargetLocation];
            [mapView addAnnotation:pointFlightRealTargetAnnotation];
        }
        else{
            float oldLatitude  = pointFlightRealTargetAnnotation.coordinate.latitude;
            float oldLongitude = pointFlightRealTargetAnnotation.coordinate.longitude;
            
            float newLatitude = [[BasicInfoManager sharedManager] pointFlightTargetLocation].latitude;
            float newLongitude = [[BasicInfoManager sharedManager] pointFlightTargetLocation].longitude;
            
            if (fabs(newLatitude - oldLatitude) > 0.00000001 || fabs(newLongitude - oldLongitude) > 0.00000001) {
                [mapView removeAnnotation:pointFlightRealTargetAnnotation];
                pointFlightRealTargetAnnotation.coordinate = [[BasicInfoManager sharedManager] pointFlightTargetLocation];
                [mapView addAnnotation:pointFlightRealTargetAnnotation];                
            }
        }
    }
    else if(hudState == hud_state_circle_flight){
    
    }
    else{
    
    }
}

- (void)updateRcControlModeButton:(BOOL)physicalRcEnabled{
    if (rcControlModeSwitchButton.tag != physicalRcEnabled) {
        rcControlModeSwitchButton.tag = physicalRcEnabled;
        
        if (physicalRcEnabled == YES) {
            [rcControlModeSwitchButton setTitle:getLocalizeString(@"Touch Control") forState:UIControlStateNormal];
        }
        else{
            [rcControlModeSwitchButton setTitle:getLocalizeString(@"Physical Control") forState:UIControlStateNormal];
        }
    }
}

#pragma mark Airline Management Methods
- (void)updateAirlineStateUI{
    waypointCountTextLabel.text = [NSString stringWithFormat:@"%d", waypointAnnotationList.count];
    
    float distance = 0;
    float deltaX = 0;
    float deltaY = 0;

    for (int waypointIdx = 0; waypointIdx < (int)(waypointAnnotationList.count) - 1; waypointIdx++) {
        WaypointAnnotation *waypoint = [waypointAnnotationList objectAtIndex:waypointIdx];
        WaypointAnnotation *nextWaypoint = [waypointAnnotationList objectAtIndex:waypointIdx + 1];
        
        deltaX = (nextWaypoint.coordinate.longitude - waypoint.coordinate.longitude) * 0.766 * 111199;
        deltaY = (nextWaypoint.coordinate.latitude - waypoint.coordinate.latitude) * 111199;
        
        distance += sqrtf(deltaX * deltaX + deltaY * deltaY);
        
        waypoint = nextWaypoint;
    }
    
    airlineDistanceTextLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
}

- (void)updateUI{
    [self updateOSDView];
    [self updateMapView];
    [self updateDroneStatusTextLabel];
    
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;
    [self updateRcControlModeButton:osdData.physicalRcEnabled];

    voltValueTextLabel.text = [NSString stringWithFormat:@"%.2fv", osdData.voltage];
    if (osdData.voltageIsLow) {
        [voltValueTextLabel setTextColor:[UIColor redColor]];
    }
    else{
        [voltValueTextLabel setTextColor:[altValueTextLabel textColor]];
    }

    satCountValueTextLabel.text = [NSString stringWithFormat:@"%d", osdData.satCount];
    
    if (osdData.satCount < 5) {
        [satCountValueTextLabel setTextColor:[UIColor redColor]];
    }
    else if(osdData.satCount == 5){
        [satCountValueTextLabel setTextColor:[UIColor yellowColor]];
    }
    else{
        [satCountValueTextLabel setTextColor:[altValueTextLabel textColor]];
    }
    
    altValueTextLabel.text = [NSString stringWithFormat:@"%.2fm", osdData.altitude];
    orientationValueTextLabel.text =  [NSString stringWithFormat:@"%.1f", osdData.headAngle];
    
    statusInfoLabel.text = [osdInfoPaneVC getFlightModeName];
    
    BasicInfoManager *manager = [BasicInfoManager sharedManager];
    
    CLLocationCoordinate2D location = [manager location];
    
    float longitude = location.longitude;
    float latitude = location.latitude;
    
    demoGcsLatitude.text = [NSString stringWithFormat:@"%f", latitude];
    demoGcsLongitude.text = [NSString stringWithFormat:@"%f", longitude];
}

#pragma mark MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{    
    if ([annotation isKindOfClass:[WaypointAnnotation class]])    {
        NSString *waypointAnnotationViewId = @"WaypointAnnotationView";
        
        WaypointAnnotationView *waypointAnnotationView = (WaypointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:waypointAnnotationViewId ];
        if (waypointAnnotationView == nil){
            waypointAnnotationView = [[[WaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:waypointAnnotationViewId ] autorelease];

            waypointAnnotationView.delegate = self;
        }
        else{
            waypointAnnotationView.annotation = annotation;
        }
        
        return waypointAnnotationView;
    }
    else if([annotation isKindOfClass:[CSRouteAnnotation class]]){
        NSString *routeId = [(CSRouteAnnotation *)annotation routeID];
        
        if ([routeId isEqualToString:kRouteAirline]) {
            if (airlineRouteAnnotationView != nil) {
                airlineRouteAnnotationView.annotation = annotation;
            }
            else{
                airlineRouteAnnotationView =
                (CSRouteView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kRouteAirline];
                if (airlineRouteAnnotationView == nil){
                    airlineRouteAnnotationView = [[CSRouteView alloc] initWithAnnotation:annotation reuseIdentifier:kRouteAirline];
                    [airlineRouteAnnotationView setFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height) ];
                    
                    airlineRouteAnnotationView.mapView = mapView;
                }
                else{
                    airlineRouteAnnotationView.annotation = annotation;
                }

            }
            return airlineRouteAnnotationView;
        }
        else if([routeId isEqualToString:kRouteTrack]){
            if (trackAnnotationView != nil) {
                trackAnnotationView.annotation = annotation;
            }
            else{
                trackAnnotationView =
                (CSRouteView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kRouteTrack];
                if (trackAnnotationView == nil){
                    trackAnnotationView = [[CSRouteView alloc] initWithAnnotation:annotation reuseIdentifier:kRouteTrack];
                    [trackAnnotationView setFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
                    
                    trackAnnotationView.mapView = mapView;
                }
                else{
                    trackAnnotationView.annotation = annotation;
                }
            }
            return trackAnnotationView;
        }
        else if([routeId isEqualToString:kRouteNextTrack]){
            if (nextTrackAnnotationView != nil) {
                nextTrackAnnotationView.annotation = annotation;
            }
            else{
                nextTrackAnnotationView =
                (CSRouteView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kRouteNextTrack];
                if (nextTrackAnnotationView == nil){
                    nextTrackAnnotationView = [[CSRouteView alloc] initWithAnnotation:annotation reuseIdentifier:kRouteNextTrack];
                    [nextTrackAnnotationView setFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height) ];
                    
                    nextTrackAnnotationView.mapView = mapView;
                }
                else{
                    nextTrackAnnotationView.annotation = annotation;
                }
            }
            
            return nextTrackAnnotationView;
        }
	}
    else if([annotation isKindOfClass:[ImageAnnotation class]]){
        int typeId = [(ImageAnnotation *)annotation typeId];
        
        if (typeId == kImageAnnotationDrone) {
            if (droneAnnotationView != nil) {
                droneAnnotationView.annotation = annotation;
            }
            else{
                droneAnnotationView =
                (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewDrone];
                if (droneAnnotationView == nil){
                    droneAnnotationView = [[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewDrone];
                }
                else{
                    droneAnnotationView.annotation = annotation;
                }
            }
            return droneAnnotationView;
        }
        else if(typeId == kImageAnnotationMyLocation){
            if (myLocationAnnotationView != nil) {
                myLocationAnnotationView.annotation = annotation;
            }
            else{
                myLocationAnnotationView =
                (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewMyLocation];
                if (myLocationAnnotationView == nil){
                    myLocationAnnotationView = [[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewMyLocation];
                }
                else{
                    myLocationAnnotationView.annotation = annotation;
                }
            }
            return myLocationAnnotationView;
        }
        else if(typeId == kImageAnnotationPointFlight){
            ImageAnnotationView  *imageAnnotationView =
            (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewPointFlight];
            if (imageAnnotationView == nil){
                imageAnnotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewPointFlight] autorelease];
            }
            else{
                imageAnnotationView.annotation = annotation;
            }
            return imageAnnotationView;
        }
        else if(typeId == kImageAnnotationCircleFlight){
            ImageAnnotationView  *imageAnnotationView =
            (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewCircleFlight];
            if (imageAnnotationView == nil){
                imageAnnotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewCircleFlight] autorelease];
            }
            else{
                imageAnnotationView.annotation = annotation;
            }
            return imageAnnotationView;
        }
        else if(typeId == kImageAnnotationPointFlightRealTarget){
            ImageAnnotationView  *imageAnnotationView =
            (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewPointFlightRealTarget];
            if (imageAnnotationView == nil){
                imageAnnotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewPointFlightRealTarget] autorelease];
            }
            else{
                imageAnnotationView.annotation = annotation;
            }
            return imageAnnotationView;
        }
        else if(typeId == kImageAnnotationCircleFlightRealCenter){
            ImageAnnotationView  *imageAnnotationView =
            (ImageAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kImageAnnotationViewCircleFlightRealCenter];
            if (imageAnnotationView == nil){
                imageAnnotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kImageAnnotationViewCircleFlightRealCenter] autorelease];
            }
            else{
                imageAnnotationView.annotation = annotation;
            }
            return imageAnnotationView;
        }
        else{
        
        }
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [airlineRouteAnnotationView regionChanged];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [airlineRouteAnnotationView regionChanged];
}

#pragma mark MKMapViewDelegate Methods end

- (IBAction)takoffButtonDidTouchDown:(id)sender {
    [self blockJoystickHudForTakingOff];
    
    _aileronChannel.value = 0;
    _elevatorChannel.value = 0;
    _rudderChannel.value = 0;
    
    float takeOffValue = clip(-1 + _settings.takeOffThrottle * 2 + _throttleChannel.trimValue, -1.0, 1.0); 
    
    if (_throttleChannel.isReversing) {
        takeOffValue = -takeOffValue;
    }
    
    _throttleChannel.value = takeOffValue;
    
    [self updateThrottleValueLabel];
    [self updateJoystickCenter];
}

- (IBAction)takeoffButtonDidTouchUp:(id)sender {
    [self unblockJoystickHudForTakingOff:NO];
}

- (IBAction)throttleStopButtonDidTouchDown:(id)sender {
    [self blockJoystickHudForStopping];
    
    _aileronChannel.value = 0;
    _elevatorChannel.value = 0;
    _rudderChannel.value = 0;
    _throttleChannel.value = -1;
    
    [self updateThrottleValueLabel];
    [self updateJoystickCenter];
}

- (IBAction)throttleStopButtonDidTouchUp:(id)sender {
    [self unblockJoystickHudForStopping:NO];
}

- (void)setView:(UIView *)view hidden:(BOOL)hidden{
    //view.h
}

- (IBAction)buttonDidTouchDown:(id)sender {
    if(sender == throttleUpButton){ 
        upIndicatorImageView.hidden = NO;
    }
    else if(sender == throttleDownButton){
        downIndicatorImageView.hidden = NO;
    }
}

- (IBAction)buttonDidDragEnter:(id)sender {
    if(sender == throttleUpButton || sender == throttleDownButton){ 
        [self buttonDidTouchDown:sender];
    }
}

- (IBAction)buttonDidDragExit:(id)sender {
    if(sender == throttleUpButton || sender == throttleDownButton){ 
        [self buttonDidTouchUpOutside:sender];
    }
}

- (IBAction)buttonDidTouchUpInside:(id)sender {
    if(sender == configButton){
        [self showAlertViewWithTitle:getLocalizeString(@"Settings") message:getLocalizeString(@"Enter settings interface?") tag:hub_view_alert_dialog_enter_config];
    }
    else if(sender == rudderLockButton){
        rudderIsLocked = !rudderIsLocked;
        
        if(rudderIsLocked){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                [rudderLockButton setImage:[UIImage imageNamed:@"Switch_On_IPAD.png"] forState:UIControlStateNormal];
            } 
            else {
                [rudderLockButton setImage:[UIImage imageNamed:@"Switch_On_RETINA.png"] forState:UIControlStateNormal];
            }
        }
        else{
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                [rudderLockButton setImage:[UIImage imageNamed:@"Switch_Off_IPAD.png"] forState:UIControlStateNormal];
            } 
            else {
                [rudderLockButton setImage:[UIImage imageNamed:@"Switch_Off_RETINA.png"] forState:UIControlStateNormal];
            }
        }
        
        [self updateStatusInfoLabel];
    }
    else if(sender == throttleUpButton){
        if(_throttleChannel.value + kThrottleFineTuningStep > 1){
            _throttleChannel.value = 1; 
        }
        else {
            _throttleChannel.value += kThrottleFineTuningStep;
        }
        [self updateJoystickCenter];
        
        if(isLeftHanded){
            joystickLeftThumbImageView.center = CGPointMake(joystickLeftThumbImageView.center.x, leftCenter.y - _throttleChannel.value * leftJoyStickOperableRadius);
        }
        else{
            joystickRightThumbImageView.center = CGPointMake(joystickRightThumbImageView.center.x, rightCenter.y - _throttleChannel.value * rightJoyStickOperableRadius);
        }   
        
        upIndicatorImageView.hidden = YES;
        
        [self updateThrottleValueLabel];
    }
    else if(sender == throttleDownButton){
        if(_throttleChannel.value - kThrottleFineTuningStep < -1){
            _throttleChannel.value = -1; 
        }
        else {
            _throttleChannel.value -= kThrottleFineTuningStep;
        }
        [self updateJoystickCenter];
        
        downIndicatorImageView.hidden = YES;
        
        [self updateThrottleValueLabel];
    }
}

- (IBAction)buttonDidTouchUpOutside:(id)sender {
    if(sender == throttleUpButton){ 
        upIndicatorImageView.hidden = YES;
    }
    else if(sender == throttleDownButton){
        downIndicatorImageView.hidden = YES;
    }
}

- (IBAction)buttonDidTouchCancel:(id)sender {
    if(sender == throttleUpButton || sender == throttleDownButton){ 
        [self buttonDidTouchUpOutside:sender];
    }
}

- (void)transmmitSimpleCommand:(eva_simple_command_t)cmd{
    NSData *cmdData = [EvaCommand getSimpleCommand:cmd];
    [[Transmitter sharedTransmitter] transmmitData:cmdData];
}

- (IBAction)unlockMotor:(id)sender {
    evaCommand = eva_command_motor_unlock;
    [self showAlertViewWithTitle:@"马达解锁" message:@"马达解锁?" tag:hud_view_alert_dialog_eva_command_simple];
}

- (IBAction)autoTakeoff:(id)sender {
#ifndef __DEMO__
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;
    if (osdData.satCount < 5) {
        [self showAlertViewWithTitle:getLocalizeString(@"Auto Takeoff") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"GPS Sat count is less than 5, can't auto takeoff.")  tag:hud_view_alert_dialog_gps_count_not_enough];
    }
#endif
    
#ifndef __DEMO__
    else{
#endif
        evaCommand = eva_command_auto_take_off;
        [self showAlertViewWithTitle:getLocalizeString(@"Auto Takeoff") message:getLocalizeString(@"Auto takeoff?") tag:hud_view_alert_dialog_eva_command_simple];
#ifndef __DEMO__
    }
#endif
}

- (IBAction)backAndLanding:(id)sender {
    evaCommand = eva_command_back_and_landing;
    [self showAlertViewWithTitle:getLocalizeString(@"Landing") message:getLocalizeString(@"Landing?") tag:hud_view_alert_dialog_eva_command_simple];
}

- (IBAction)enableFollow:(id)sender {
    if ([[BasicInfoManager sharedManager] needsFollow]) {
        [self showAlertViewWithTitle:@"Track" message:@"Stop tracking?" tag:hud_view_alert_dialog_eva_command_follow];
    }
    else{
        [self showAlertViewWithTitle:@"Track" message:@"Start tracking" tag:hud_view_alert_dialog_eva_command_follow];
    }
}

- (IBAction)enableCarefree:(id)sender{
    [self closeFlightModeView];
    
    evaCommand = eva_command_carefree_enable;
    [self showAlertViewWithTitle:getLocalizeString(@"Lock Head") message:getLocalizeString(@"Lock head?") tag:hud_view_alert_dialog_eva_command_simple];
}

- (IBAction)disableCarefree:(id)sender {
    [self closeFlightModeView];
    
    evaCommand = eva_command_carefree_disable;
    [self showAlertViewWithTitle:getLocalizeString(@"Unlock Head") message:getLocalizeString(@"Unlock head?") tag:hud_view_alert_dialog_eva_command_simple];
}

- (IBAction)showAirlineList:(id)sender {
    NSArray *airlineFileList = [EvaAirlineFile getAirlineFileList];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        AirlineListViewController *_airlineListVC = [[AirlineListViewController alloc]  initWithNibName:@"AirlineListViewController"
                                                                                                 bundle:nil
                                                                                            airlineList:airlineFileList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAirlineOpenNotification:) name:kNoticationAirlineOpen object:nil];
        
        CGRect bounds = _airlineListVC.view.frame;
        
        _airlineListVC.navBar.topItem.rightBarButtonItem.action = @selector(closeAirlineListView);
        _airlineListVC.navBar.topItem.rightBarButtonItem.target = self;
        _airlineListVC.modalPresentationStyle = UIModalPresentationFormSheet;
        _airlineListVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentModalViewController:_airlineListVC animated:YES];
        
        self.modalViewController.view.superview.bounds = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
        
        [_airlineListVC release];
    }
    else{
        airlineListVC = [[AirlineListViewController alloc]  initWithNibName:@"AirlineListViewController"
                                                                     bundle:nil
                                                                airlineList:airlineFileList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAirlineOpenNotification:) name:kNoticationAirlineOpen object:nil];
        [airlineListVC view];
        airlineListVC.navBar.topItem.rightBarButtonItem.action = @selector(closeAirlineListView);
        airlineListVC.navBar.topItem.rightBarButtonItem.target = self;
        
        UIView *blockView = [[UIView alloc] initWithFrame:self.view.frame];
        
        [blockView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
        
        airlineListVC.view.center = CGPointMake(blockView.bounds.size.width / 2.0, blockView.bounds.size.height / 2.0);
        [blockView addSubview:airlineListVC.view];
        
        [self.view addSubview:blockView];
        
        [blockView release];
    }
}

- (IBAction)enterAirlineManagementMenu:(id)sender {
    if (hudState == hud_state_airline_management) {
        return;
    }
    
    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Enter airline managment menu?") tag:hud_view_alert_dialog_airline_create];
}

- (IBAction)saveAirline:(id)sender {
    if(airlineFileName == nil){
        [self showAlertViewWithTitle:getLocalizeString(@"Save Airline")
                             message:getLocalizeString(@"Please input the airline name:")
                                 tag:hud_view_alert_dialog_airline_save
                      needsTextFiled:YES];
    }
    else{
        [EvaAirlineFile saveAirline:waypointAnnotationList toFile:airlineFileName];
    }
}

- (IBAction)clearAirline:(id)sender {
    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Clean current airline?") tag:hud_view_alert_dialog_airline_clear];
}

- (IBAction)exitAirlineManagementMenu:(id)sender {
    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Close airline managment menu?") tag:hud_view_alert_dialog_airline_management_exit];
}

- (IBAction)uploadAndVerifyAirline:(id)sender {
    if (airlineManagmentState == airline_managment_state_uploading) {
        [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Stop uploading current airline?") tag:hub_view_alert_dialog_airline_upload_cancel];
    }
    else{
        [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Upload airline?") tag:hub_view_alert_dialog_airline_upload_and_verify];
    }
}

- (IBAction)enableAirline:(id)sender {
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;

    if (osdData.satCount < 5) {
        [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"GPS Sat count is less than 5, can't perform the airline.")  tag:hud_view_alert_dialog_gps_count_not_enough];
    }
    else{
        evaCommand = eva_command_enable_airline;

        [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Airline ON?") tag:hud_view_alert_dialog_airline_enable];
    }
}

- (IBAction)disableAirline:(id)sender {
    evaCommand = eva_command_disable_airline;
    
    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") message:getLocalizeString(@"Airline OFF?")  tag:hud_view_alert_dialog_airline_disable];
}

- (IBAction)changeAltitude:(id)sender {
}

- (IBAction)locateToMyPosition:(id)sender {
    [self closeFlightModeView];
    
    BasicInfoManager *basicInfoManager = [BasicInfoManager sharedManager];
    if ([basicInfoManager locationIsUpdated] == NO) {
        [self showAlertViewWithTitle:getLocalizeString(@"Locate User") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"Can't locate user msg")
                                 tag:hud_view_alert_dialog_i_known];
        return;
    }

    CLLocationCoordinate2D coordinate = [(BasicInfoManager *)[BasicInfoManager sharedManager] location];
    MKCoordinateRegion region = mapView.region;
    region.center = coordinate;
    region.span = kDefaultCoordinateSpan;
    
    [mapView setRegion:region animated:NO];
}

- (IBAction)locateToDronePosition:(id)sender {
    [self closeFlightModeView];
    
    if([[[Transmitter sharedTransmitter] osdData] satCount] < 5){
        [self showAlertViewWithTitle:getLocalizeString(@"Locate EVA") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"GPS Sat count is less then 5, can't locate EVA")  tag:hud_view_alert_dialog_gps_count_not_enough];
        return;
    }

   float latitude = [[[Transmitter sharedTransmitter] osdData] latitude];
   float longitude = [[[Transmitter sharedTransmitter] osdData] longitude];
    
    MKCoordinateRegion region = mapView.region;
    region.center = CLLocationCoordinate2DMake(latitude, longitude);
    region.span = kDefaultCoordinateSpan;
    [mapView setRegion:region animated:NO];
}

- (IBAction)choseFlightMode:(id)sender {
    if (hudState != hud_state_flight_mode && hudState != hud_state_circle_flight && hudState != hud_state_point_flight) {
        if (flightModeVC.view.superview == nil) {
            [self.view insertSubview:flightModeVC.view belowSubview:hudDownPartImageView];
        }
        airlineManagementButton.enabled = FALSE;
        hudState = hud_state_flight_mode;
    }
}

- (IBAction)exitPointFlightMenu:(id)sender {
    [self showAlertViewWithTitle:getLocalizeString(@"Target Flight") message:getLocalizeString(@"Close target flight menu?") tag:hud_view_alert_dialog_exit_point_flight];
}

- (IBAction)cancelPointFlight:(id)sender {
    [self transmmitSimpleCommand:eva_command_cancel_point_flight];
}

- (IBAction)enterPointFlightMenu:(id)sender {
    if (pointFlightTargetAnnotation == nil) {
        [self showAlertViewWithTitle:getLocalizeString(@"Target Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"Please tap the map to set the target.") tag:hud_view_alert_dialog_i_known];
    }
    else{
        if([[[Transmitter sharedTransmitter] osdData] satCount] < 1){
            [self showAlertViewWithTitle:getLocalizeString(@"Target Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"GPS Sat count is less than 5, can't perform target flight.")  tag:hud_view_alert_dialog_gps_count_not_enough];
            return;
        }

        float radLat1 = droneAnnotation.coordinate.latitude * 3.1415926 / 180.0;
        float radLat2 = pointFlightTargetAnnotation.coordinate.latitude  * 3.1415926 / 180.0;
        float a = radLat1 - radLat2;
        
        float lng1 = droneAnnotation.coordinate.longitude * 3.1415926 / 180.0;
        float lng2 = pointFlightTargetAnnotation.coordinate.longitude * 3.1415926 / 180.0;
        float b = lng1 - lng2;
        
        float distance = 2 * asin(sqrt(pow(sin(a/2),2) +cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)));
        
        distance = distance * 6378137.0;
        
        if(distance > 800){
            [self showAlertViewWithTitle:getLocalizeString(@"Target Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"The target must within 800m.") tag:hud_view_alert_dialog_i_known];
        }
        else if(distance > 100){
            [self showAlertViewWithTitle:getLocalizeString(@"Target Flight")  cancelButtonTitle:getLocalizeString(@"No") okButtonTitle:getLocalizeString(@"Yes") message:getLocalizeString(@"The traget is 100m away, are you sure to flight to there?") tag:hud_view_alert_dialog_point_flight_distance_larger_than_100m];
        }
        else{
            [self setEvaToHoverMode];
            
            [[Transmitter sharedTransmitter] transmmitData:[EvaCommand getPointFlightCommandWithLongitude:pointFlightTargetAnnotation.coordinate.longitude latitude:pointFlightTargetAnnotation.coordinate.latitude]];
        }
    }
}

- (IBAction)exitCirleFlightMenu:(id)sender {
    [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") message:getLocalizeString(@"Close circle flight menu?") tag:hud_view_alert_dialog_exit_circle_flight];
}

- (IBAction)cancelCircleFlight:(id)sender {
    [self transmmitSimpleCommand:eva_command_cancel_circle_flight];
}

- (IBAction)ernterCircleFlightMenu:(id)sender {
    if (circleFlightCenterAnnotation == nil) {
        [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"Please tap the map to set the circle flight target.") tag:hud_view_alert_dialog_i_known];
    }
    else{
        if([[[Transmitter sharedTransmitter] osdData] satCount]  < 1){
            [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"GPS Sat count is less than 5, can't perform circle flight.") tag:hud_view_alert_dialog_gps_count_not_enough];
            return;
        }
        
        float radLat1 = droneAnnotation.coordinate.latitude * 3.1415926 / 180.0;
        float radLat2 = circleFlightCenterAnnotation.coordinate.latitude  * 3.1415926 / 180.0;
        float a = radLat1 - radLat2;
        
        float lng1 = droneAnnotation.coordinate.longitude * 3.1415926 / 180.0;
        float lng2 = circleFlightCenterAnnotation.coordinate.longitude * 3.1415926 / 180.0;
        float b = lng1 - lng2;
        
        float distance = 2 * asin(sqrt(pow(sin(a/2),2) +cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)));
        
        distance = distance * 6378137.0;
        
        if(distance > 800){
            [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"The circle flight target must within 800m.") tag:hud_view_alert_dialog_i_known];
        }
        else if(distance > 100){
            [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") cancelButtonTitle:getLocalizeString(@"No") okButtonTitle:getLocalizeString(@"Yes") message:getLocalizeString(@"The circle flight traget is out of 100m, are you sure?") tag:hud_view_alert_dialog_circle_flight_distance_larger_than_100m];
        }
        else{
            [self setEvaToHoverMode];

            [[Transmitter sharedTransmitter] transmmitData:[EvaCommand getCircleFlightCommandWithLongitude:circleFlightCenterAnnotation.coordinate.longitude latitude:circleFlightCenterAnnotation.coordinate.latitude]];
        }
    }
}

- (void)enableJoysticks:(BOOL)isMapMode_{
    isMapMode = isMapMode_;

    joystickLeftBackgroundImageView.hidden = isMapMode;
    joystickLeftThumbImageView.hidden = isMapMode;
    joystickLeftButton.hidden = isMapMode;
    joystickRightBackgroundImageView.hidden = isMapMode;
    joystickRightThumbImageView.hidden = isMapMode;
    joystickRightButton.hidden = isMapMode;
    
    if (isMapMode) {
        mapIsEnableTextLabel.text = getLocalizeString(@"Show Joysticks");
    }
    else{
        mapIsEnableTextLabel.text = getLocalizeString(@"Hide Joysticks");
    }
}

- (IBAction)setMapEnable:(id)sender {
    isMapMode = !isMapMode;
    
    [self enableJoysticks:isMapMode];
}

- (IBAction)hideDemoLabel:(id)sender {
    demoGcsLatitude.hidden = !(demoGcsLatitude.hidden);
    demoGcsLongitude.hidden = !(demoGcsLongitude.hidden);
}

- (IBAction)switchRcControlMode:(id)sender {
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;
    [self updateRcControlModeButton:osdData.physicalRcEnabled];

    if (osdData.physicalRcEnabled == YES) {
        evaCommand = eva_command_physical_rc_disable;

        [self showAlertViewWithTitle:getLocalizeString(@"Switch Control Mode") cancelButtonTitle:getLocalizeString(@"No") okButtonTitle:getLocalizeString(@"Yes") message:getLocalizeString(@"Switch to Touch Control mode?") tag:hud_view_alert_dialog_eva_command_simple];
    }
    else{
        evaCommand = eva_command_physical_rc_enable;
        
       [self showAlertViewWithTitle:getLocalizeString(@"Switch Control Mode")cancelButtonTitle:getLocalizeString(@"No") okButtonTitle:getLocalizeString(@"Yes")  message:getLocalizeString(@"Switch to Physical Control mode?")  tag:hud_view_alert_dialog_eva_command_simple];
    }
}

- (void)updateOSDView{
    [osdVC updateUI];
}

#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case hud_view_alert_dialog_eva_command_simple:
                if (evaCommand == eva_command_auto_take_off) {
                    NSLog(@"unlock motor");
                    [self transmmitSimpleCommand:eva_command_motor_unlock];
                }
                [self transmmitSimpleCommand:evaCommand];
                break;
            case hud_view_alert_dialog_eva_command_follow:
                [self closeFlightModeView];
         
                if ([[BasicInfoManager sharedManager] needsFollow]) {
                    [[BasicInfoManager sharedManager] setNeedsFollow:NO];
                    flightModeVC.followTextLabel.text = getLocalizeString(@"Track");
                    NSLog(@"stop tracking");
                }
                else{
                    BasicInfoManager *basicInfoManager = [BasicInfoManager sharedManager];
                    
                    if ([basicInfoManager locationIsUpdated] == NO) {
                        [self showAlertViewWithTitle: getLocalizeString(@"Track") cancelButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"can't track msg")  tag:hud_view_alert_dialog_i_known];                    }
                    else{
                        [[BasicInfoManager sharedManager] setNeedsFollow:YES];
                        flightModeVC.followTextLabel.text = getLocalizeString(@"Stop Track");
                        NSLog(@"start tracking");
                    }
                }
                break;
            case hud_view_alert_dialog_circle_flight:
                [self closeFlightModeView];
                [self activeMapViewForCircleFlight:YES];
                [self enableJoysticks:YES];
                hudState = hud_state_circle_flight;
                break;
            case hud_view_alert_dialog_point_flight:
                [self closeFlightModeView];
                [self activeMapViewForPointFlight:YES];
                [self enableJoysticks:YES];
                hudState = hud_state_point_flight;
                break;
            case hud_view_alert_dialog_airline_create:
                airlineNameTextLabel.text = @"*";
                [self abandonCurrentAirline];
                [self activeMapViewForAirlineManagement:YES];
                [self enableJoysticks:YES];
                [self switchAirlineManagmentState:airline_managment_state_edit];
                hudState = hud_state_airline_management;
                [self updateAirlineStateUI];
                airlineDistanceTextLabel.superview.hidden = NO;
                break;
            case hud_view_alert_dialog_airline_management_exit:
                [self abandonCurrentAirline];
                [self activeMapViewForAirlineManagement:NO];
                [self enableJoysticks:NO];
                hudState = hud_state_normal;
                [self updateAirlineStateUI];
                airlineDistanceTextLabel.superview.hidden = YES;
                break;
            case hud_view_alert_dialog_airline_clear:
                [self switchAirlineManagmentState:airline_managment_state_edit];
                [self clearCurrentAirline];
                [self updateAirlineStateUI];
                break;
            case hud_view_alert_dialog_airline_save:
                for (UIView * subview in [alertView subviews]) {
                    if ([subview isKindOfClass:[UITextField class]]) {
                        airlineFileName = [((UITextField *)subview).text retain];
                        if (airlineFileName == nil || [airlineFileName isEqualToString:@""]) {
                            [self showAlertViewWithTitle:getLocalizeString(@"Save Failed")
                                       cancelButtonTitle:getLocalizeString(@"I known")
                                                 message:getLocalizeString(@"The airline name can't be empty.")
                                                     tag:hud_view_alert_dialog_airline_file_name_wrong];
                            airlineFileName = nil;
                        }
                        else{
                            [EvaAirlineFile saveAirline:waypointAnnotationList toFile:airlineFileName];
                            airlineNameTextLabel.text = airlineFileName;
                        }
                        
                        return;
                    }
                }
                break;
            case hub_view_alert_dialog_airline_upload_and_verify:
                if (waypointAnnotationList.count == 0) {
                    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment")
                               cancelButtonTitle:getLocalizeString(@"I known")
                                         message:getLocalizeString(@"The airline is empty, please add some waypoints first.")
                                             tag:hud_view_alert_dialog_airline_empty];
                }
                else{
                    [self switchAirlineManagmentState:airline_managment_state_uploading];
                    
                    airlineUploader = [[EvaAirlineUploader alloc] initWithAirline:waypointAnnotationList delegate:self];
                    [[BasicInfoManager sharedManager] setAirlineUploader:airlineUploader];
                    
                    [airlineUploader upload];
                }
                
                break;
            case hub_view_alert_dialog_airline_upload_cancel:
                [self switchAirlineManagmentState:airline_managment_state_edit];
                [[BasicInfoManager sharedManager] setAirlineUploader:nil];
                [airlineUploader cancel];
                [airlineUploader release];
                airlineUploader = nil;
                break;
            case hud_view_alert_dialog_airline_enable:
                [self switchAirlineManagmentState:airline_managment_state_enable];
                
                //自动导航模式
                [[[BasicInfoManager sharedManager] channel5] setValue:1];
                [[[BasicInfoManager sharedManager] channel6] setValue:0];

                [self transmmitSimpleCommand:evaCommand];
                break;
            case hud_view_alert_dialog_airline_disable:
                [self switchAirlineManagmentState:airline_managment_state_uploaded];
                //hover mode
                [[[BasicInfoManager sharedManager] channel5] setValue:1];
                [[[BasicInfoManager sharedManager] channel6] setValue:-1];
                [self transmmitSimpleCommand:evaCommand];
                break;
            case hub_view_alert_dialog_enter_config:
                [self closeFlightModeView];
                [self showConfigView];
                break;
            case hud_view_alert_dialog_exit_circle_flight:
                [self hideCircleFlightMenu];
                if (circleFlightCenterAnnotation != nil) {
                    [mapView removeAnnotation:circleFlightCenterAnnotation];
                    [circleFlightCenterAnnotation release];
                    circleFlightCenterAnnotation = nil;
                }
                if (circleFlightRealCenterAnnotation != nil) {
                    [mapView removeAnnotation:circleFlightRealCenterAnnotation];
                    [circleFlightRealCenterAnnotation release];
                    circleFlightRealCenterAnnotation = nil;
                }
                
                [self activeMapViewForCircleFlight:NO];
                
                hudState = hud_state_normal;
                break;
            case hud_view_alert_dialog_exit_point_flight:
                [self hidePointFlightMenu];
                if (pointFlightTargetAnnotation != nil) {
                    [mapView removeAnnotation:pointFlightTargetAnnotation];
                    [pointFlightTargetAnnotation release];
                    pointFlightTargetAnnotation = nil;
                }
                if (pointFlightRealTargetAnnotation != nil) {
                    [mapView removeAnnotation:pointFlightRealTargetAnnotation];
                    [pointFlightRealTargetAnnotation release];
                    pointFlightRealTargetAnnotation = nil;
                }
                
                [self activeMapViewForPointFlight:NO];
                
                hudState = hud_state_normal;
                break;
            case hud_view_alert_dialog_point_flight_distance_larger_than_100m:
                [self setEvaToHoverMode];
                [[Transmitter sharedTransmitter] transmmitData:[EvaCommand getPointFlightCommandWithLongitude:pointFlightTargetAnnotation.coordinate.longitude latitude:pointFlightTargetAnnotation.coordinate.latitude]];
                break;
            case hud_view_alert_dialog_circle_flight_distance_larger_than_100m:
                [self setEvaToHoverMode];
                [[Transmitter sharedTransmitter] transmmitData:[EvaCommand getCircleFlightCommandWithLongitude:circleFlightCenterAnnotation.coordinate.longitude latitude:circleFlightCenterAnnotation.coordinate.latitude]];
                break;
            default:
                break;
        }
    }
    else{
       // NSLog(@"NO");
    }
}          
#pragma mark UIAlertViewDelegate Methods end

#pragma mark UIAlertView Methods
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(int)tag{
#ifdef __DEMO__
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
#else
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:getLocalizeString(@"No")
                                              otherButtonTitles:getLocalizeString(@"Yes"), nil];    
#endif
    
    
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

- (UITextField *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(int)tag needsTextFiled:(BOOL)needsTextField{
    if (needsTextField == NO) {
        [self showAlertViewWithTitle:title message:message tag:tag];
        return nil;
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:getLocalizeString(@"No")
                                              otherButtonTitles:getLocalizeString(@"Yes"), nil];
        alertView.tag = tag;
        
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 60);
//        [alertView setTransform:transform];
        
        UITextField *textField = [[UITextField alloc]
                                    initWithFrame:CGRectMake(12, 65, 260, 25)];
        textField.backgroundColor = [UIColor whiteColor];
        [alertView addSubview:textField];
        
        [alertView show];
        [alertView release];
        return [textField autorelease];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle message:(NSString *)message tag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

- (void)showAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle message:(NSString *)message tag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:okButtonTitle, nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

#pragma mark UIAlertView Methods end


#pragma mark EvaAirlineUploaderDelegate Methods
- (void)airlineUploader:(EvaAirlineUploader *)airlineUploader didSendWaypoint:(WaypointAnnotation *)waypoint{
    [mapView removeAnnotation:waypoint];
    [mapView addAnnotation:waypoint];
}

- (void)airlineUploader:(EvaAirlineUploader *)airlineUploader didUploadWaypoint:(WaypointAnnotation *)waypoint{
    [mapView removeAnnotation:waypoint];
    [mapView addAnnotation:waypoint];
}

- (void)airlineUploaderDidUpload:(EvaAirlineUploader *)airlineUploader_{
    //[self unblockTotalUIAnimated:[NSNumber numberWithBool:NO]];
    
    [[BasicInfoManager sharedManager] setAirlineUploader:nil];
    [airlineUploader cancel];
    [airlineUploader release];
    airlineUploader = nil;
    
    [self showAlertViewWithTitle:getLocalizeString(@"Airline Managment") cancelButtonTitle:nil okButtonTitle:getLocalizeString(@"I known") message:getLocalizeString(@"The airline is uploaded successfully.") tag:hub_view_alert_dialog_airline_upload_success];
    
    [self switchAirlineManagmentState:airline_managment_state_uploaded];
}

#pragma mark EvaAirlineUploaderDelegate Methods end

- (void)closeFlightModeView{
    if (flightModeVC.view.superview != nil) {
        [flightModeVC handleButtonDidTouchInside:flightModeVC.closeButton];
    }
    
    if (hudState == hud_state_flight_mode && hudState != hud_state_circle_flight && hudState != hud_state_point_flight) {
        hudState = hud_state_normal;
    }
    
    airlineManagementButton.enabled = YES;
}

#pragma mark FlightModeViewControlDelegate Methods

- (void)flightModeViewController:(FlightModeViewController *)flightModeVC_ buttonDidTouchUpInside:(UIButton *)button
{
    if (button == flightModeVC_.followButton) {
        if ([[BasicInfoManager sharedManager] needsFollow]) {
            [self showAlertViewWithTitle:getLocalizeString(@"Track") message:getLocalizeString(@"Stop tracking?") tag:hud_view_alert_dialog_eva_command_follow];
        }
        else{
            [self showAlertViewWithTitle:getLocalizeString(@"Track") message:getLocalizeString(@"Start tracking?") tag:hud_view_alert_dialog_eva_command_follow];
        }
    }
    else if(button == flightModeVC_.hoverButton){
        [self closeFlightModeView];
        [self setEvaToHoverMode];
    }
    else if (button == flightModeVC_.manualModeButton){
        [self closeFlightModeView];
        [self setEvaToManualMode];
    }
    else if (button == flightModeVC_.altHoldButton){
        [self closeFlightModeView];
        [self setEvaToAltHoldMode];
    }
    else if (button == flightModeVC_.circleButton){
        [self showAlertViewWithTitle:getLocalizeString(@"Circle Flight") message:getLocalizeString(@"Enter circle flight menu?") tag:hud_view_alert_dialog_circle_flight];
    }
    else if (button == flightModeVC_.fixedPositionButton){
        [self showAlertViewWithTitle:getLocalizeString(@"Target Flight") message:getLocalizeString(@"Enter target flight menu?") tag:hud_view_alert_dialog_point_flight];
    }
    else if (button == flightModeVC_.closeButton){
        hudState = hud_state_normal;
        airlineManagementButton.enabled = YES;
    }
    else{
        
    }
}

#pragma mark FlightModeViewControlDelegate Methods end

- (void)switchAirlineManagmentState:(airline_managment_state_t)state{
    switch (state) {
        case airline_managment_state_edit:
            airlineListButton.enabled           = YES;
            airlineDisableButton.enabled        = NO;
            airlineEnableButton.enabled         = NO;
            airlineSaveButton.enabled           = YES;
            airlineUploadButton.enabled         = YES;
            airlineClearButton.enabled          = YES;
            airlineAbandonButton.enabled        = YES;
            airlineAltitudeChangeButton.enabled = NO;
            airlineUploadTextLabel.text         = getLocalizeString(@"Upload Airline");
            break;
        case airline_managment_state_uploading:
            airlineListButton.enabled           = NO;
            airlineDisableButton.enabled        = NO;
            airlineEnableButton.enabled         = NO;
            airlineSaveButton.enabled           = YES;
            airlineUploadButton.enabled         = YES;
            airlineClearButton.enabled          = NO;
            airlineAbandonButton.enabled        = NO;
            airlineAltitudeChangeButton.enabled = NO;
            airlineUploadTextLabel.text         = getLocalizeString(@"Stop Upload");
            break;
        case airline_managment_state_uploaded:
            airlineListButton.enabled           = YES;
            airlineDisableButton.enabled        = YES;
            airlineEnableButton.enabled         = YES;
            airlineSaveButton.enabled           = YES;
            airlineUploadButton.enabled         = NO;
            airlineClearButton.enabled          = YES;
            airlineAbandonButton.enabled        = YES;
            airlineAltitudeChangeButton.enabled = NO;
            airlineUploadTextLabel.text         = getLocalizeString(@"Upload Airline");
            break;
        case airline_managment_state_enable:
            airlineListButton.enabled           = NO;
            airlineDisableButton.enabled        = YES;
            airlineEnableButton.enabled         = YES;
            airlineSaveButton.enabled           = NO;
            airlineUploadButton.enabled         = NO;
            airlineClearButton.enabled          = NO;
            airlineAbandonButton.enabled        = NO;
            airlineAltitudeChangeButton.enabled = YES;
            break;  
        default:
            break;
    }
    airlineManagmentState = state;
}

#pragma mark WaypointViewControllerDelegate Methods

- (void)waypointMenuViewController:(WaypointViewController *)waypointVC didChangeWaypoint:(WaypointAnnotation *)waypoint{
    [mapView removeAnnotation:waypoint];
    waypoint.style = waypoint_style_red;
    waypoint.isUploaded = NO;
    [mapView addAnnotation:waypoint];
    
    [self updateWaypointRoute];
    [airlineRouteAnnotationView regionChanged];

    [self switchAirlineManagmentState:airline_managment_state_edit];
}

#pragma mark WaypointViewControllerDelegate Methods end

- (void)showPointFlightMenu{
    if (pointFlightMenu.superview == nil) {
        pointFlightMenu.center = CGPointMake(200, 145);
        [self.view addSubview:pointFlightMenu];
    }
}

- (void)hidePointFlightMenu{
    if (pointFlightMenu.superview != nil) {
        [pointFlightMenu removeFromSuperview];
    }
}

- (void)showCircleFlightMenu{
    if (circleFlightMenu.superview == nil) {
        circleFlightMenu.center = CGPointMake(200, 145);
        [self.view addSubview:circleFlightMenu];
    }
}

- (void)hideCircleFlightMenu{
    if (circleFlightMenu.superview != nil) {
        [circleFlightMenu removeFromSuperview];
    }
}

#pragma mark Eva Mode set Methods

- (void)setEvaToHoverMode{
    Channel *channel5 = [[BasicInfoManager sharedManager] channel5];
    Channel *channel6 = [[BasicInfoManager sharedManager] channel6];
    
    channel5.value = 1;
    channel6.value = -1;
}

- (void)setEvaToManualMode{
    Channel *channel5 = [[BasicInfoManager sharedManager] channel5];
    channel5.value = -1;
}

- (void)setEvaToAltHoldMode{
    Channel *channel5 = [[BasicInfoManager sharedManager] channel5];
    channel5.value = 0;
}
#pragma mark Eva Mode Methods end

#pragma mark WaypointAnnotationViewDelegate Methods
- (void)waypointAnnotationViewDidTapped:(WaypointAnnotationView *)waypointAnnotationView{
    if (airlineManagmentState == airline_managment_state_uploading) {
        return;
    }
    
    selectedWaypoint = [waypointAnnotationView annotation];
    
    [_waypointMenuPopoverVC release];
    _waypointMenuPopoverVC = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSArray *list = nil;
        if (airlineManagmentState == airline_managment_state_enable) {
            list = [NSArray arrayWithObjects:getLocalizeString(@"Fly to Here"), nil];
        }
        else{
            list = [NSArray arrayWithObjects:getLocalizeString(@"Edit Waypoint"), getLocalizeString(@"Delete Waypoint"), nil];
        }
        
        WaypointMenuViewController *listVC = [[WaypointMenuViewController alloc] initWithList:list];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWaypointMenuItemDidSelect:) name:kNoticationDidSelectWaypointMenuItem object:nil];
        
        _waypointMenuPopoverVC = [[UIPopoverController alloc] initWithContentViewController:listVC];
        [listVC release];
        
        if (airlineManagmentState == airline_managment_state_enable) {
            listVC.view.bounds = CGRectMake(listVC.view.bounds.origin.x, listVC.view.bounds.origin.y, listVC.view.bounds.size.width, listVC.view.bounds.size.height / 2.0);
        }
        
        UIView *viewTapped = waypointAnnotationView;
        
        CGRect popoverRect;
        popoverRect.origin.x = viewTapped.frame.size.width / 2.0;
        popoverRect.origin.y = viewTapped.frame.size.height / 2.0;
        popoverRect.size.width = popoverRect.size.height = 1;
        _waypointMenuPopoverVC.popoverContentSize = _waypointMenuPopoverVC.contentViewController.view.frame.size;
        [_waypointMenuPopoverVC presentPopoverFromRect:popoverRect
                                                inView:viewTapped
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
    }else{
        //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"飞行器类型"
        //                                                                 delegate:self
        //                                                        cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"X四轴",@"+四轴", @"X六轴", @"+六轴", @"X八轴", @"+八轴", nil];
        //        [actionSheet showInView:self.view];
        //        [actionSheet release];
    }
}

- (void)waypointAnnotationViewDidDragged:(WaypointAnnotationView *)waypointAnnotationView newCenter:(CGPoint)newCenter{
    if (airlineManagmentState == airline_managment_state_uploading) {
        return;
    }
    else if(airlineManagmentState == airline_managment_state_enable){
        return; 
    }
    
    waypointAnnotationView.center = newCenter;
    
    WaypointAnnotation* waypoint = waypointAnnotationView.annotation;
    
    
    if (waypoint.style != waypoint_style_red) {
        waypoint.style = waypoint_style_red;
        waypoint.isUploaded = NO;
        
        [waypointAnnotationView setNeedsDisplay];
    }
    
    CLLocationCoordinate2D newCoordinate = [mapView convertPoint:newCenter toCoordinateFromView:waypointAnnotationView.superview];
    
    waypoint.coordinate = newCoordinate;
    
    [self updateWaypointRoute];
    [airlineRouteAnnotationView regionChanged];
    
    [self switchAirlineManagmentState:airline_managment_state_edit];
    
    [self updateAirlineStateUI];
}
#pragma mark WaypointAnnotationViewDelegate Methods end


- (void)updateDroneStatusTextLabel{
    NSString *flightModeStr = nil;
    
    EvaOSDData *osdData = [Transmitter sharedTransmitter].osdData;
    
    switch (osdData.flightMode) {
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
    
    droneStatusTextLabel.text = flightModeStr;
}


@end