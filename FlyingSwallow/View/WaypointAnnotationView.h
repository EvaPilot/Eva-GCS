//
//  WayPointAnnationView.h
//  EVA GCS
//
//  Created by 11 on 11-12-30.
//  Copyright (c) 2011年 Hex Airbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WaypointAnnotationView;

@protocol WaypointAnnotationViewDelegate <NSObject>

- (void)waypointAnnotationViewDidTapped:(WaypointAnnotationView *)waypointAnnotationView;
- (void)waypointAnnotationViewDidDragged:(WaypointAnnotationView *)waypointAnnotationView newCenter:(CGPoint)newCenter;

@end

@class MapView;

@interface WaypointAnnotationView : MKAnnotationView{
}

@property(nonatomic, assign) id<WaypointAnnotationViewDelegate> delegate;


@end
