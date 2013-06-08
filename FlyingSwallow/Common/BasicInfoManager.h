//
//  BasicInfo.h
//  EMagazine
//
//  Created by koupoo on 11-7-5.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDAttitudePaneViewController.h"
#import "OSDInfoPaneViewController.h"
#import "ConfigViewController.h"
#import "OSDViewController.h"
#import "EvaGcsLocation.h"
#import "Channel.h"
#import "EvaAirlineUploader.h"
#import <CoreLocation/CoreLocation.h>


@interface BasicInfoManager : NSObject {
}

@property (nonatomic, retain) UITextView *debugTextView;
@property (nonatomic, retain) OSDInfoPaneViewController *osdInfoPaneVC;
@property (nonatomic, retain) OSDAttitudePaneViewController *osdAttitudePaneVC;
@property (nonatomic, retain) OSDViewController *osdVC;
@property (nonatomic, retain) ConfigViewController *configVC;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) CLLocationCoordinate2D pointFlightTargetLocation;
@property (nonatomic, assign) CLLocationCoordinate2D circleFlightCenterLocation;
@property (nonatomic, assign) BOOL needsFollow;
@property (nonatomic, assign) BOOL locationIsUpdated;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, retain) EvaAirlineUploader *airlineUploader;

@property(nonatomic, retain) Channel *aileronChannel;
@property(nonatomic, retain) Channel *elevatorChannel;
@property(nonatomic, retain) Channel *rudderChannel;
@property(nonatomic, retain) Channel *throttleChannel;
@property(nonatomic, retain) Channel *channel5;
@property(nonatomic, retain) Channel *channel6;



+ (id)sharedManager;


@end
