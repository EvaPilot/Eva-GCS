//
//  MagCalibrationViewController.m
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "MagCalibrationViewController.h"
#import "EvaCommand.h"
#import "Transmitter.h"
#import "Macros.h"

@interface MagCalibrationViewController (){
    mag_calibration_mode_t magCalibrationMode;
    UIView *currentView;
    NSTimer *updateTimer;
}

@end

@implementation MagCalibrationViewController
@synthesize config = _config;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)showView:(mag_calibration_view_t)view{
    [self updateUI];
    
    switch (view) {
        case mag_calibration_view_h:
            if (currentView != hCalibrationView) {
                [currentView removeFromSuperview];
                currentView = hCalibrationView;
                [containerView addSubview:currentView];
            }
            break;
        case mag_calibration_view_v:
            if (currentView != vCalibrationView) {
                [currentView removeFromSuperview];
                currentView = vCalibrationView;
                [containerView addSubview:currentView];
            }
            break;
        case mag_calibration_view_save:
            if (currentView != dataSaveView) {
                [currentView removeFromSuperview];
                currentView = dataSaveView;
                [containerView addSubview:currentView];
            }
            break;
        case mag_calibration_view_state:
            hCalibrationNextButton.enabled = NO;
            if (currentView != stateView) {
                [currentView removeFromSuperview];
                currentView = stateView;
                [containerView addSubview:currentView];
            }
            break;
    }
}

- (void)updateUI
{
    int xyPointCount = [[[[Transmitter sharedTransmitter] magData] xyList] count];
    xyPointCountTextLabel.text = [NSString stringWithFormat:@"%d", xyPointCount];
    
    int zyPointCount = [[[[Transmitter sharedTransmitter] magData] zyList] count];
    zyPointCountTextLabel.text = [NSString stringWithFormat:@"%d", zyPointCount];
    
    if (magStateView.magData.dataIsLoaded) {
        NSLog(@"***[magStateView setNeedsDisplay];");
        [magStateView setNeedsDisplay];
    }
    
    
    switch (_config.magCalibrationState) {
        case mag_calibration_mode_h:
            isEnterHCalibrationTextLabel.text = getLocalizeString(@"EVA has entered calibration state");
            hCalibrationEnterButton.enabled = NO;
            hCalibrationNextButton.enabled = YES;
            dataIsSavedTextLabel.text = getLocalizeString(@"Not saved");
            dataSaveButton.enabled = YES;
            calibrationDoneButton.enabled = NO;
            break;
        case mag_calibration_mode_v:
            isEnterVCalibrationTextLabel.text = getLocalizeString(@"EVA has entered calibration state");
            vCalibrationEnterButton.enabled = NO;
            vCalibrationNextButton.enabled = YES;
            break;
        case mag_calibration_mode_saved:
            dataIsSavedTextLabel.text = getLocalizeString(@"Saved");
            dataSaveButton.enabled = NO;
            calibrationDoneButton.enabled = YES;
        default:
            isEnterHCalibrationTextLabel.text = getLocalizeString(@"EVA has not entered calibration state");            hCalibrationEnterButton.enabled = YES;
            hCalibrationNextButton.enabled = NO;
            
            isEnterVCalibrationTextLabel.text = getLocalizeString(@"EVA has not entered calibration state");
            vCalibrationEnterButton.enabled = YES;
            vCalibrationNextButton.enabled = NO;
            break;
    }
}

- (void)updateMode{
    magCalibrationMode = _config.magCalibrationState;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil config:(EvaConfig *)config
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _config = [config retain];
        magCalibrationMode = _config.magCalibrationState;
        
        currentView = nil;
        
        updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateUI) userInfo:nil repeats:YES] retain];
    }
    
    return self;
}

- (IBAction)buttonIsTouchUpInside:(id)sender {
    if (sender == hCalibrationEnterButton) {
        NSData *cmd = [EvaCommand getMagHCalibrateCommand];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
        
        cmd = [EvaCommand getSimpleCommand:eva_command_config_read];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
    }
    else if(sender == hCalibrationNextButton){
        NSData *cmd = [EvaCommand getMagVCalibrateCommand];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
        
        cmd = [EvaCommand getSimpleCommand:eva_command_config_read];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
        
        [self showView:mag_calibration_view_v];
    }
    else if(sender == vCalibrationEnterButton){
        NSData *cmd = [EvaCommand getMagVCalibrateCommand];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
        
        cmd = [EvaCommand getSimpleCommand:eva_command_config_read];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
    }
    else if(sender == vCalibrationNextButton){
        [self showView:mag_calibration_view_save];
    }
    else if(sender == dataSaveButton){
        NSData *cmd = [EvaCommand getMagCalibrationSaveCommand];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
        
        cmd = [EvaCommand getSimpleCommand:eva_command_config_read];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
    }
    else if(sender == calibrationDoneButton){
        [self showView:mag_calibration_view_state];
        [[[[Transmitter sharedTransmitter] magData] xyList] removeAllObjects];
        NSData *cmd = [EvaCommand getSimpleCommand:eva_command_mag_data_get];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
    }
    else if(sender == magDataGetButton){
        magStateView.magData.dataIsLoaded = NO;
        [[[[Transmitter sharedTransmitter] magData] xyList] removeAllObjects];
        [[[[Transmitter sharedTransmitter] magData] zyList] removeAllObjects];
        [magStateView setNeedsDisplay];
        
        NSData *cmd = [EvaCommand getSimpleCommand:eva_command_mag_data_get];
        [[Transmitter sharedTransmitter] transmmitData:cmd];
    }
    else{
        NSLog(@"unkonwn button");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     magStateView.magData = [[Transmitter sharedTransmitter] magData];
   // [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [updateTimer invalidate];
    [updateTimer release];
    [_config release];
    [containerView release];
    [hCalibrationView release];
    [vCalibrationView release];
    [dataSaveView release];
    [stateView release];
    [isEnterVCalibrationTextLabel release];
    [isEnterHCalibrationTextLabel release];
    [vCalibrationEnterButton release];
    [hCalibrationEnterButton release];
    [hCalibrationNextButton release];
    [vCalibrationNextButton release];
    [dataIsSavedTextLabel release];
    [calibrationDoneButton release];
    [dataSaveButton release];
    [magStateView release];
    [_navBar release];
    [magDataGetButton release];
    [xyPointCountTextLabel release];
    [zyPointCountTextLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [containerView release];
    containerView = nil;
    [hCalibrationView release];
    hCalibrationView = nil;
    [vCalibrationView release];
    vCalibrationView = nil;
    [dataSaveView release];
    dataSaveView = nil;
    [stateView release];
    stateView = nil;
    [isEnterVCalibrationTextLabel release];
    isEnterVCalibrationTextLabel = nil;
    [isEnterHCalibrationTextLabel release];
    isEnterHCalibrationTextLabel = nil;
    [vCalibrationEnterButton release];
    vCalibrationEnterButton = nil;
    [hCalibrationEnterButton release];
    hCalibrationEnterButton = nil;
    [hCalibrationNextButton release];
    hCalibrationNextButton = nil;
    [vCalibrationNextButton release];
    vCalibrationNextButton = nil;
    [dataIsSavedTextLabel release];
    dataIsSavedTextLabel = nil;
    [calibrationDoneButton release];
    calibrationDoneButton = nil;
    [dataSaveButton release];
    dataSaveButton = nil;
    [magStateView release];
    magStateView = nil;
    [self setNavBar:nil];
    [magDataGetButton release];
    magDataGetButton = nil;
    [xyPointCountTextLabel release];
    xyPointCountTextLabel = nil;
    [zyPointCountTextLabel release];
    zyPointCountTextLabel = nil;
    [super viewDidUnload];
}
@end
