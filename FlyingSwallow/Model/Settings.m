//
//  Settings.m
//  FlyingSwallow
//
//  Created by koupoo on 12-12-22.
//  Copyright (c) 2012年 www.hexairbot.com. All rights reserved.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License V2
//  as published by the Free Software Foundation.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "Settings.h"
#import "Channel.h"

@implementation Settings
@synthesize settingsData = _settingsData;
@synthesize interfaceOpacity = _interfaceOpacity;
@synthesize isLeftHanded = _isLeftHanded;
@synthesize ppmPolarityIsNegative = _ppmPolarityIsNegative;
@synthesize aileronDeadBand = _aileronDeadBand;
@synthesize elevatorDeadBand = _elevatorDeadBand;
@synthesize rudderDeadBand = _rudderDeadBand;
@synthesize takeOffThrottle = _takeOffThrottle;


- (id)initWithSettingsFile:(NSString *)settingsFilePath{
    self = [super init];
    
    if(self){
        _path = settingsFilePath;
        [_path retain];
        
        _settingsData = [[NSMutableDictionary alloc] initWithContentsOfFile:_path];
        
        _interfaceOpacity = [[_settingsData objectForKey:kKeySettingsInterfaceOpacity] floatValue];
        _isLeftHanded = [[_settingsData objectForKey:kKeySettingsIsLeftHanded] boolValue];
        _ppmPolarityIsNegative = [[_settingsData objectForKey:kKeySettingsPpmPolarityIsNegative] boolValue];
        _aileronDeadBand = [[_settingsData objectForKey:kKeySettingsAileronDeadBand] floatValue];
        _elevatorDeadBand = [[_settingsData objectForKey:kKeySettingsElevatorDeadBand] floatValue];
        _rudderDeadBand = [[_settingsData objectForKey:kKeySettingsRudderDeadBand] floatValue];
        _takeOffThrottle = [[_settingsData objectForKey:kKeySettingsTakeOffThrottle] floatValue];
        
        NSArray *channelDataArray = [_settingsData objectForKey:kKeySettingsChannels];
        int channelCount = [channelDataArray count];
        _channelArray = [[NSMutableArray alloc] initWithCapacity:channelCount];

        for(int channelIdx = 0; channelIdx < channelCount; channelIdx++){
            Channel *channel = [[Channel alloc] initWithSetting:self idx:channelIdx];
            [_channelArray addObject:channel];
            
            [channel release];
        }
    }
    
    return self;
}

- (void)setInterfaceOpacity:(float)interfaceOpacity{
    _interfaceOpacity = interfaceOpacity;
    
    [_settingsData setObject:[NSNumber numberWithFloat:_interfaceOpacity] forKey:kKeySettingsInterfaceOpacity];
}

- (void)setIsLeftHanded:(BOOL)isLeftHanded{
    _isLeftHanded = isLeftHanded;
    
     [_settingsData setObject:[NSNumber numberWithBool:_isLeftHanded] forKey:kKeySettingsIsLeftHanded];
}

- (void)setPpmPolarityIsNegative:(BOOL)ppmPolarityIsNegative{
    _ppmPolarityIsNegative = ppmPolarityIsNegative;

     [_settingsData setObject:[NSNumber numberWithBool:_ppmPolarityIsNegative] forKey:kKeySettingsPpmPolarityIsNegative];
}

- (void)setAileronDeadBand:(float)aileronDeadBand{
    _aileronDeadBand = aileronDeadBand;
    
     [_settingsData setObject:[NSNumber numberWithFloat:_aileronDeadBand] forKey:kKeySettingsAileronDeadBand];
}

- (void)setElevatorDeadBand:(float)elevatorDeadBand{
    _elevatorDeadBand = elevatorDeadBand;
    
     [_settingsData setObject:[NSNumber numberWithFloat:_elevatorDeadBand] forKey:kKeySettingsElevatorDeadBand];
}

- (void)setRudderDeadBand:(float)rudderDeadBand{
    _rudderDeadBand = rudderDeadBand;
    
    [_settingsData setObject:[NSNumber numberWithFloat:_rudderDeadBand] forKey:kKeySettingsRudderDeadBand];
}


- (void)setTakeOffThrottle:(float)takeOffThrottle{
    _takeOffThrottle = takeOffThrottle;
    
    [_settingsData setObject:[NSNumber numberWithFloat:_takeOffThrottle] forKey:kKeySettingsTakeOffThrottle];
}

- (void)save{
    [_settingsData writeToFile:_path atomically:YES];
}

- (int)channelCount{
    return [_channelArray count];
}

- (Channel *)channelAtIndex:(int)i{
    if(i < [_channelArray count]){
        return [_channelArray objectAtIndex:i];
    }
    else {
        return nil;
    }
}

- (Channel *)channelByName:(NSString*)name{
    for(Channel *channel in _channelArray){
        if([name isEqualToString:[channel name]]){
            return channel;
        }
    }
    return nil;
}

- (void)changeChannelFrom:(int)from to:(int)to{
    Channel *channel = [[_channelArray objectAtIndex:from] retain];
	[_channelArray removeObjectAtIndex:from];
	[_channelArray insertObject:channel atIndex:to];
	[channel release];
    
    NSMutableArray *channelDataArray = (NSMutableArray *)[_settingsData valueForKey:kKeySettingsChannels];
    
	id channelData = [[channelDataArray objectAtIndex:from] retain];
	[channelDataArray removeObjectAtIndex:from];
	[channelDataArray insertObject:channelData atIndex:to];
	[channelData release];
	
	int idx = 0;
	for (Channel *oneChannel in _channelArray) {
		oneChannel.idx = idx++;
	}
}

- (void)resetToDefault{
    NSString *defaultSettingsFilePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    
    Settings *defaultSettings = [[Settings alloc] initWithSettingsFile:defaultSettingsFilePath];
    
    NSDictionary *defaultSettingsData = defaultSettings.settingsData;
    
    self.interfaceOpacity = [[defaultSettingsData objectForKey:kKeySettingsInterfaceOpacity] floatValue];
    self.isLeftHanded = [[defaultSettingsData objectForKey:kKeySettingsIsLeftHanded] boolValue];
    self.ppmPolarityIsNegative = [[defaultSettingsData objectForKey:kKeySettingsPpmPolarityIsNegative] boolValue];
    self.aileronDeadBand = [[defaultSettingsData objectForKey:kKeySettingsAileronDeadBand] floatValue];
    self.elevatorDeadBand = [[defaultSettingsData objectForKey:kKeySettingsElevatorDeadBand] floatValue];
    self.rudderDeadBand = [[defaultSettingsData objectForKey:kKeySettingsRudderDeadBand] floatValue];
    self.takeOffThrottle = [[defaultSettingsData objectForKey:kKeySettingsTakeOffThrottle] floatValue];
    
    int channelCount = [defaultSettings channelCount];
    
    for(int defaultChannelIdx = 0; defaultChannelIdx < channelCount; defaultChannelIdx++){
        Channel *defaultChannel = [[Channel alloc] initWithSetting:defaultSettings idx:defaultChannelIdx];

        Channel *channel = [self channelByName:defaultChannel.name];
        
        if(channel.idx != defaultChannelIdx){
            Channel *needsReordedChannel = [_channelArray objectAtIndex:defaultChannelIdx];
            needsReordedChannel.idx = channel.idx;
            
            [_channelArray exchangeObjectAtIndex:defaultChannelIdx withObjectAtIndex:channel.idx];
            
            channel.idx = defaultChannelIdx;
        }

        channel.isReversing = defaultChannel.isReversing;
        channel.trimValue = defaultChannel.trimValue;
        channel.outputAdjustabledRange = defaultChannel.outputAdjustabledRange;
        channel.defaultOutputValue = defaultChannel.defaultOutputValue;
        channel.value = channel.defaultOutputValue;

        [defaultChannel release];
    }
    
    [defaultSettings release];
}

- (void)dealloc{
    [_path release];
    [_settingsData release];
    [_channelArray release];
    [super dealloc];
}


@end
