//
//  EvaAirlineFile.m
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaAirlineFile.h"
#import "WaypointAnnotation.h"

@implementation EvaAirlineFile

+ (NSString *)getAirlineDocumentPath{
    NSString *documentsDir= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"Airlines"];
}

+ (NSString *)getFullPathOfAirlineFile:(NSString *)fileName{
    return [[self getAirlineDocumentPath] stringByAppendingPathComponent:fileName];
}

+ (BOOL)createAirlineDocumentIfNeeded{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory= NO;

    BOOL exists = [fileManager fileExistsAtPath:[self getAirlineDocumentPath] isDirectory:&isDirectory];
    
    if (exists && isDirectory) {
        return YES;
    }
    else {
        return [fileManager createDirectoryAtPath:[self getAirlineDocumentPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

+ (BOOL)saveAirline:(NSArray *)airline toFile:(NSString *)fileName{
    NSMutableData *airlineData = [[NSMutableData alloc] init];
    for (WaypointAnnotation *waypointAnnotation in airline) {
        NSString *waypoint =[[NSString alloc]initWithFormat:@"%.5f %.5f %d %d %d %d\r\n",
                             waypointAnnotation.coordinate.longitude,
                             waypointAnnotation.coordinate.latitude,
                             waypointAnnotation.altitude,
                             waypointAnnotation.speed,
                             waypointAnnotation.panxuan,
                             waypointAnnotation.hoverTime];
        [airlineData appendData:[waypoint dataUsingEncoding:NSASCIIStringEncoding]];
        [waypoint release];
    }
    
    NSString *fullPath = [self getFullPathOfAirlineFile:fileName];
    BOOL successed = [airlineData writeToFile:fullPath atomically:YES];
    [airlineData release];
    
    return successed;
}

+ (NSArray *)loadAirlineFromFile:(NSString *)fileName{
    NSMutableArray *waypointList = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *airlineData = [fileManager contentsAtPath:[self getFullPathOfAirlineFile:fileName]];
    
    if (airlineData.length < 20){
        [waypointList release];
        return nil;
    }
    
    NSMutableString *strdata = [[NSMutableString alloc] initWithBytes:airlineData.bytes
                                                              length:airlineData.length
                                                            encoding:NSASCIIStringEncoding];
    while (strdata.length > 0) {
        NSRange srRange;
        srRange.length = 0;
        srRange.location=  0;
        
        srRange = [strdata rangeOfString:@"\r\n"];
        
        if (srRange.location>0) {
            NSString *str = [strdata substringToIndex:srRange.location];
            [strdata deleteCharactersInRange:NSMakeRange(0, srRange.location+2) ];
            NSMutableString *strbuf=[[NSMutableString alloc]initWithFormat:@"%@ ",str ];
            
            WaypointAnnotation *waypointAnnotation = [[WaypointAnnotation alloc] init];
            waypointAnnotation.no  = waypointList.count + 1;
            waypointAnnotation.speed = 0;
            waypointAnnotation.style = waypoint_style_red;
            waypointAnnotation.isUploaded = NO;
            
            float latitude = 0;
            float longitude = 0;
            
            for(int i = 0; i <6; i++){
                NSString *strPara = @"0";
                srRange=[strbuf rangeOfString:@" "];
                if (srRange.location>0) {
                    strPara =[strbuf substringToIndex:srRange.location];
                    [strbuf deleteCharactersInRange:NSMakeRange(0, srRange.location+1)  ];
                }
                
                if(i==0)
                    longitude = [strPara floatValue];
                if(i==1)
                    latitude = [strPara floatValue];
                if(i==2)  waypointAnnotation.altitude  = [strPara intValue];
                if(i==3)  waypointAnnotation.speed     = [strPara intValue];
                if(i==4)  waypointAnnotation.panxuan   = [strPara intValue];
                if(i==5)  waypointAnnotation.hoverTime = [strPara intValue];
            }
            
            waypointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            [strbuf release];
            
            [waypointList addObject:waypointAnnotation];
            
            [waypointAnnotation release];
        }
    }
    
    [strdata release];

    return [waypointList autorelease];
}

+ (BOOL)remove:(NSString *)fileName{
    NSString *airlineFullPath = [self getFullPathOfAirlineFile:fileName];
    return [[NSFileManager defaultManager] removeItemAtPath:airlineFullPath error:NULL];
}

+ (NSArray *)getAirlineFileList{
    NSString *airlineDocumentPath = [self getAirlineDocumentPath];
    
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:airlineDocumentPath error:NULL];
}



@end
