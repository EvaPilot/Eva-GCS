//
//  EvaAirlineFile.h
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvaAirlineFile : NSObject

+ (BOOL)createAirlineDocumentIfNeeded;
+ (BOOL)saveAirline:(NSArray *)airline toFile:(NSString *)fileName;
+ (NSArray *)loadAirlineFromFile:(NSString *)fileName;
+ (BOOL)remove:(NSString *)fileName;
+ (NSArray *)getAirlineFileList;


@end
