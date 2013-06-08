//
//  MaxFlightSpeedListViewController.h
//  RCTouch
//
//  Created by koupoo on 13-3-31.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationDidSelectMagCalibrationMenuItem @"NDidSelectMagCalibrationMenuItem"
#define kMagCalibrationMenuKeyItem @"Item"

typedef enum mag_calibration_menu_item{
    mag_calibration_menu_item_calibrate = 0,
    mag_calibration_menu_item_state = 1
}mag_calibration_menu_item_t;

@interface MagCalibrationMenuViewController : UIViewController{
    IBOutlet UITableView *listTableView;
}

@property (nonatomic, retain) NSArray *list;

- (id)initWithList:(NSArray *)list;

@end

