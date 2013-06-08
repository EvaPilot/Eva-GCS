 //
//  PPMTransmitter.m
//  RCTouch
//
//  Created by koupoo on 13-3-15.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "Transmitter.h"
#import "AsyncUdpSocket.h"
#import "BasicInfoManager.h"
#import "EvaPackageExtractor.h"
#import "EvaRawPackage.h"
#import "MyAlertView.h"
#import "EvaCommand.h"
#import "EvaAirlineUploader.h"


#define kPpmChannelCount 8

#define UDP_SERVER_HOST @"192.168.1.254"
#define UDP_SERVER_PORT 55555

#define kOsdRequestFreqRatio  2        //Freq = 1.0/kOsdRequestFreqRatio * 50 

#define kInputAllowableContiniousTimeoutCount  2
#define kOutputAllowableContiniousTimeoutCount 2

#define kInputTimeout  0.5
#define kOutputTimeout 0.5

static Transmitter *sharedTransmitter;

@interface Transmitter(){
    enum PpmPolarity polarity;
    NSTimer *timer;
    NSTimer *updateDataTimer;
    float channelList[kPpmChannelCount];

    unsigned char ppmPackage[30];
    
    AsyncUdpSocket *udpSocket;
    
    BOOL socketIsSetuped;
    
    int outputTimeoutCount;
    int inputTimeoutCount;
    
    NSMutableArray *extractorList;
    NSMutableArray *receivedPackageList;
}

@end

@implementation Transmitter

@synthesize osdData = _osdData;
@synthesize config = _config;
@synthesize magData = _magData;
@synthesize outputState = _outputState;
@synthesize inputState = _inputState;
@synthesize needsTransmmitPpmPackage = _needsTransmmitPpmPackage;

+ (Transmitter *)sharedTransmitter{
    if (sharedTransmitter == nil) {
		sharedTransmitter = [[super alloc] init];
		return sharedTransmitter;
	}
	return sharedTransmitter;
}

- (id)init{
    if(self = [super init]){
        _outputState = TransmitterStateOk;
        _inputState = TransmitterStateOk;
    }
    return self;
}

- (void)updatePpmPackage{    
    int yaw      = (uint16_t)(1500 + 500 * channelList[3]);
    int aileron  = (uint16_t)(1500 + 500 * channelList[0]);
    int elevator = (uint16_t)(1500 + 500 * channelList[1]);
    int throttle = (uint16_t)(1500 + 500 * channelList[2]);
    
    int chan5    = (uint16_t)(1500 + 500 * channelList[4]);
    int chan6    = (uint16_t)(1500 + 500 * channelList[5]);
    
    Byte hightByte = yaw / 256;
    Byte lowByte   = yaw - hightByte * 256;
    
    ppmPackage[5] = ppmPackage[17] = hightByte;
    ppmPackage[6] = ppmPackage[18] = lowByte;
    
    hightByte = aileron / 256;
    lowByte   = aileron - hightByte * 256;
    
    ppmPackage[7] = ppmPackage[19] = hightByte;
    ppmPackage[8] = ppmPackage[20] = lowByte;
    
    hightByte = elevator / 256;
    lowByte   = elevator - hightByte * 256;
    
    ppmPackage[9]  = ppmPackage[21] = hightByte;
    ppmPackage[10] = ppmPackage[22] = lowByte;
    
    hightByte = throttle / 256;
    lowByte   = throttle - hightByte * 256;
    
    ppmPackage[11] = ppmPackage[23] = hightByte;
    ppmPackage[12] = ppmPackage[24] = lowByte;
    
    hightByte = chan5 / 256;
    lowByte   = chan5- hightByte * 256;
    
    ppmPackage[13] = ppmPackage[25] = hightByte;
    ppmPackage[14] = ppmPackage[26] = lowByte;
    
    hightByte = chan6 / 256;
    lowByte   = chan6 - hightByte * 256;
    
    ppmPackage[15] = ppmPackage[27] = hightByte;
    ppmPackage[16] = ppmPackage[28] = lowByte;
    
    ppmPackage[29] = 0;
}

- (void)updatePackageCheckSum{
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 21;
    
    for (int checkIdx = dataSizeIdx; checkIdx < checkSumIdx; checkIdx++) {
        checkSum ^= (ppmPackage[checkIdx] & 0xFF);
    }
    
    ppmPackage[checkSumIdx] = checkSum;
}

- (void)initPackage{
    ppmPackage[0] = '$';
    ppmPackage[1] = 'I';
    ppmPackage[2] = 'E';
    ppmPackage[3] = 'V';
    ppmPackage[4] = 'A';
    
    [self updatePpmPackage];
}

- (void)sendTransmitterStateDidChangeNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTransmitterStateDidChange object:self userInfo:nil];
}

- (void)sendOsdRequest{

}

- (void)updateData{
    EvaRawPackage *rawPackage = nil;
    
    if(receivedPackageList.count > 0)
    {
        rawPackage = [[receivedPackageList objectAtIndex:0] retain];
        [receivedPackageList removeObject:rawPackage];
    }

    if(rawPackage != nil)
    {
        //int revSTPcount =0;
        if ([rawPackage.type compare:@"$STP"]==NSOrderedSame) {
            [_osdData updateWithRawPackage:rawPackage];
            [[[BasicInfoManager sharedManager] osdInfoPaneVC] updateUI];
            [[[BasicInfoManager sharedManager] osdVC] updateUI];
            
            //更新通道显示
            if ([[[[BasicInfoManager sharedManager] configVC] view] superview] != nil) {
                [[[BasicInfoManager sharedManager] configVC] updateChannelView];
                [[[BasicInfoManager sharedManager] configVC] updateFilghtModeTextFiled];
            }        }
        else if ([rawPackage.type compare:@"$PAR"]==NSOrderedSame) { //参数页面
            [_config updateWithRawPackage:rawPackage];
            [[[BasicInfoManager sharedManager] configVC] updateUI];
        }
        else if ([rawPackage.type compare:@"$SETD"]==NSOrderedSame) {
            [[[BasicInfoManager sharedManager] airlineUploader] verifyWaypoint:rawPackage];
        }
        else if ([rawPackage.type compare:@"$DOYMA"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$DOYMM"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$SETEN"] == NSOrderedSame) {  //进入设置得到回应
        }
        else if ([rawPackage.type compare:@"$SETEX"]==NSOrderedSame) { //退出设置得到回应
        }
        else if ([rawPackage.type compare:@"$DIN"] == NSOrderedSame) { //定点飞行
            const Byte *p = rawPackage.data.bytes;
            float latitude = 0.0 ;
            float longitude = 0.0;
            
            Byte *pp = (Byte*)&latitude;
            for (int i=0; i<4; i++) {
                pp[i]=p[8+i] ;
            }
            pp = (Byte*)&longitude;
            for (int i=0; i<4; i++) {
                pp[i]=p[4+i] ;
            }
            
            [[BasicInfoManager sharedManager] setPointFlightTargetLocation:CLLocationCoordinate2DMake(latitude, longitude)];
        }
        else if ([rawPackage.type compare:@"$MG2"] == NSOrderedSame) {
           [_magData updateWithRawPackage:rawPackage];
        }
        else if ([rawPackage.type compare:@"$MG3"] == NSOrderedSame) {
            [_magData updateWithRawPackage:rawPackage];
        }
        else if ([rawPackage.type compare:@"$MG1"] == NSOrderedSame) {
            [_magData updateWithRawPackage:rawPackage];
        }
        else if ([rawPackage.type compare:@"$LIM"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$PUR"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$PAED"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$QUZA"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$HHH"]==NSOrderedSame) {
        }
        else if ([rawPackage.type compare:@"$1MIN"]==NSOrderedSame) {
        }
    
        if ([rawPackage.type compare:@"$STP"]==NSOrderedSame) {
		}
        else{
        }
        
        [rawPackage release];
    }
}

- (void)transmmit{  //每20ms发送一次
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self updatePpmPackage];
    
    NSMutableData *data = nil;
    
    if (_needsTransmmitPpmPackage) {
        data = [NSMutableData dataWithBytes:ppmPackage length:30];
        [udpSocket sendData:data  toHost:UDP_SERVER_HOST port:UDP_SERVER_PORT withTimeout:kOutputTimeout tag:0];
        
//        NSLog(@"yaw:%d, ail:%d, ele:%d, thr:%d, chan5:%d, chan6:%d"
//              ,(uint16_t)(1500 + 500 * channelList[3])
//              ,(uint16_t)(1500 + 500 * channelList[0])
//              ,(uint16_t)(1500 + 500 * channelList[1])
//              ,(uint16_t)(1500 + 500 * channelList[2])
//              ,(uint16_t)(1500 + 500 * channelList[4])
//              ,(uint16_t)(1500 + 500 * channelList[5]));
    }
    else{
        NSData *dummyCommand = [EvaCommand getDummyCommand];
        //用空命令激励飞控返还数据，若不发送空命令，飞控的osd和config数据不会返回
        data = [NSMutableData dataWithBytes:[dummyCommand bytes] length:[dummyCommand length]];
    }
    
    static int gcsLocationTimer = 0;
    gcsLocationTimer++;
    
    if (gcsLocationTimer == 25) {
        gcsLocationTimer = 0;
        
        if([[BasicInfoManager sharedManager] locationIsUpdated]) {
            BasicInfoManager *infoManager = [BasicInfoManager sharedManager];
            
            if ([infoManager needsFollow]) {
                NSLog(@"***debug:send gcs location to eva");
                
                CLLocationCoordinate2D location = [infoManager location];
                
                float longitude = location.longitude;
                float latitude = location.latitude;
                
                NSData *followCommand = [EvaCommand getFollowCommandWithLongitude:longitude latitude:latitude];
                
                [udpSocket sendData:followCommand toHost:UDP_SERVER_HOST port:UDP_SERVER_PORT withTimeout:kOutputTimeout tag:0];
                
                [data appendData:followCommand];
            }
        }
    }
    
    [udpSocket sendData:data toHost:UDP_SERVER_HOST port:UDP_SERVER_PORT withTimeout:kOutputTimeout tag:0];

    [pool release];
}

- (BOOL)transmmitData:(NSData *)data{
    if (data == nil) {
        return NO;
    }
    else{
        [udpSocket receiveWithTimeout:kInputTimeout tag:0];
        [udpSocket sendData:data  toHost:UDP_SERVER_HOST port:UDP_SERVER_PORT withTimeout:kOutputTimeout tag:0];
        return YES;
    }
}

- (BOOL)start{
    [self stop];
    
    if (receivedPackageList == nil) {
        receivedPackageList = [[NSMutableArray alloc] init];
        extractorList =  [[NSMutableArray alloc] init];
    }
    
    _needsTransmmitPpmPackage = YES;
    
    [self initPackage];
    [self setupSocket];

    if (_osdData == nil) {
        _osdData = [[EvaOSDData alloc] init];
        _osdData.physicalRcEnabled = YES;
        
        NSString *documentsDir= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *userConfigFilePath = [documentsDir stringByAppendingPathComponent:@"EvaConfig.plist"];
        
        _config = [[EvaConfig alloc] initWithConfigFile:userConfigFilePath];
        _magData = [[EvaMag alloc] init];
    }
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(transmmit) userInfo:nil repeats:YES] retain];
    
    updateDataTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateData) userInfo:nil repeats:YES] retain];

    return YES;
}

- (BOOL)stop{    
    [timer invalidate];
    [timer release];
    timer = nil;
    
    [updateDataTimer invalidate];
    [updateDataTimer release];
    updateDataTimer = nil;
    
    [receivedPackageList removeAllObjects];
    [extractorList removeAllObjects];
    
    _needsTransmmitPpmPackage = NO;
    
    [self closeSocket];
    
    return YES;
}

- (void)setPpmValue:(float)value atChannel:(int)channelIdx{
    channelList[channelIdx] = value;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	exit(0);
}

- (void)showBindToPortErrAlertView{
    NSString *msg = [NSString stringWithFormat:@"RC Touch can't bind to port %d. The port may be already used by another app.", UDP_SERVER_PORT];

    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Sorry" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (BOOL)setupSocket
{
    if(socketIsSetuped) 
        return YES;
    else{
        if(udpSocket == nil)
            udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self enableIPv6:NO];
        
        NSError *error = nil;
        
        if (![udpSocket bindToPort:UDP_SERVER_PORT error:&error])
        {
            NSLog(@"Error binding: %@", error);
            [self showBindToPortErrAlertView];
            return NO;
        }
        
        [udpSocket receiveWithTimeout:kInputTimeout tag:0];
        
        NSLog(@"UDP is Ready\r");
        
        socketIsSetuped = YES;
        
        return YES;
    }
}

- (BOOL)closeSocket{    
    [udpSocket close];
    [udpSocket release];
    udpSocket = nil;
    
    socketIsSetuped = NO;
    return YES;
}

- (EvaPackageExtractor *)getPackageExtractorForPort:(int)port host:(NSString *)host{
    EvaPackageExtractor *extractor = nil;
    for(int i = 0; i< extractorList.count; i++){
        extractor = (EvaPackageExtractor *)[extractorList objectAtIndex:i];
        if((port == extractor.port) &&([host compare:extractor.host] == NSOrderedSame)){
            return extractor;
        }
    }
    
    extractor = [[EvaPackageExtractor alloc] initWithPort:port host:host];
    
    [extractorList addObject:extractor];
    
    return [extractor autorelease];
}

- (void)onUdpSocket:(AsyncUdpSocket *)socket didSendDataWithTag:(long)tag
{
    if (socket != udpSocket) { //old socket response, just skip
        return;
    }
    
    //NSLog(@"did send data****");
    
    
    outputTimeoutCount = 0;
    if (_outputState == TransmitterStateError) {
        _outputState = TransmitterStateOk;
        [self sendTransmitterStateDidChangeNotification];
    }
}

- (void)onUdpSocket:(AsyncUdpSocket *)socket didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if (socket != udpSocket) { //old socket response, just skip
        return;
    }
    
    if (outputTimeoutCount < kOutputAllowableContiniousTimeoutCount) {
        outputTimeoutCount++;
        
        if (outputTimeoutCount == kOutputAllowableContiniousTimeoutCount) {
            _outputState = TransmitterStateError;
            [self sendTransmitterStateDidChangeNotification];
        }
    }
    
    //NSLog(@"Did note send data, Err:%@", error);
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)socket
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    if (socket != udpSocket) { //old socket response, just skip
        return YES;
    }
    
    //NSLog(@"did receive data****");
    
    EvaPackageExtractor *extractor = [self getPackageExtractorForPort:port host:host];

    [extractor addData:data];
    [receivedPackageList addObjectsFromArray:[extractor extractAll]];

    [udpSocket receiveWithTimeout:kOutputTimeout tag:0];
    
    inputTimeoutCount = 0;
    
    if (_inputState == TransmitterStateError) {
        _inputState = TransmitterStateOk;
        [self sendTransmitterStateDidChangeNotification];
    }
    
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)socket didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    if (socket != udpSocket) { //old socket response, just skip
        return;
    }
    
    [udpSocket receiveWithTimeout:kInputTimeout tag:0];
    
    if (inputTimeoutCount < kInputAllowableContiniousTimeoutCount ) {
        inputTimeoutCount++;
        
        if (inputTimeoutCount == kInputAllowableContiniousTimeoutCount) {
            _inputState = TransmitterStateError;
            [self sendTransmitterStateDidChangeNotification];
        }
    }
    
   // NSLog(@"Did note receive data, Err:%@", error);
}


- (void)dealloc{
    [self stop];
    [extractorList removeAllObjects];
    [udpSocket release];
    [_osdData  release];
    [_config release];
    [_magData release];
    [super dealloc];
}

@end
