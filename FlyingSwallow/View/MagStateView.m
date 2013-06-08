//
//  MagStateView.m
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "MagStateView.h"
#import "EvaMagPoint.h"

@implementation MagStateView
@synthesize magData = _magData;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float xxCenter=  self.center.x - 10;
	float yyCenter=  self.center.y - 50;
    
	CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.height;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.5, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextFillRect(context, CGRectMake((w -4 ) / 2.0, 0.0, 4.0, h));
    CGContextFillRect(context, CGRectMake(0.0, (h - 4) / 2.0, w, 4));
    
    NSArray *xyList = _magData.xyList;
    NSArray *zyList = _magData.zyList;
    float xMagBias = _magData.xMagBias;
    float yMagBias = _magData.yMagBias;
    float zMagBias = _magData.zMagBias;
    float kMag = _magData.kMag;
    float kMag2 = _magData.kMag2;
    
    for(int i=0;i<xyList.count;i++){
        EvaMagPoint *pack = (EvaMagPoint *)[xyList objectAtIndex:i];
        
        float xmag = pack.x -  xMagBias;
        float ymag = pack.y -  yMagBias;
        ymag *= kMag;
        
        float x = xmag * xxCenter / 500.0 + xxCenter;
        float y = ymag * xxCenter / 500.0 + yyCenter;
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 0, 0.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, CGRectMake(x - 2, y - 2, 4, 4));
    }
    
    for(int i=0;i<zyList.count;i++){
        EvaMagPoint *pack = (EvaMagPoint *)[zyList objectAtIndex:i];
        
        float zmag = pack.x -  zMagBias;
        float ymag = pack.y -  yMagBias;
        zmag *= kMag2;
        
        float x = zmag * xxCenter / 500.0 + xxCenter;
        float y = ymag * xxCenter / 500.0 + yyCenter;
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, CGRectMake(x - 2, y - 2, 4, 4));
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect2:(CGRect)rect
{
    float xxCenter=  self.center.x;
	float yyCenter=  self.center.y-24;
    
	CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.height-47;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.5, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextFillRect(context, CGRectMake((w-4)/2, 0.0, 4.0, h));
    CGContextFillRect(context, CGRectMake(0.0,(h-4)/2, w, 4));
    
    NSArray *xyList = _magData.xyList;
    NSArray *zyList = _magData.zyList;
    float xMagBias = _magData.xMagBias;
    float yMagBias = _magData.yMagBias;
    float zMagBias = _magData.zMagBias;
    float kMag = _magData.kMag;
    float kMag2 = _magData.kMag2;
    
    for(int i=0;i<xyList.count;i++){
        EvaMagPoint *pack = (EvaMagPoint *)[xyList objectAtIndex:i];
        
        float xmag = pack.x -  xMagBias;
        float ymag = pack.y -  yMagBias;
        ymag *= kMag;
        
        float x = xmag*xxCenter / 500 + xxCenter;
        float y = ymag*xxCenter / 500 + yyCenter;
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 0, 0.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, CGRectMake(x-2,y-2, 4, 4));
    }

    for(int i=0;i<zyList.count;i++){
        EvaMagPoint *pack = (EvaMagPoint *)[zyList objectAtIndex:i];
        
        float zmag = pack.x -  zMagBias;
        float ymag = pack.y -  yMagBias;
        zmag *= kMag2;
        
        float x = zmag*xxCenter / 500+xxCenter;
        float y = ymag*xxCenter / 500+yyCenter;
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, CGRectMake(x-2,y-2, 4, 4));
    }
}

- (void)dealloc{
    [_magData release];
    [super dealloc];
}

@end
