//
//  MagCalibrationViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagStateView.h"
#import "EvaConfig.h"

typedef enum mag_calibration_view{
    mag_calibration_view_h,
    mag_calibration_view_v,
    mag_calibration_view_save,
    mag_calibration_view_state,
}mag_calibration_view_t;

@interface MagCalibrationViewController : UIViewController{
    IBOutlet UIView *containerView;
    IBOutlet UIView *hCalibrationView;
    IBOutlet UIView *vCalibrationView;
    IBOutlet UIView *dataSaveView;
    IBOutlet UIView *stateView;
    
    IBOutlet UILabel *isEnterVCalibrationTextLabel;
    IBOutlet UILabel *isEnterHCalibrationTextLabel;
    IBOutlet UILabel *dataIsSavedTextLabel;
    
    IBOutlet UIButton *hCalibrationEnterButton;
    IBOutlet UIButton *hCalibrationNextButton;
    
    IBOutlet UIButton *vCalibrationEnterButton;
    IBOutlet UIButton *vCalibrationNextButton;
    
    IBOutlet UIButton *dataSaveButton;
    IBOutlet UIButton *calibrationDoneButton;
    
    IBOutlet UIButton *magDataGetButton;
    
    IBOutlet MagStateView *magStateView;
    
    IBOutlet UILabel *xyPointCountTextLabel;
    
    IBOutlet UILabel *zyPointCountTextLabel;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property(nonatomic, retain) EvaConfig *config;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil config:(EvaConfig *)config;

- (IBAction)buttonIsTouchUpInside:(id)sender;

- (void)showView:(mag_calibration_view_t)view;


@end
