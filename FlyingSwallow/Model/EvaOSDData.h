//
//  EvaOSD.h
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaRawPackage.h"

typedef enum flight_mode{
    FlightModeManual = 0,
    FlightModeAutoHovering = 1,
    FlightModeAutoNavigation = 2,
    FlightModeCirclePosition = 3,
    FlightModeRealtimeWaypoint = 4,
    FlightModeAutoWaypointCircling = 5,
    FlightModeSemiAutomatic = 6,
    FlightModeSettingsState = 7,
    FlightModeZeroGyro = 8,
    FlightModeAltitudeError = 9,
    FlightModeAirSpeedError = 10,
    FlightModeBackLanding = 11,
    FlightModeMunualSetAltitude = 15,
    FlightModeUnkonwn = 100
}flight_mode_t;

@interface EvaOSDData : NSObject

@property(nonatomic, assign) float roll;
@property(nonatomic, assign) float pitch;
@property(nonatomic, assign) float headAngle;

@property(nonatomic, assign) int satCount;
@property(nonatomic, assign) float longitude;    //飞行器的经度
@property(nonatomic, assign) float latitude;     //飞行器的纬度
@property(nonatomic, assign) float altitude;     //以m为单位，小数点后面两位精度
@property(nonatomic, assign) int distanceToHome; //以米为单位
@property(nonatomic, assign) int gpsVelocityX;
@property(nonatomic, assign) int gpsVelocityY;

@property(nonatomic, assign) int xekfVelocityX;
@property(nonatomic, assign) int xekfVelocityY;
@property(nonatomic, assign) int xekfVelocityD;

@property(nonatomic, assign) int mobileSatCount;

@property(nonatomic, assign) int current;          //单位是A
@property(nonatomic, assign) int consumedCurrent;  //单位是mAH
@property(nonatomic, assign) float voltage;
@property(nonatomic, assign) BOOL voltageIsLow;

@property(nonatomic, assign) int flightMode;

@property(nonatomic, assign) int waypointCount;          //总的航点数
@property(nonatomic, assign) int finishedWaypointCount;  //已经完成的航点数

@property(nonatomic, assign) int photoCount;

@property(nonatomic, assign) int vibrateState; //震动系数
@property(nonatomic, assign) int shakeState;   //晃动系数


@property(nonatomic, assign) int aileronValue;
@property(nonatomic, assign) int elevatorValue;
@property(nonatomic, assign) int throttleValue;
@property(nonatomic, assign) int yawValue;

@property(nonatomic, assign) int manualAileronValue;
@property(nonatomic, assign) int manualElevatorValue;
@property(nonatomic, assign) int manualThrottleValue;
@property(nonatomic, assign) int manualYawValue;

@property(nonatomic, assign) BOOL physicalRcEnabled;


-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage;


@end
