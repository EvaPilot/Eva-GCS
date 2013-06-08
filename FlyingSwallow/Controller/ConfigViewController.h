//
//  ConfigurationViewController.h
//  RCTouch
//
//  Created by koupoo on 13-3-25.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaConfig.h"
#import "EvaOSDData.h"
#import "FSSlider.h"
#import "ChannelView.h"

#define kNotificationDismissConfigView @"NotificationDismissConfigView"

@class ConfigViewController;

@protocol ConfigViewControllerDelegate <NSObject>

- (void)configViewController:(ConfigViewController *)ctrl interfaceOpacityValueDidChange:(float)newValue;
- (void)configViewController:(ConfigViewController *)ctrl leftHandedValueDidChange:(BOOL)enabled;
- (void)configViewController:(ConfigViewController *)ctrl mapModeDidChange:(map_mode_t)mapMode;

@end


@interface ConfigViewController : UIViewController<UIActionSheetDelegate>{
    IBOutlet UIView *fixPageView;
    IBOutlet UIView *motroConfigPageView;
    IBOutlet UIView *rcConfigPageView;
    IBOutlet UIView *speedControlPageView;
    IBOutlet UIView *autoPilotSystemPageView;
    IBOutlet UIView *ptzConfigPageView;
    IBOutlet UIView *powerConfigPageView;
    IBOutlet UIView *interfaceConfigPageView;
    IBOutlet UITableView *configListTableView;    
    IBOutlet UIView *configPageViewHolder;
    
    
    IBOutlet UIButton *backButton;

    IBOutlet UIButton *configReadButton;
    IBOutlet UIButton *configWriteButton;
    
    IBOutlet UILabel *droneTypeLabel;
    
    IBOutlet UISegmentedControl *escTypeSegmentControl;
    IBOutlet UISegmentedControl *rcTypeSegmentControl;
    IBOutlet UISegmentedControl *maxVerticleSpeedSegmentControl;
    
    IBOutlet UISegmentedControl *overloadControlSegmentControl;
    IBOutlet UISegmentedControl *batteryCellCountSegmentControl;
    IBOutlet UISegmentedControl *batterryAlertVoltageSegmentControl;
    IBOutlet UISegmentedControl *throttleModeSegmentControl;

    IBOutlet UISlider *rollDSlider;
    IBOutlet UISlider *pitchDSlider;
    IBOutlet UISlider *throttlePSlider;
    IBOutlet UISlider *rollISlider;
    IBOutlet UISlider *maxFlightSpeedSlider;
    
    IBOutlet UILabel *rollDTextLabel;
    IBOutlet UILabel *pitchDTextLabel;
    IBOutlet UILabel *throttlePTextLabel;
    IBOutlet UILabel *rollITextLabel;
    
    IBOutlet UITextField *magDeclinationTextField;
    
    IBOutlet UISlider *ptzRollSensitivitySlider;
    IBOutlet UISlider *ptzPitchSensitivitySlider;
    IBOutlet UILabel *ptzRollSensitivityTextLabel;
    IBOutlet UILabel *ptzPitchSensitivityTextLabel;
    IBOutlet UISegmentedControl *ptzOutputFreqSegmentControl;
    IBOutlet UILabel *batteryTypeTextLabel;
    IBOutlet UISlider *interfaceOpacitySlider;
    IBOutlet UILabel *interfaceOpacityTextLabel;
    
    IBOutlet UILabel *maxFlightSpeedTextLabel;
    
    IBOutlet ChannelView *channelView;
    IBOutlet UILabel *flightModeTextLabel;
    IBOutlet UILabel *isConnectedTextLabel;
    
    IBOutlet UISegmentedControl *mapModeSegmentControl;
    
    
    //iPhone
    
    IBOutlet UIScrollView *configPageScrollView;
    
    IBOutlet UIButton *previousPageButton;
    IBOutlet UIButton *nextPageButton;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UILabel *pageTitleLabel;
    
    
    
}

@property(nonatomic, retain) EvaConfig *config;
@property(nonatomic, retain) EvaOSDData *osdData;

@property(nonatomic, assign) BOOL isConnected;

@property(nonatomic, assign) NSObject<ConfigViewControllerDelegate> *delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil config:(EvaConfig *)config;

- (void)updateFilghtModeTextFiled;
- (void)updateChannelView;
- (void)updateUI;

- (IBAction)buttonDidTouchUpInside:(id)sender;

- (IBAction)choseDroneType:(id)sender;

- (IBAction)readConfig:(id)sender;
- (IBAction)writeConfig:(id)sender;
- (IBAction)showMagCalibrationMenu:(id)sender;

- (IBAction)choseMaxFlightSpeed:(id)sender;

- (IBAction)calibrateRc:(id)sender;

- (IBAction)segmentControlValueDidChanged:(id)sender;

- (IBAction)sliderDidRelease:(id)sender;
- (IBAction)sliderValueDidChanged:(id)sender;

- (IBAction)previousPage:(id)sender;
- (IBAction)nextPage:(id)sender;



@end
