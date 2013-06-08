//
//  PPMTransmitter.h
//  RCTouch
//
//  Created by koupoo on 13-3-15.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaOSDData.h"
#import "EvaConfig.h"
#import "EvaMag.h"


enum PpmPolarity {
    PPM_POLARITY_POSITIVE,
    PPM_POLARITY_NEGATIVE
};

typedef enum {
    TransmitterStateError = 0,
    TransmitterStateOk = 1,
}TransmitterState;


#define kNotificationTransmitterStateDidChange @"NotificationTransmitterStateDidChange"


@interface Transmitter: NSObject

//控制是否发送ppm包，为NO时，OSD请求还是可以被发送的
@property (nonatomic, assign) BOOL needsTransmmitPpmPackage;

+ (Transmitter *)sharedTransmitter;

//以下的方法均非线程安全
- (BOOL)start;
- (BOOL)stop;
- (void)setPpmValue:(float)value atChannel:(int)channelIdx;

- (BOOL)transmmitData:(NSData *)data;

@property(nonatomic, assign) TransmitterState outputState;
@property(nonatomic, assign) TransmitterState inputState ;


@property(nonatomic, retain) EvaOSDData *osdData;
@property(nonatomic, retain) EvaConfig *config;
@property(nonatomic, retain) EvaMag *magData;

@end
