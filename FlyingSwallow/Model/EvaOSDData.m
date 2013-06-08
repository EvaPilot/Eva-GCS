//
//  EvaOSD.m
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaOSDData.h"

@implementation EvaOSDData

@synthesize roll = _roll;
@synthesize pitch = _pitch;
@synthesize headAngle = _headAngle;

@synthesize satCount = _satCount;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize altitude = _altitude;
@synthesize distanceToHome = _distanceToHome;
@synthesize gpsVelocityX = _gpsVelocityX;
@synthesize gpsVelocityY = _gpsVelocityY;

@synthesize xekfVelocityX = _xekfVelocityX;
@synthesize xekfVelocityY = _xekfVelocityY;
@synthesize xekfVelocityD = _xekfVelocityD;

@synthesize mobileSatCount = _mobileSatCount;

@synthesize current = _current;
@synthesize consumedCurrent = _consumedCurrent;
@synthesize voltage = _voltage;
@synthesize voltageIsLow = _voltageIsLow;

@synthesize flightMode = _flightMode;

@synthesize waypointCount = _waypointCount;
@synthesize finishedWaypointCount = _finishedWaypointCount;

@synthesize photoCount = _photoCount;

@synthesize vibrateState = _vibrateState;
@synthesize shakeState = _shakeState;

@synthesize aileronValue = _aileronValue;
@synthesize elevatorValue = _elevatorValue;
@synthesize throttleValue = _throttleValue;
@synthesize yawValue = _yawValue;

@synthesize manualAileronValue = _manualAileronValue;
@synthesize manualElevatorValue = _manualElevatorValue;
@synthesize manualThrottleValue = _manualThrottleValue;
@synthesize manualYawValue = _manualYawValue;

@synthesize physicalRcEnabled = _physicalRcEnabled;


-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage{
    const Byte *p = [rawPackage.data bytes];
    
    _longitude = *(float*)(p+8);	
    _latitude = *(float*)(p+4);
    
    int rawAltitude =  p[49] * 256 + p[48];
	if (rawAltitude > 32768){
		rawAltitude -= 65536;
	}
    _altitude = rawAltitude / 10.0f;

    _distanceToHome = p[46]*256+p[52];
    _satCount = p[24]; 
	
	_gpsVelocityX = p[51]*256+p[50];
	if(_gpsVelocityX > 32768){
		_gpsVelocityX -= 65536;
	}
	
    _gpsVelocityY = p[95]*256+p[94];
	if(_gpsVelocityY > 32768){
		_gpsVelocityY -= 65536;
	}
	
	_xekfVelocityX = p[40]*256+p[41];
	if(_xekfVelocityX > 32768){
		_xekfVelocityX -= 65536;
	}
	
	_xekfVelocityY= p[83]*256+p[93];
	if(_xekfVelocityY > 32768){
		_xekfVelocityY -= 65536;
	}
    
    _xekfVelocityD = p[79]*256+p[89];
	if(_xekfVelocityD > 32768){
		_xekfVelocityD -= 65536;
	}
    
    _headAngle = (*((float *)(p+20)))* 180 / M_PI;
    
    _consumedCurrent = p[77]*256+p[76]; //mAH
    _current = p[92]; //A
    
    int rawVoltage =  p[71]*256+p[70];
	if (rawVoltage > 32768){
		rawVoltage -= 65536;
	}
    _voltage = rawVoltage / 4096.0 * 20.0;
    
    _voltageIsLow = p[78];
    
	/*
     mm++;
     NSString *dataStr =@"";
     dataStr = [NSString stringWithFormat:@"%d",mm];
     [GPSSatellites setText:dataStr];
     if(mm>5*100*10){
     mm = 0;
     }
     
     */
    
    _roll = *(int*)(p+66);
    _pitch = *(int*)(p+62);
    
    _flightMode = p[75];
    
    _finishedWaypointCount = p[74];
    _waypointCount = p[31];
    
    _photoCount = p[87]*256+p[86];
    
    int A2 = p[80]; //yaw的中值
	int A  = p[32];
    _manualYawValue = A - A2; //右拨是正

    A2 = p[81];
    A  = p[33];
    _manualAileronValue = A - A2;

    A2 = p[82];
	A  = p[34];
    _manualElevatorValue = A - A2;

    
    A  = 200-p[35];
    _manualThrottleValue = A;
    
    
    A2 = p[80];
	A  = p[36];
    _yawValue = A - A2; //右拨是正
    
    A2 = p[81];
	A  = p[37];
    _aileronValue = A - A2;

	A2 = p[81];
	A  = p[37];
    _elevatorValue = A - A2; //右拨是正
    
    A = 200-p[39];
    _throttleValue = A;
    
    A  = p[56];
    _vibrateState = A;
    
    A  = p[54];
    _shakeState = A;
    
    _physicalRcEnabled = !(p[53]);
    
    return YES;
}


@end
