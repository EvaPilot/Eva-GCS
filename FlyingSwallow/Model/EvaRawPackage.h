//
//  RawPackage.h
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EvaRawPackage : NSObject

@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSData *data;

+(id)packageWithType:(NSString *)type data:(NSData *)data;

-(id)initWithType:(NSString *)type data:(NSData *)data;


@end
