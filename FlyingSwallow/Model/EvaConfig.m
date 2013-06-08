//
//  EvaConfig.m
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaConfig.h"

#define kKeyConfigDroneType @"DroneType"
#define kKeyConfigRcType @"RcType"
#define kKeyConfigEscType @"EscType"
#define kKeyConfigRollP @"RollP"
#define kKeyConfigRollI @"RollI"
#define kKeyConfigRollD @"RollD"
#define kKeyConfigPitchP @"PitchP"
#define kKeyConfigPitchI @"PitchI"
#define kKeyConfigPitchD @"PitchD"
#define kKeyConfigYawP @"YawP"
#define kKeyConfigYawD @"YawD"
#define kKeyConfigThrottleP @"ThrottleP"
#define kKeyConfigSpeedP @"SpeedP"
#define kKeyConfigSpeedI @"SpeedI"
#define kKeyConfigMagDeclination @"agDeclination"
#define kKeyConfigMaxFlightSpeed @"MaxFlightSpeed"
#define kKeyConfigMaxVerticleSpeed @"MaxVerticleSpeed"
#define kKeyConfigOverloadControlType @"OverloadControlType"
#define kKeyConfigPtzRollSensitivity @"PtzRollSensitivity"
#define kKeyConfigPtzPitchSensitivity @"PtzPitchSensitivity"
#define kKeyConfigPtzOutputFreq @"PtzOutputFreq"
#define kKeyConfigBatteryCellCount @"BatteryCellCount"
#define kKeyConfigBatterryAlertVoltage @"BatterryAlertVoltage"
#define kKeyConfigControlType @"ControlType"
#define kKeyConfigMinGan @"MinGan"
#define kKeyConfigThrottleSwitch @"ThrottleSwitch"
#define kKeyMagCalibrationState @"MagCalibrationState"
#define kKeyInterfaceOpacity @"InterfaceOpacity"
#define kKeyIsLeftHandMode @"IsLeftHandMode"
#define kKeyMapMode @"MapMode"

@implementation EvaConfig{
    NSString *path;
    NSMutableDictionary *configDict;
}

@synthesize droneType = _droneType;

@synthesize rcType = _rcType;
@synthesize escType = _escType;

@synthesize rollP = _rollP;
@synthesize rollI = _rollI;
@synthesize rollD = _rollD;

@synthesize pitchP = _pitchP;
@synthesize pitchI = _pitchI;
@synthesize pitchD = _pitchD;

@synthesize yawP = _yawP;
@synthesize yawD = _yawD;

@synthesize throttleP = _throttleP;

@synthesize speedP = _speedP;
@synthesize speedI = _speedI;

@synthesize magDeclination = _magDeclination;

@synthesize maxFlightSpeed = _maxFlightSpeed;
@synthesize maxVerticleSpeed = _maxVerticleSpeed;

@synthesize overloadControlType = _overloadControlType;

@synthesize ptzRollSensitivity = _ptzRollSensitivity;
@synthesize ptzPitchSensitivity = _ptzPitchSensitivity;
@synthesize ptzOutputFreq = _ptzOutputFreq;

@synthesize batteryCellCount = _batteryCellCount;
@synthesize batterryAlertVoltage = _batterryAlertVoltage;

@synthesize controlType = _controlType;

@synthesize minGan = _minGan;
@synthesize throttleSwitch = _throttleSwitch;

@synthesize magCalibrationState = _magCalibrationState;

@synthesize interfaceOpacity = _interfaceOpacity;
@synthesize isLeftHandMode = _isLeftHandMode;

@synthesize mapMode = _mapMode;

- (id)initWithConfigFile:(NSString *)configFilePath{
    if(self = [super init]){
        path = [configFilePath retain];
        configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        _droneType = [[configDict objectForKey:kKeyConfigDroneType] intValue];
        _escType = [[configDict objectForKey:kKeyConfigEscType] intValue];
        _rollP = [[configDict objectForKey:kKeyConfigRollP] intValue];
        _rollI = [[configDict objectForKey:kKeyConfigRollI] intValue];
        _rollD = [[configDict objectForKey:kKeyConfigRollD] intValue];
        _pitchP = [[configDict objectForKey:kKeyConfigPitchP] intValue];
        _pitchI = [[configDict objectForKey:kKeyConfigPitchI] intValue];
        _pitchD = [[configDict objectForKey:kKeyConfigPitchD] intValue];
        _yawP = [[configDict objectForKey:kKeyConfigYawP] intValue];
        _yawD = [[configDict objectForKey:kKeyConfigYawD] intValue];
        _throttleP = [[configDict objectForKey:kKeyConfigThrottleP] intValue];
        _speedP = [[configDict objectForKey:kKeyConfigSpeedP] intValue];
        _speedI = [[configDict objectForKey:kKeyConfigSpeedI] intValue];
        _magDeclination = [[configDict objectForKey:kKeyConfigMagDeclination] intValue];
        _maxFlightSpeed = [[configDict objectForKey:kKeyConfigMaxFlightSpeed] intValue];
        _maxVerticleSpeed = [[configDict objectForKey:kKeyConfigMaxFlightSpeed] intValue];
        _overloadControlType = [[configDict objectForKey:kKeyConfigOverloadControlType] intValue];
        _ptzRollSensitivity = [[configDict objectForKey:kKeyConfigPtzRollSensitivity] intValue];
        _ptzPitchSensitivity = [[configDict objectForKey:kKeyConfigPtzPitchSensitivity] intValue];
        _ptzOutputFreq = [[configDict objectForKey:kKeyConfigPtzOutputFreq] intValue];
        _batteryCellCount = [[configDict objectForKey:kKeyConfigBatteryCellCount] intValue];
        _batterryAlertVoltage = [[configDict objectForKey:kKeyConfigBatterryAlertVoltage] intValue];
        _controlType = [[configDict objectForKey:kKeyConfigControlType] intValue];
        _minGan = [[configDict objectForKey:kKeyConfigMinGan] intValue];
        _throttleSwitch = [[configDict objectForKey:kKeyConfigThrottleSwitch] intValue];
        _magCalibrationState = [[configDict objectForKey:kKeyMagCalibrationState] intValue];
        _interfaceOpacity = [[configDict objectForKey:kKeyInterfaceOpacity] floatValue];
        _isLeftHandMode = [[configDict objectForKey:kKeyIsLeftHandMode] boolValue];
        
        _mapMode = [[configDict objectForKey:kKeyMapMode] intValue];
    }
    
    return self;
}

- (void)setInterfaceOpacity:(float)interfaceOpacity{
    _interfaceOpacity = interfaceOpacity;
    
    [configDict setObject:[NSNumber numberWithFloat:_interfaceOpacity] forKey:kKeyInterfaceOpacity];
}

- (void)setIsLeftHandMode:(BOOL)isLeftHandMode{
    _isLeftHandMode = isLeftHandMode;
    
    [configDict setObject:[NSNumber numberWithBool:_isLeftHandMode] forKey:kKeyIsLeftHandMode];
}

- (void)setMapMode:(map_mode_t)mapMode{
    _mapMode = mapMode;
    
    [configDict setObject:[NSNumber numberWithInt:_mapMode] forKey:kKeyMapMode];
}

-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage{
    const Byte *p = [rawPackage.data bytes];

    _rollP = p[4+3];
    _rollI = p[4+29];
	_rollD = p[4+34];
    
    _pitchP = p[4+22];
	_pitchI = p[4+18];
	_pitchD = p[4+20];
    
	_yawP = p[4+0];
	_yawD = p[4+2];
    
    _throttleP = p[4+8];
    
    _speedP = p[4+21];
    _speedI = p[4+24];
    
    _maxVerticleSpeed = p[4 + 5];

	_batteryCellCount =p[4+1] & 0x0f;
    _throttleSwitch = (p[4+1] >> 4) & 0x01;
    _minGan = (p[4+1] >> 5) & 0x01;
    
	_controlType = p[4+38] & 0x0F;
    _overloadControlType = p[4+38]>> 4 & 0x0F;

    
	Byte b =p[4+23];
    int Ci = b;
    if(Ci>=127) Ci-= 256;
    
    if(abs(Ci)<=100){
        _magDeclination = Ci / 10.0;
    }
    else{
        if(Ci>0) Ci-=100;
        if(Ci<0) Ci+=100;
        
        _magDeclination = Ci;
    }
	
	_droneType = p[4+30];
	
    _ptzRollSensitivity = p[4+13];
    if (_ptzRollSensitivity >= 128) {
        _ptzRollSensitivity -= 256;
    }

	_ptzPitchSensitivity = p[4+19];
    if (_ptzPitchSensitivity >= 128) {
        _ptzPitchSensitivity -= 256;
    }
	
	_maxFlightSpeed = p[4+28];
//    if(b==90){
//        _maxFlightSpeed = 3.6;
//    }
//    else if(b==120){
//        _maxFlightSpeed = 4.8;
//    }
//    else if(b==150){
//        _maxFlightSpeed = 6.0;
//    }
//    else if(b==200){
//        _maxFlightSpeed = 8.0;
//    }
//    else if(b==255){
//        _maxFlightSpeed = 10.2;
//    }
//    else{
//       _maxFlightSpeed = b / 25.0;
//    }

    _rcType = p[4+39] & 0x03;
    _batterryAlertVoltage = p[4+39] >> 2 & 0x03;
    _escType = p[4+39] >> 4 & 0x03;
    _ptzOutputFreq = p[4+39] >> 6 & 0x03;
    
    _magCalibrationState = p[4 + 9];
    
    NSLog(@"***begin***");
    NSLog(@"***drone type:%d",_droneType);
    NSLog(@"***rcType:%d", _rcType);
    NSLog(@"***escType:%d", _escType);
    NSLog(@"***pitchP:%d", _pitchP);
    NSLog(@"***pitchI:%d", _pitchI);
    NSLog(@"***pitchD:%d", _pitchD);
    NSLog(@"***rollP:%d", _rollP);
    NSLog(@"***rollI:%d", _rollI);
    NSLog(@"***rollD:%d", _rollD);
    NSLog(@"***yawP:%d", _yawP);
    NSLog(@"***yawD:%d", _yawD);
    NSLog(@"***throttleP:%d", _throttleP);
    NSLog(@"***speedP:%d", _speedP);
    NSLog(@"***speedI:%d", _speedI);
    NSLog(@"***magDeclination:%.2f", _magDeclination);
    NSLog(@"***maxFlightSpeed:%d", _maxFlightSpeed);
    NSLog(@"***maxVerticleSpeed:%d", _maxVerticleSpeed);
    NSLog(@"***overloadControlType:%d", _overloadControlType);
    NSLog(@"***ptzRollSensitivity:%d", _ptzRollSensitivity);
    NSLog(@"***ptzPitchSensitivity:%d", _ptzPitchSensitivity);
    NSLog(@"***ptzOutputFreq:%d", _ptzOutputFreq);
    NSLog(@"***batteryCellCount:%d", _batteryCellCount);
    NSLog(@"***batterryAlertVoltage:%d", _batterryAlertVoltage);
    NSLog(@"***controlType:%d", _controlType);
    NSLog(@"***minGan:%d", _minGan);
    NSLog(@"***throttleSwitch:%d", _throttleSwitch);
    NSLog(@"***magCalibrationState:%d", _magCalibrationState);
    NSLog(@"****end****");
    
    return YES;
}

- (void)save{
    [configDict writeToFile:path atomically:YES];
}

- (void)resetToDefault{
    NSString *defaultConfigFilePath = [[NSBundle mainBundle] pathForResource:@"EvaConfig" ofType:@"plist"];
    
    EvaConfig *defaultConfig = [[EvaConfig alloc] initWithConfigFile:defaultConfigFilePath];
    
    _droneType = defaultConfig.droneType;
    _escType = defaultConfig.escType;
    _rollP = defaultConfig.rollP;
    _rollI = defaultConfig.rollI;
    _rollD = defaultConfig.rollD;
    _pitchP = defaultConfig.pitchP;
    _pitchI = defaultConfig.pitchI;
    _pitchD = defaultConfig.pitchD;
    _yawP = defaultConfig.yawP;
    _yawD = defaultConfig.yawD;
    _throttleP = defaultConfig.throttleP;
    _throttleP = defaultConfig.throttleP;
    _speedP = defaultConfig.speedP;
    _speedI = defaultConfig.speedI;
    _magDeclination = defaultConfig.magDeclination;
    _maxFlightSpeed = defaultConfig.maxFlightSpeed;
    _maxVerticleSpeed = defaultConfig.maxVerticleSpeed;
    _overloadControlType = defaultConfig.overloadControlType;
    _ptzRollSensitivity = defaultConfig.ptzRollSensitivity;
    _ptzPitchSensitivity = defaultConfig.ptzPitchSensitivity;
    _ptzOutputFreq = defaultConfig.ptzOutputFreq;
    _batteryCellCount = defaultConfig.batteryCellCount;
    _batterryAlertVoltage = defaultConfig.batterryAlertVoltage;
    _controlType = defaultConfig.controlType;
    _minGan = defaultConfig.minGan;
    _throttleSwitch = defaultConfig.throttleSwitch;
    _magCalibrationState = defaultConfig.magCalibrationState;
    _interfaceOpacity = defaultConfig.interfaceOpacity;
    _isLeftHandMode = defaultConfig.isLeftHandMode;
    _mapMode = defaultConfig.mapMode;
    
    [defaultConfig release];
}

- (void)dealloc{
    [path release];
    [configDict release];
    [super dealloc];
}

@end
