//
//  PlaneAnnotation.m
//  RCTouch
//
//  Created by koupoo on 13-4-11.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "ImageAnnotation.h"

@implementation ImageAnnotation

@synthesize coordinate;

@synthesize rotation;
@synthesize imagePath;
@synthesize typeId;

- (void)dealloc{
    [imagePath release];
    [super dealloc];
}

@end
