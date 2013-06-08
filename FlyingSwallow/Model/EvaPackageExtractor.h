//
//  EvaPackageExtractor.h
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvaRawPackage.h"

@interface EvaPackageExtractor : NSObject

@property (nonatomic, readonly) int port;
@property (nonatomic, readonly) NSString *host;

- (id)initWithPort:(int)port host:(NSString *)host;

- (void)addData:(NSData *)data;
//尝试从缓存中析取一个包，如果析取失败返回nil
- (EvaRawPackage *)extract;
//尝试从缓存中析取所有的包，如果析取失败返回nil
- (NSArray *)extractAll; 



@end
