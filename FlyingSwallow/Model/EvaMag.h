//
//  EvaMag.h
//  RCTouch
//
//  Created by koupoo on 13-4-3.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvaRawPackage.h"

@interface EvaMag : NSObject

@property (nonatomic, assign) float xMagBias;
@property (nonatomic, assign) float yMagBias;
@property (nonatomic, assign) float zMagBias;

@property (nonatomic, assign) float kMag;
@property (nonatomic, assign) float kMag2;

@property (nonatomic, readonly) NSMutableArray *xyList;
@property (nonatomic, readonly) NSMutableArray *zyList;

@property (nonatomic, assign) BOOL dataIsLoaded; //磁场数据是否下载完

-(BOOL)updateWithRawPackage:(EvaRawPackage *)rawPackage;

@end
