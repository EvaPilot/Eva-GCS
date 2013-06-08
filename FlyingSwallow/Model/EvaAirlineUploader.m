//
//  EvaAirlineUploader.m
//  RCTouch
//
//  Created by koupoo on 13-4-11.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaAirlineUploader.h"
#import "EvaCommand.h"
#import "Transmitter.h"
#import "EvaOSDData.h"

@implementation EvaAirlineUploader{
    NSArray *waypointList;
    
    BOOL uploadIsTimeout;
    
    NSTimer *uploadTimer;
    
    id<EvaAirlineUploaderDelegate> delegate;
    
    int lastWaypointSendIdx;
}

- (id)initWithAirline:(NSArray *)waypointList_ delegate:(id<EvaAirlineUploaderDelegate>)delegate_{
    if (self = [super init]) {
        waypointList = [waypointList_ retain];
        delegate = delegate_;
    }
    return self;
}

- (BOOL)upload{
    lastWaypointSendIdx = -1;
    
    if (uploadTimer == nil) {
        uploadTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doUpload) userInfo:nil repeats:YES] retain];
    }

    return YES;
}

- (void)doUpload{
    BOOL needsUpload = NO;
    
    for (int waypointIdx = 0; waypointIdx < waypointList.count; waypointIdx++) {
        WaypointAnnotation *waypoint = [waypointList objectAtIndex:waypointIdx];
        
        if (waypoint.isUploaded == NO) {
            needsUpload = YES;
            
            if (waypointIdx > lastWaypointSendIdx) {
                NSData *waypointUploadCommand = [EvaCommand getWaypointUploadCommand:waypoint];
                [[Transmitter sharedTransmitter] transmmitData:waypointUploadCommand];
                
                waypoint.style = waypoint_style_yellow;
                
                if ([delegate respondsToSelector:@selector(airlineUploader:didSendWaypoint:)]) {
                    [delegate airlineUploader:self didSendWaypoint:waypoint];
                }

                lastWaypointSendIdx++;
                
                if ((lastWaypointSendIdx + 1) >= waypointList.count) {
                    lastWaypointSendIdx = -1;
                }
                break;
            }
        }
    }
    
//    for(WaypointAnnotation *waypoint in waypointList){
//        if (waypoint.isUploaded == NO) {
//            needsUpload = YES;
//            
//            waypoint.uploadingTimer++;
//            
//            NSData *waypointUploadCommand = [EvaCommand getWaypointUploadCommand:waypoint];
//            [[Transmitter sharedTransmitter] transmmitData:waypointUploadCommand];
//            
//            waypoint.style = waypoint_style_yellow;
//            
//            if ([delegate respondsToSelector:@selector(airlineUploader:didSendWaypoint:)]) {
//                [delegate airlineUploader:self didSendWaypoint:waypoint];
//            }
//            
//            currentWaypointIdx++;
//            
//            break;
//            
//        }
//    }
    
    if ([[[Transmitter sharedTransmitter] osdData] waypointCount] != waypointList.count) { //飞控返回的航点数跟本地的对不上
        NSData *waypointCountSetCommand = [EvaCommand getWaypointCountSetCommand:waypointList.count];
        [[Transmitter sharedTransmitter] transmmitData:waypointCountSetCommand];
    }
    
    if (needsUpload == NO && [[[Transmitter sharedTransmitter] osdData] waypointCount] == waypointList.count) {  //全部上传成功并通过验证
        [uploadTimer invalidate];
        [uploadTimer release];
        uploadTimer = nil;
        
        if ([[[Transmitter sharedTransmitter] osdData] waypointCount] == waypointList.count) {
            if ([delegate respondsToSelector:@selector(airlineUploaderDidUpload:)]) {
                [delegate airlineUploaderDidUpload:self];
            }
        }
    }
}

-(BOOL)verifyWaypoint:(EvaRawPackage *)waypointRawPackage{
    const Byte *p = [waypointRawPackage.data bytes];
    
    int no;
    int altitude = 0;
    int speed;
    int panxuan;
    int hoverTime;
    
    no = p[5];  
    
    if (no > waypointList.count){
        return NO;
    }
    else if (no < 1){
        return NO;
    }
    else{
        WaypointAnnotation *waypoint = [waypointList objectAtIndex:no - 1];
        
        if (waypoint.isUploaded) {
            return YES;
        }
        
        float maxOffset = 0.00020f;
        
        float latitude  = 0;
        float longitude = 0;
        
        Byte *pp = (Byte*)&latitude;
        for (int i=0; i<4; i++) {
            pp[i]=p[6+i] ;
        }
        pp = (Byte*)&longitude;
        for (int i=0; i<4; i++) {
            pp[i]=p[10+i] ;
        }
        
        altitude  = *((int*)(p + 14));
        hoverTime = p[25] * 256 + p[26];
        panxuan   = p[24];
        speed     = p[18];
        
        float latitudeOffset = fabsf(waypoint.coordinate.latitude - latitude);
        float longitudeOffset = fabsf(waypoint.coordinate.longitude - longitude);
        
        if ((latitudeOffset <= maxOffset)
            && (longitudeOffset <= maxOffset)
            && (altitude == waypoint.altitude)
            && (speed == waypoint.speed)
            && (panxuan == waypoint.panxuan)
            && (hoverTime == waypoint.hoverTime)){
            waypoint.isUploaded = YES;
            waypoint.style = waypoint_style_green;
            if ([delegate respondsToSelector:@selector(airlineUploader:didUploadWaypoint:)]) {
                [delegate airlineUploader:self didUploadWaypoint:waypoint];
            }
        }
        else{
            waypoint.isUploaded = NO;
            waypoint.style = waypoint_style_red;
        }
    };
    
    return YES;
}

- (BOOL)cancel{
    [uploadTimer invalidate];
    [uploadTimer release];
    uploadTimer = nil;
    
    return YES;
}

- (void)dealloc{
    [self cancel];
    [waypointList release];
    [super dealloc];
}

@end
