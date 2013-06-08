#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define kFirstWaypointHoverTime (15 * 60)

typedef enum{
    waypoint_style_green = 0,
    waypoint_style_yellow = 1,
    waypoint_style_red = 2
}waypoint_style_t;

@interface WaypointAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic) int no;         //航点编号
@property (nonatomic) int altitude;
@property (nonatomic) int speed;

@property (nonatomic) int panxuan;  //?

@property (nonatomic) int hoverTime;

@property (nonatomic) waypoint_style_t style;

@property (nonatomic) BOOL isUploaded;  //是否上传到飞控

@end
