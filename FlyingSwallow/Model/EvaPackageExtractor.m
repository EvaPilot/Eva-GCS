//
//  EvaPackageExtractor.m
//  RCTouch
//
//  Created by koupoo on 13-3-28.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "EvaPackageExtractor.h"
#import "EvaRawPackage.h"

@interface EvaPackageExtractor()
{
	Byte *revbuf;   //从udp口收到的数据缓存，大小大概为4kb
	int head;
	int tail;
}

@end

@implementation EvaPackageExtractor
@synthesize port = _port;
@synthesize host = _host;

- (id)init
{
	if(self = [super init]){
        revbuf = malloc(1024 * 5) ;
        head = 0;
        tail = 0;
    }
    return self;
}

- (id)initWithPort:(int)port host:(NSString *)host{
    if (self = [self init]) {
        _port = port;
        _host = [host retain];
    }
    return self;
}

- (void)dealloc {
	free(revbuf);
    [_host release];
    [super dealloc];
}

- (void)addData:(NSData *)data
{
	int len = [data length];
	int size = len + tail;
	if(size < 1024 * 4){
		memcpy(revbuf + tail, [data bytes], len );
		tail+=len;
	}
	else {
		head = 0;
		tail = 0;
		revbuf[0] = 0;
	}
}

//返回一个有效包的起始位置，head将指向下一个包的位置
- (EvaRawPackage *)extract
{
    NSData *packageData = nil;
    NSString *packageType = nil;
   
    char ch;
    
	while(YES)
	{
		ch = (char)revbuf[head];
		if (ch=='$'){  // find $
            int nsize = tail - head;  //收到的数据包大小
            if (nsize < 2)  //收到的数据过于的小 舍去
                return nil;
            else{
            	if([self isPackage:@"$STP":nsize:99] == 0)
                {
                    packageType = @"$STP";
                    
                    Byte sum =0;   //计算校验和
                    for (int i=0; i < 98; i++) {
                        sum+=revbuf[head + i];
                    }
                    Byte b = revbuf[head + 98];
                    if(b != sum){   //校验和不对
                        packageType = @"";
                        head += 99;
                        continue;
                    }
                    else{
                        packageData = [NSData dataWithBytes:revbuf + head length:99];
                        head += 99;  //下一个包的起始位置
                    }
                }
                else if([self isPackage:@"$DIN":nsize:14] == 0) //定点飞行要飞的目标点
                {
                    packageType = @"$DIN";
                    
                    Byte sum = 0;
                    for (int i = 0; i < 13; i++) {
                        sum += revbuf[head+i];
                    }
                    Byte b = revbuf[head+13];
                    if(b != sum){
                        packageType = @"";
                        head += 14;
                        continue;
                    }
                    else{
                        packageData = [NSData dataWithBytes:revbuf + head length:14];
                        head += 14;
                    }
                    
                }
                else if([self isPackage:@"$SETD":nsize:31]==0)
                {
                    packageType =  @"$SETD";
                    packageData = [NSData dataWithBytes:revbuf + head length:31];
                    head += 31;
                }
                else if([self isPackage:@"$DOCAP":nsize:6]==0)
                {
                    packageType = @"$DOCAP";
                    packageData = [NSData dataWithBytes:revbuf + head length:6];
                    head += 6;
                }
                else if([self isPackage:@"$DOYMA":nsize:6]==0)
                {
                    packageType = @"$DOYMA";
                    packageData = [NSData dataWithBytes:revbuf + head length:6];
                    head += 6;
                }
                else if([self isPackage:@"$DOYMM":nsize:6]==0)
                {
                    packageType = @"$DOYMM";
                    packageData = [NSData dataWithBytes:revbuf + head length:6];
                    head += 6;
                }
                else if([self isPackage:@"$SETEN":nsize:6]==0)
                {
                    packageType = @"$SETEN";
                    packageData = [NSData dataWithBytes:revbuf + head length:6];
                    head += 6;
                }
                else if([self isPackage:@"$SETEX":nsize:6]==0)
                {
                    packageType = @"$SETEX";
                    packageData = [NSData dataWithBytes:revbuf + head length:6];
                    head += 6;
                }
                else if([self isPackage:@"$PAR":nsize:45]==0)
                {
                    packageType = @"$PAR";
                    packageData = [NSData dataWithBytes:revbuf + head length:45];
                    head += 45;
                }
                else if([self isPackage:@"$MG2":nsize:13]==0)
                {
                    packageType = @"$MG2";
                    packageData = [NSData dataWithBytes:revbuf + head length:13];
                    head += 13;
                }
                else if([self isPackage:@"$MG3":nsize:13]==0)
                {
                    packageType = @"$MG3";
                    packageData = [NSData dataWithBytes:revbuf + head length:13];
                    head += 13;
                }
                
                else if([self isPackage:@"$MG1":nsize:25]==0)
                {
                    packageType = @"$MG1";
                    packageData = [NSData dataWithBytes:revbuf + head length:25];
                    head += 25;
                }
                else if([self isPackage:@"$LIM":nsize:16]==0)
                {
                    packageType = @"$LIM";
                    packageData = [NSData dataWithBytes:revbuf + head length:16];
                    head += 16;
                }
                else if([self isPackage:@"$PUR":nsize:37]==0)
                {
                    packageType = @"$PUR";
                    packageData = [NSData dataWithBytes:revbuf + head length:37];
                    head += 37;
                }
                else if([self isPackage:@"$HHH":nsize:40]==0)
                {
                    packageType = @"$HHH";
                    packageData = [NSData dataWithBytes:revbuf + head length:40];
                    head += 40;
                }
                else if([self isPackage:@"$PAED":nsize:16]==0)
                {
                    packageType = @"$PAED";
                    packageData = [NSData dataWithBytes:revbuf + head length:16];
                    head += 16;
                }
                else if([self isPackage:@"$QUZA":nsize:35]==0)
                {
                    packageType = @"$QUZA";
                    packageData = [NSData dataWithBytes:revbuf + head length:35];
                    head += 35;
                }
                else if([self isPackage:@"$1MIN":nsize:5]==0)
                {
                    packageType = @"$1MIN";
                    packageData = [NSData dataWithBytes:revbuf + head length:5];
                    head += 5;
                }
                else {
                    head++;
                    packageData = nil;
                    packageType = @"";
                }
                
                if (packageType == nil || [packageType isEqualToString:@""]) {
                    return nil;
                }
                else{
                    return [EvaRawPackage packageWithType:packageType data:packageData];
                }
            }
			break;
        }
        else
            head++;
		
		if (head >= tail)  //没有有效数据
		{
			head = 0;
			tail = 0;
			revbuf[head] =0;
			return nil;
		}
	}
}

-(NSArray *)extractAll{
    NSMutableArray *packages = nil;;
    EvaRawPackage *onePackage = nil;
    
    while ((onePackage = [self extract]) != nil) {
        if (packages == nil) {
            packages = [NSMutableArray array];
        }
        
        [packages addObject:onePackage];
    }
    
    return packages;
}

- (int)isCmd:(NSString *)szcmd
{
    int flag1 = 0;
    
	NSData *data = [szcmd dataUsingEncoding:NSUTF8StringEncoding];
	Byte *dataBuf =(Byte *)[data bytes];
	int n = [data length];
	for(int i = 0; i < n; i++){
		Byte b = dataBuf[i];
		if(!(revbuf[head+i]==b)){
			flag1++;
		}
	}
	
	return flag1;
}

//返回0说明是szcmd数据包
-(int) isPackage:(NSString*) szcmd :(int) nsize :(int) npackage{
	int flag1 = 0;
	int flag = 1;
	NSData *data = [szcmd dataUsingEncoding:NSUTF8StringEncoding];
	Byte *dataBuf =(Byte *)[data bytes];
	int n = [data length];
	for(int i = 0; i < n; i++){
		Byte b = dataBuf[i];
		if(!(revbuf[head+i]==b)){
			flag1++;   //flag1>0时说明收到的数据包与szcmd不匹配
		}
	}
	
	if(flag1==0){
		if (nsize>=npackage)   //如果收到的数据包大小
		{
			flag = 0;
		}
	}
	
	return flag;
}


@end
