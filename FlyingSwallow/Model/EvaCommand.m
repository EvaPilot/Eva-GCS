//
//  EvaCommand.m
//  RCTouch
//
//  Created by koupoo on 13-3-30.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaCommand.h"

@implementation EvaCommand

+ (NSData *)getSimpleCommand:(eva_simple_command_t)commandCode{
    Byte command[30];
	for(int i = 0; i < 30; i++){
		command[i] = 0;
	}
	command[0] = '$';
	command[1] = 'W';
	command[2] = 'I';
	command[3] = 'F';
	command[4] = 'I';
	command[5] = commandCode;
	command[6] = commandCode;
	command[7] = commandCode;
	command[8] = 0;
	command[9] = 0;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getSetupEnterCommand{
    return [self getSimpleCommand:120];
}

+ (NSData *)getSetupQuitCommand{
    return [self getSimpleCommand:121];
}

+ (NSData *)getConfigReadCommand{
    return [self getSimpleCommand:104];
}

+ (NSData *)getConfigWriteCommand:(EvaConfig *)config{
	Byte buf[20];
	
	buf[0] = config.rollP;
	buf[1] = config.rollI;
	buf[2] = config.rollD;
    buf[3] = config.throttleP;
	buf[4] = config.yawP;
	buf[5] = config.yawD;
	buf[6] = (config.minGan << 5) + (config.throttleSwitch << 4) + (config.batteryCellCount & 0x0f);
    buf[7] = (config.controlType & 0xF) + (config.overloadControlType << 4);
    
    float f = config.magDeclination;
    
    if(fabs(f) <= 10.0){
        f = f * 10.0;
    }
    else{
        if( f > 0) f += 100;
        if(f < 0)  f -= 100;
    }
    
    int nn=(int)f;
    if(nn < 0){
        nn += 256;
    }
    
	buf[8]  =nn;
	buf[9]  = config.droneType;
	buf[10] = config.pitchP;
	buf[11] = config.pitchD;
	buf[12] = config.ptzRollSensitivity;
	buf[13] = config.ptzPitchSensitivity;
	buf[14] = config.pitchI;
	buf[15] = config.maxFlightSpeed;
	buf[16] = config.speedP;
	buf[17] = config.speedI;
    
    int ptzOutputFreq = (config.ptzOutputFreq << 6) & 0xFF ;
    int escType = (config.escType << 4) & 0xFF;
    int batterryAlertVoltage = (config.batterryAlertVoltage << 2) & 0xFF ;
    int rcType = (config.rcType << 0) & 0xFF ;
    
	buf[18] =(Byte)(ptzOutputFreq + escType + batterryAlertVoltage + rcType);
	buf[19] = config.maxVerticleSpeed;
    
    NSLog(@"****config axVerticleSpeed:%d", buf[19]);
    
    
    Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
    
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =115;
	command[6] =command[5];
    
	for(int i = 0; i < 20; i++){
		command[7 + i] = buf[i];
	}
    
	int sum1 = 0;
	for(int i = 7; i < 14; i++){
		sum1 += command[i];
	}
	int sum2 = 0;
	for(int i = 14; i < 21; i++){
		sum2 += command[i];
	}
	
	int sum3=0;
	for(int i = 21; i < 27; i++){
		sum3 += command[i];
	}
	command[27] = sum1;
	command[28] = sum2;
	command[29] = sum3;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getMagHCalibrateCommand{
    Byte num = 9;
    Byte data = 87;
    
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =105;
	command[6] =105;
	command[7] =num;
	command[8] =data;
	command[9] =num;
	command[10] =data;
	command[11] =num;
	command[12] =data;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getMagVCalibrateCommand{
    Byte num = 9;
    Byte data = 88;
    
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =105;
	command[6] =105;
	command[7] =num;
	command[8] =data;
	command[9] =num;
	command[10] =data;
	command[11] =num;
	command[12] =data;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getMagCalibrationSaveCommand{
    Byte num = 9;
    Byte data = 89;
    
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =105;
	command[6] =105;
	command[7] =num;
	command[8] =data;
	command[9] =num;
	command[10] =data;
	command[11] =num;
	command[12] =data;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getDummyCommand{
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getMagDataGetCommand{
    return [self getSimpleCommand:eva_command_mag_data_get];
}


+ (NSData *)getFollowCommandWithLongitude:(float)longitude latitude:(float)latitude{
    Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	
	command[5] =(Byte)91;
    
    Byte *p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[6+i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[10 + i] = *(p+i);
    }
    p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[14 + i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[18 + i] = *(p+i);
    }
	command[22] =(Byte)91;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getWaypointUploadCommand:(WaypointAnnotation *)waypoint{
    float latitude = waypoint.coordinate.latitude;
    float longitude = waypoint.coordinate.longitude;
    
    int altitude = waypoint.altitude;
    int hoverTime = waypoint.hoverTime;
    int panxuan = waypoint.panxuan;
    int speed = waypoint.speed;
    int no = waypoint.no;
    
    Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
    
	command[0] = '$';
	command[1] = 'W';
	command[2] = 'I';
	command[3] = 'F';
	command[4] = 'I';
	command[5] = (Byte)83;
	command[6] = no;
    
//    if (no == 1) {
//        hoverTime = kFirstWaypointHoverTime;
//        panxuan = 90;
//        waypoint.hoverTime = hoverTime;
//        waypoint.panxuan = panxuan;
//    }
    
    if(panxuan < 2){
        panxuan =2;
        waypoint.panxuan = panxuan;
    }

    Byte *p = (Byte*)(&latitude);
    for (int i=0; i<4; i++) {
        command[7+i] = *(p+i);
    }
    
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[11+i] = *(p+i);
    }
        
    p = (Byte*)&altitude;
    for (int i=0; i<4; i++) {
        command[15+i] = *(p+i);
    }
    
	command[20] = (Byte)(hoverTime / 256);
	command[19] = (Byte)(hoverTime - command[20] * 256) ;
	
	command[21] = panxuan;
	command[22] = speed;
    
	int num =0;
	for (int i = 5; i < 23; i++) {
		num += command[i];
	}
    
	command[23] = (Byte)num;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getWaypointCountSetCommand:(int)waypointCount{
    Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
    
	command[0] = '$';
	command[1] = 'W';
	command[2] = 'I';
	command[3] = 'F';
	command[4] = 'I';
	command[5] = (Byte)84;
	command[6] = (Byte)waypointCount;
	command[7] = (Byte)waypointCount;
	command[8] = (Byte)waypointCount;
	command[9] = (Byte)84;
    
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getWaypointFlightToCommand:(int)no{
	Byte command[30];
	for(int i=0; i < 30; i++){
		command[i] = 0;
	}
	command[0] = '$';
	command[1] = 'W';
	command[2] = 'I';
	command[3] = 'F';
	command[4] = 'I';
	command[5] = 103;
	command[6] = command[5];
	command[7] = no;
	command[8] = command[7];
	command[9] = 0;
	
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getPointFlightCommandWithLongitude:(float)longitude latitude:(float)latitude{
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =(Byte)81;
    
    Byte *p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[6+i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[10+i] = *(p+i);
    }
    p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[14+i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[18+i] = *(p+i);
    }
	command[22] =(Byte)81;
	
    return [NSData dataWithBytes:command length:30];
}

+ (NSData *)getCircleFlightCommandWithLongitude:(float)longitude latitude:(float)latitude{
	Byte command[30];
	for(int i=0;i<30;i++){
		command[i] = 0;
	}
	command[0] ='$';
	command[1] ='W';
	command[2] ='I';
	command[3] ='F';
	command[4] ='I';
	command[5] =(Byte)92;
    
    Byte *p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[6+i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[10+i] = *(p+i);
    }
    p = (Byte*)&latitude;
    for (int i=0; i<4; i++) {
        command[14+i] = *(p+i);
    }
    p = (Byte*)&longitude;
    for (int i=0; i<4; i++) {
        command[18+i] = *(p+i);
    }
	command[22] =(Byte)92;
    
    return [NSData dataWithBytes:command length:30];
}


@end
