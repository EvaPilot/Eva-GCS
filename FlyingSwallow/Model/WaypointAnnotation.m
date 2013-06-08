#import "WaypointAnnotation.h"

@interface WaypointAnnotation(){

}

@end

@implementation WaypointAnnotation

@synthesize coordinate;

@synthesize no;
@synthesize altitude;
@synthesize speed;
@synthesize panxuan;
@synthesize hoverTime;

@synthesize style;
@synthesize isUploaded;

- (void)dealloc{
    [super dealloc];
}


@end
