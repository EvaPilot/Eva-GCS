//
//  RawPackage.m
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaRawPackage.h"

@implementation EvaRawPackage
@synthesize type = _type;
@synthesize data = _data;

+(id)packageWithType:(NSString *)type data:(NSData *)data{
    return [[[EvaRawPackage alloc] initWithType:type data:data] autorelease];
}

- (id)initWithType:(NSString *)type data:(NSData *)data{
    if (self = [super init]) {
        _type = [type retain];
        _data = [data retain];
    }
    return self;
}

- (void)dealloc{
    [_type release];
    [_data release];
    [super dealloc];
}

@end
