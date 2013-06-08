//
//  CSRouteAnnotation.m
//  testMapp
//
//  Created by Craig on 8/18/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import "CSRouteAnnotation.h"


@implementation CSRouteAnnotation
@synthesize coordinate = _center;
@synthesize lineColor = _lineColor;
@synthesize points = _points;
@synthesize routeID = _routeID;

-(id)initWithPoints{
	if(self = [super init]){
    	_points =[[NSMutableArray alloc] initWithCapacity:0];
    }
	
    /*
     // create a unique ID for this route so it can be added to dictionaries by this key.
     self.routeID = [NSString stringWithFormat:@"%p", self];
     
     
     // determine a logical center point for this route based on the middle of the lat/lon extents.
     double maxLat = -91;
     double minLat =  91;
     double maxLon = -181;
     double minLon =  181;
     
     for(CLLocation* currentLocation in _points)
     {
     CLLocationCoordinate2D coordinate = currentLocation.coordinate;
     
     if(coordinate.latitude > maxLat)
     maxLat = coordinate.latitude;
     if(coordinate.latitude < minLat)
     minLat = coordinate.latitude;
     if(coordinate.longitude > maxLon)
     maxLon = coordinate.longitude;
     if(coordinate.longitude < minLon)
     minLon = coordinate.longitude;
     }
     
     _span.latitudeDelta = (maxLat + 90) - (minLat + 90);
     _span.longitudeDelta = (maxLon + 180) - (minLon + 180);
     
     // the center point is the average of the max and mins
     _center.latitude = minLat + _span.latitudeDelta / 2;
     _center.longitude = minLon + _span.longitudeDelta / 2;
     
     self.lineColor = [UIColor blueColor];
     //NSLog(@"Found center of new Route Annotation at %lf, %ld", _center.latitude, _center.longitude);
     */
	return self;
}

-(void)addPoint:(CLLocationCoordinate2D)pt{
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:pt.latitude longitude:pt.longitude] ;
    [_points addObject:currentLocation];
    [currentLocation release];
    
    double maxLat = -91;
    double minLat =  91;
    double maxLon = -181;
    double minLon =  181;
    
    for(CLLocation* currentLocation in _points){
        CLLocationCoordinate2D coordinate = currentLocation.coordinate;
        
        if(coordinate.latitude > maxLat)
            maxLat = coordinate.latitude;
        if(coordinate.latitude < minLat)
            minLat = coordinate.latitude;
        if(coordinate.longitude > maxLon)
            maxLon = coordinate.longitude;
        if(coordinate.longitude < minLon)
            minLon = coordinate.longitude;
    }
    
    _span.latitudeDelta = (maxLat + 90) - (minLat + 90);    //纬度跨距
    _span.longitudeDelta = (maxLon + 180) - (minLon + 180); //经度跨距
    
    // the center point is the average of the max and mins
    _center.latitude = minLat + _span.latitudeDelta / 2;   //中心纬度
    _center.longitude = minLon + _span.longitudeDelta / 2; //中心经度
    
//    if (typeID ==0) {
//        self.lineColor = [UIColor redColor];
//    }
//    else if (typeID ==1) {
//        self.lineColor = [UIColor blueColor];
//    }
//    else if (typeID ==2) {
//        self.lineColor = [UIColor greenColor];
//    }
//    self.updateflag = 1;
}

-(MKCoordinateRegion)region{
	MKCoordinateRegion region;
	region.center = _center;
	region.span = _span;
	
	return region;
}

-(void)dealloc{
	[_points release];
	[_lineColor release];
    [_routeID release];
	[super dealloc];
}

@end
