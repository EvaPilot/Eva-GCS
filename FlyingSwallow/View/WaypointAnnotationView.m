//
//  WayPointAnnationView.m
//  EVA GCS
//
//  Created by 11 on 11-12-30.
//  Copyright (c) 2011年 Hex Airbot. All rights reserved.
//

#import "WaypointAnnotationView.h"
#import "WaypointAnnotation.h"

#define kWaypointAnnotationViewWidth  70
#define kWaypointAnnotationViewHeight 50

#define kWaypointAnnotationImageViewWidth  24
#define kWaypointAnnotationImageViewHeight 24

@interface WaypointAnnotationView(){
    BOOL isMoving;
    CGPoint startLocation;
    CGPoint originalCenter;
}

@end


@implementation WaypointAnnotationView
@synthesize delegate;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self != nil){
        CGRect frame = self.frame;
        frame.size = CGSizeMake(kWaypointAnnotationViewWidth, kWaypointAnnotationViewHeight);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0.0, 0.0);
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    WaypointAnnotation *WaypointAnnotation = self.annotation;
    
    // draw the temperature string and weather graphic
    NSString *idxStr = [NSString stringWithFormat:@"%d",WaypointAnnotation.no];
    [[UIColor redColor] set];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    [idxStr drawInRect:CGRectMake(50, 15, 40, 30) withFont:font];

    NSString *imageFile = nil;
    
    if(WaypointAnnotation.style == waypoint_style_red){ //红色
        imageFile = @"waypoint_red.png";
    }
    else if(WaypointAnnotation.style == waypoint_style_yellow){  //黄色
        imageFile = @"waypoint_yellow.png";
    }
    else if(WaypointAnnotation.style == waypoint_style_green){  //绿色
        imageFile = @"waypoint_green.png";
    }
    
    [[UIImage imageNamed:imageFile] drawInRect:CGRectMake((kWaypointAnnotationViewWidth - kWaypointAnnotationImageViewWidth  ) / 2, (kWaypointAnnotationViewHeight - kWaypointAnnotationImageViewHeight) / 2, kWaypointAnnotationImageViewWidth, kWaypointAnnotationImageViewHeight)];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"Touch begin****");
    
    UITouch* oneTouch = [touches anyObject];
    startLocation = [oneTouch locationInView:[self superview]];
    originalCenter = self.center;
    
    //[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   
    
    UITouch* oneTouch = [touches anyObject];
    
    CGPoint newLocation = [oneTouch locationInView:[self superview]];
    
    CGPoint newCenter;
    
    NSLog(@"Touch moved****");

    //isMoving == NO &&
    // If the user's finger moved more than 5 pixels, begin the drag.
    if (((fabs(newLocation.x - startLocation.x) > 5.0) || (fabs(newLocation.y - startLocation.y) > 5.0))){
        NSLog(@"Touch moved > 5****");
        
        isMoving = YES;
    }
    
    // If dragging has begun, adjust the position of the view.
    if (isMoving){
        newCenter.x = originalCenter.x + (newLocation.x - startLocation.x);
        newCenter.y = originalCenter.y + (newLocation.y - startLocation.y);
        
        if ([delegate respondsToSelector:@selector(waypointAnnotationViewDidDragged:newCenter:)]) {
            [delegate waypointAnnotationViewDidDragged:self newCenter:newCenter];
        }
    }
    else{
       // [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"Touch ended****");
    
    if (isMoving){
        startLocation = CGPointZero;
        originalCenter = CGPointZero;
        isMoving = NO;
        
    }
    else{
        if ([delegate respondsToSelector:@selector(waypointAnnotationViewDidTapped:)]) {
            [delegate waypointAnnotationViewDidTapped:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"Touch canceled****");
    
    if (isMoving){
        startLocation = CGPointZero;
        originalCenter = CGPointZero;
        isMoving = NO;    
    }
    else{
        //[super touchesCancelled:touches withEvent:event];
    }
}

- (void)dealloc{
    [super dealloc];
}

@end
