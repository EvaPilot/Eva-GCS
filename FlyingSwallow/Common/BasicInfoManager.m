//
//  BasicInfo.m
//  EMagazine
//
//  Created by koupoo on 11-7-5.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import "BasicInfoManager.h"

static BasicInfoManager *sharedManager;

@implementation BasicInfoManager


@synthesize debugTextView;
@synthesize osdInfoPaneVC;
@synthesize osdAttitudePaneVC;
@synthesize osdVC;
@synthesize configVC;
@synthesize location;
@synthesize pointFlightTargetLocation;
@synthesize circleFlightCenterLocation;
@synthesize needsFollow;
@synthesize locationIsUpdated;
@synthesize isConnected;
@synthesize airlineUploader;
@synthesize aileronChannel;
@synthesize elevatorChannel;
@synthesize rudderChannel;
@synthesize throttleChannel;
@synthesize channel5;
@synthesize channel6;

+ (id)sharedManager{
	if (sharedManager == nil) {
		sharedManager = [[super alloc] init];
		return sharedManager;
	}
	return sharedManager;
}

- (void)dealloc{
	[debugTextView release];
    [osdInfoPaneVC release];
    [osdAttitudePaneVC release];
    [osdVC release];
    [configVC release];
    [airlineUploader release];
    [aileronChannel release];
    [elevatorChannel release];
    [rudderChannel release];
    [throttleChannel release];
    [channel5 release];
    [channel6 release];
	[super dealloc];
}

@end
