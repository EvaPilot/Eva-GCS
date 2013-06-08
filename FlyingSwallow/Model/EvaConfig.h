//
//  EvaConfig.h
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaRawPackage.h"

typedef enum drone_type{
    DroneTypeQuadPlus = 0,
    DroneTypeQuadX = 1,
    DroneTypeHexPlus = 2,
    DroneTypeHexX = 3,
    DroneTypeOctoPlus = 4,
    DroneTypeOctoX = 5,
    DroneTypeUserDefined = 10
}drone_type_t;

typedef enum esc_type{
    EscTypeNormal = 0,
    EscTypeNarrow = 1,
    EscTypeIic = 2,
    EscTypeOther = 3
}esc_type_t;

typedef enum rc_type{
    RcTypeAdaptive = 0,
    RcTypeNormal = 1,
    RcTypeSbus = 2,
    RcTypePpm = 3
}rc_type_t;

typedef enum max_verticle_speed{
    MaxVerticleSpeed2 = 100,
    MaxVerticleSpeed4 = 200,
    MaxVerticleSpeed5 = 250

}max_verticle_speed_t;

typedef enum  overload_control_type{
    OverloadControlTypeSoft = 0,
    OverloadControlTypeNormal = 1,
    OverloadControlTypeHard = 2
}overload_control_type_t;

typedef enum batterry_alert_voltage{
    BatterryAlertVoltage3_5_5 = 0,
    BatterryAlertVoltage3_6_0 = 1,
    BatterryAlertVoltage3_6_5 = 2,
    BatterryAlertVoltage3_7_0 = 3
}batterry_alert_voltage_t;

typedef enum ptz_output_freq{
    PtzOutputFreq50 = 0,
    PtzOutputFreq250 = 1,
    PtzOutputFreq333 = 2,
    PtzOutputFreqOther = 3
}ptz_output_freq_t;


typedef enum mag_calibration_mode{
    mag_calibration_mode_pre    = -1,
    mag_calibration_mode_h      = 87,
    mag_calibration_mode_v      = 88,
    mag_calibration_mode_saved  = 89,     //89状态是回应保存动作，说明校验保存成功，之后读取magCalibrationState是0
    mag_calibration_mode_done  = 88888,
}mag_calibration_mode_t;

typedef enum map_mode{
    map_mode_standard = 0,
    map_mode_satellite = 1,
    map_mode_hybrid = 2
}map_mode_t;

@interface EvaConfig : NSObject

@property(nonatomic, assign) drone_type_t droneType;

@property(nonatomic, assign) rc_type_t rcType;
@property(nonatomic, assign) esc_type_t escType;

@property(nonatomic, assign) int pitchP;
@property(nonatomic, assign) int pitchI;
@property(nonatomic, assign) int pitchD;     //[0,100] pitch sensitivity

@property(nonatomic, assign) int rollP;
@property(nonatomic, assign) int rollI;      //晃动补偿
@property(nonatomic, assign) int rollD;      //[0,100] roll sensitivity

@property(nonatomic, assign) int yawP;
@property(nonatomic, assign) int yawD;

@property(nonatomic, assign) int throttleP;  //throttle P

@property(nonatomic, assign) int speedP;
@property(nonatomic, assign) int speedI;

@property(nonatomic, assign) float magDeclination;

@property(nonatomic, assign) int maxFlightSpeed; //单位m,除以25才是真实值
@property(nonatomic, assign) max_verticle_speed_t maxVerticleSpeed;  //单位m,除以50才是真实值

@property(nonatomic, assign) overload_control_type_t overloadControlType;

@property(nonatomic, assign) int ptzRollSensitivity;
@property(nonatomic, assign) int ptzPitchSensitivity;
@property(nonatomic, assign) ptz_output_freq_t ptzOutputFreq;

@property(nonatomic, assign) int batteryCellCount;
@property(nonatomic, assign) batterry_alert_voltage_t batterryAlertVoltage;

@property(nonatomic, assign) int controlType;  //control mode

@property(nonatomic, assign) int minGan;    //0 No, 1 Yes
@property(nonatomic, assign) int throttleSwitch; //0 No, 1 Yes

@property(nonatomic, assign) mag_calibration_mode_t magCalibrationState;

@property(nonatomic, assign) float interfaceOpacity;
@property(nonatomic, assign) BOOL isLeftHandMode;

@property(nonatomic, assign) map_mode_t mapMode;


- (id)initWithConfigFile:(NSString *)configFilePath;

-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage;

//持久化
- (void)save;

- (void)resetToDefault;



@end
