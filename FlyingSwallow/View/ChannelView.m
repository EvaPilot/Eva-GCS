//
//  ChannelView.m
//  EVA GCS
//
//  Created by 11 on 11-12-9.
//  Copyright 2011 Hex Airbot. All rights reserved.
//

#import "ChannelView.h"

@interface ChannelView(){
    int posRudder;
    int posElevator;
    int posAileron;
    int posThrottle;
}

@end

@implementation ChannelView

@synthesize osdData = _osdData;

- (void)setOsdData:(EvaOSDData *)osdData{
    [_osdData release];
    _osdData = [osdData retain];
    [self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }

    return self;
}
- (id)initWithCoder:(NSCoder*)coder{
    if (self = [super initWithCoder:coder]) {        
         posRudder   = 0;
         posElevator = 0;
         posAileron       = 0;
         posThrottle = 45;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.height-20;
    
    float xxCenter=  w/2.0;
    float xxCenter1=  xxCenter/2.0;
    float xxCenter2=  xxCenter/2.0+xxCenter;
	float yyCenter=  h/2.0;
    
  	
    CGContextRef context=UIGraphicsGetCurrentContext();  
	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); 
	CGContextSetLineWidth(context, 2.0);
	
	CGContextMoveToPoint(context,    5,       yyCenter);
    CGContextAddLineToPoint(context, xxCenter-5,yyCenter);
    CGContextStrokePath(context); 
    
    CGContextMoveToPoint(context,   xxCenter1,0);
    CGContextAddLineToPoint(context,xxCenter1,h);
    CGContextStrokePath(context); 
    
    CGContextMoveToPoint(context, 5+xxCenter,yyCenter);
    CGContextAddLineToPoint(context, xxCenter-5+xxCenter,yyCenter);
    CGContextStrokePath(context); 
    
    CGContextMoveToPoint(context, xxCenter2,0);
    CGContextAddLineToPoint(context,xxCenter2,h);
    CGContextStrokePath(context); 


    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0,1.0);
    CGContextSelectFont(context, "Helvetica", 13, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    CGContextSetTextMatrix(context, flip);
    
    NSString *channelName = @"Rudder";
    const char *p=[channelName UTF8String];
    CGContextShowTextAtPoint(context, 5, yyCenter+15, p, strlen(p));
    
    channelName = @"Elevator";
    p=[channelName UTF8String];
    CGContextShowTextAtPoint(context, xxCenter1-20, yyCenter*2+10, p, strlen(p));
    
    channelName = @"Aileron";
    p=[channelName UTF8String];
    CGContextShowTextAtPoint(context, 5+xxCenter, yyCenter+15, p, strlen(p));
    
    channelName = @"Throttle";
    p=[channelName UTF8String];
    CGContextShowTextAtPoint(context, xxCenter2-20, yyCenter*2+10, p, strlen(p));


    CGContextFillPath(context);
    
    CGContextSetLineWidth(context, 6.0);
    
    posRudder = _osdData.manualYawValue;
    
    if(posRudder > 40)  posRudder = 40;
    if(posRudder <- 40) posRudder = -40;
    
    if (abs(posRudder) <= 1) {//green
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 0.0, 1.0, 0.0, 1.0); 
    }
    else{//red
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 1.0, 0.0, 0.0, 1.0); 
    }

    int cx = posRudder*(xxCenter1 - 5) / 40;
    CGContextMoveToPoint(context, xxCenter1+cx,yyCenter-10);
    CGContextAddLineToPoint(context,xxCenter1+cx,yyCenter+10);
    CGContextStrokePath(context); 
    
    posAileron = _osdData.manualAileronValue;
    
    if(posAileron > 40)  posAileron = 40;
    if(posAileron < -40) posAileron = -40;
    
    if (abs(posAileron) <= 1) {//green
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 0.0, 1.0, 0.0, 1.0); 
    }
    else{//red
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 1.0, 0.0, 0.0, 1.0); 
    }
    
    cx = posAileron*(xxCenter1-5)/40;
    CGContextMoveToPoint(context, xxCenter2+cx,yyCenter-10);
    CGContextAddLineToPoint(context,xxCenter2+cx,yyCenter+10);
    CGContextStrokePath(context); 
    
    posElevator = _osdData.manualElevatorValue;
    
    if(posElevator > 40)  posElevator = 40;
    if(posElevator < -40) posElevator = -40;
    
    if (abs(posElevator) <= 1) {//green
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 0.0, 1.0, 0.0, 1.0); 
    }
    else{//red
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 1.0, 0.0, 0.0, 1.0); 
    }
    
    int cy = posElevator*(yyCenter)/40;
    CGContextMoveToPoint(context, xxCenter1-10,yyCenter+cy);
    CGContextAddLineToPoint(context,xxCenter1+10,yyCenter+cy);
    CGContextStrokePath(context); 

    posThrottle = _osdData.manualThrottleValue;
    
    if(posThrottle > 90) posThrottle = 90;
    if(posThrottle < 0)  posThrottle = 0;
    
    if (posThrottle <= 7) {//green
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 0.0, 1.0, 0.0, 1.0); 
    }
    else  if(posThrottle <= 10) {//yellow
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 1.0, 1.0, 0.0, 1.0);
    }
    else{ //red
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(  context, 1.0, 0.0, 0.0, 1.0);
    }
    
    cy = yyCenter*2-posThrottle*(yyCenter*2)/90;
    CGContextMoveToPoint(context, xxCenter2-10,cy);
    CGContextAddLineToPoint(context,xxCenter2+10,cy);
    CGContextStrokePath(context); 
}


- (void)dealloc {
    [_osdData release];
    [super dealloc];
}


@end
