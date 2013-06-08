//
//  EvaMag.m
//  RCTouch
//
//  Created by koupoo on 13-4-3.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaMag.h"
#import "EvaMagPoint.h"

@implementation EvaMag
@synthesize xMagBias = _xMagBias;
@synthesize yMagBias = _yMagBias;
@synthesize zMagBias = _zMagBias;

@synthesize kMag = _kMag;
@synthesize kMag2 = _kMag2;

@synthesize xyList = _xyList;
@synthesize zyList = _zyList;

@synthesize dataIsLoaded = _dataIsLoaded;

- (id)init{
    if (self = [super init]) {
        _xyList = [[NSMutableArray alloc] init];
        _zyList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc{
    [_xyList release];
    [_zyList release];
    [super dealloc];
}

-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage{
    if ([rawPackage.type compare:@"$MG2"] == NSOrderedSame) {
        _dataIsLoaded = NO;
        const Byte *p = [rawPackage.data bytes];

        Byte sum=0;
        for(int i=4;i<12;i++){
            
            sum+=p[i];
        }
        Byte b= p[12];
        if(b==sum){
            
            float x= 0.0f;//*(float*)(p+4);
            float y= 0.0f;//*(float*)(p+8);
            
            Byte *pp = (Byte*)&x;
            for (int i=0; i<4; i++) {
                pp[i]=p[4+i] ;
            }
            pp = (Byte*)&y;
            for (int i=0; i<4; i++) {
                pp[i]=p[8+i] ;
            }
            
            EvaMagPoint *magPoint = [[EvaMagPoint alloc] init];
            magPoint.x = x;
            magPoint.y = y;
            
            [_xyList addObject:magPoint];
            [magPoint release];
        }
    }
    else if ([rawPackage.type compare:@"$MG3"] == NSOrderedSame) {
        const Byte *p = [rawPackage.data bytes];
        Byte sum = 0;
        for(int i=4; i<12; i++){
            
            sum+=p[i];
        }
        Byte b= p[12];
        if(b==sum){
            float x= 0.0f;//*(float*)(p+4);
            float y= 0.0f;//*(float*)(p+8);
            
            Byte *pp = (Byte*)&y;
            for (int i=0; i<4; i++) {
                pp[i]=p[4+i] ;
            }
            pp = (Byte*)&x;
            for (int i=0; i<4; i++) {
                pp[i]=p[8+i] ;
            }
            
            EvaMagPoint *magPoint = [[EvaMagPoint alloc] init];
            magPoint.x = x;
            magPoint.y = y;
            
            [_zyList addObject:magPoint];
            [magPoint release];
        }
    }
    else if ([rawPackage.type compare:@"$MG1"] == NSOrderedSame) {
        _dataIsLoaded = YES;
        
        const Byte *p = [rawPackage.data bytes];
        
        Byte sum=0;
        for(int i=4;i<24;i++){
            
            sum+=p[i];
        }
        Byte b= p[24];
        if(b==sum){
            float xmag_bias= 0.0f;//*(float*)(p+4);
            float ymag_bias= 0.0f;//*(float*)(p+8);
            float zmag_bias= 0.0f;//*(float*)(p+8);
            
            float Kmag= 0.0f;//*(float*)(p+8);
            float Kmag2= 0.0f;//*(float*)(p+8);
            
            Byte *pp = (Byte*)&xmag_bias;
            for (int i=0; i<4; i++) {
                pp[i]=p[4+i] ;
            }
            pp = (Byte*)&ymag_bias;
            for (int i=0; i<4; i++) {
                pp[i]=p[8+i] ;
            }
            pp = (Byte*)&zmag_bias;
            for (int i=0; i<4; i++) {
                pp[i]=p[12+i] ;
            }
            pp = (Byte*)&Kmag;
            for (int i=0; i<4; i++) {
                pp[i]=p[16+i] ;
            }
            pp = (Byte*)&Kmag2;
            for (int i=0; i<4; i++) {
                pp[i]=p[20+i] ;
            }
            
            _xMagBias = xmag_bias;
            _yMagBias = ymag_bias;
            _zMagBias = zmag_bias;
            
            _kMag = Kmag;
            _kMag2 = Kmag2;
        }
    }
    
    return YES;
}

@end
