//
//  EvaAirlineUploader.h
//  RCTouch
//
//  Created by koupoo on 13-4-11.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaypointAnnotation.h"
#import "EvaRawPackage.h"

@class EvaAirlineUploader;
@protocol EvaAirlineUploaderDelegate <NSObject>

- (void)airlineUploaderDidUpload:(EvaAirlineUploader *)airlineUploader;
- (void)airlineUploader:(EvaAirlineUploader *)airlineUploader didUploadWaypoint:(WaypointAnnotation *)waypoint;
- (void)airlineUploader:(EvaAirlineUploader *)airlineUploader didSendWaypoint:(WaypointAnnotation *)waypoint;

@end

@interface EvaAirlineUploader : NSObject

- (id)initWithAirline:(NSArray *)waypointList delegate:(id<EvaAirlineUploaderDelegate>)delegate;
- (BOOL)upload;
- (BOOL)cancel;
- (BOOL)verifyWaypoint:(EvaRawPackage *)waypointRawPackage;

@end
