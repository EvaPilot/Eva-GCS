//
//  EvaCommand.h
//  RCTouch
//
//  Created by koupoo on 13-3-30.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvaConfig.h"
#import "WaypointAnnotation.h"

typedef enum eva_simple_command{
    eva_command_download_airline     = 82,
    eva_command_cancel_point_flight  = 85,
    eva_command_cancel_circle_flight = 85,
    eva_command_config_read          = 104,
    eva_command_setup_enter          = 120,
    eva_command_setup_quit           = 121,
    eva_command_auto_take_off        = 88,
    eva_command_back_and_landing     = 87,
    eva_command_physical_rc_enable   = 89,
    eva_command_physical_rc_disable  = 90,
    eva_command_rc_calibrate         = 117,
    eva_command_enable_airline       = 122,
    eva_command_disable_airline      = 123,
    eva_command_motor_unlock         = 137,
    eva_command_carefree_enable      = 149,
    eva_command_carefree_disable     = 150,
    eva_command_mag_data_get         = 200
}eva_simple_command_t;

@interface EvaCommand : NSObject

+ (NSData *)getSimpleCommand:(eva_simple_command_t)commandCode;
+ (NSData *)getConfigReadCommand;
+ (NSData *)getConfigWriteCommand:(EvaConfig *)config;
+ (NSData *)getSetupEnterCommand;
+ (NSData *)getSetupQuitCommand;

+ (NSData *)getMagHCalibrateCommand;
+ (NSData *)getMagVCalibrateCommand;
+ (NSData *)getMagCalibrationSaveCommand;
+ (NSData *)getMagDataGetCommand;

+ (NSData *)getDummyCommand;

+ (NSData *)getFollowCommandWithLongitude:(float)longitude latitude:(float)latitude;

+ (NSData *)getWaypointUploadCommand:(WaypointAnnotation *)waypoint;
+ (NSData *)getWaypointCountSetCommand:(int)waypointCount;
+ (NSData *)getWaypointFlightToCommand:(int)no;

+ (NSData *)getPointFlightCommandWithLongitude:(float)longitude latitude:(float)latitude;
+ (NSData *)getCircleFlightCommandWithLongitude:(float)longitude latitude:(float)latitude;



@end
