//
//  PlaneAnnotation.h
//  RCTouch
//
//  Created by koupoo on 13-4-11.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation :  NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) float rotation;
@property (nonatomic, retain) NSString *imagePath;

@property (nonatomic, assign) int typeId;

@end
