//
//  AppDelegate.m
//  FlyingSwallow
//
//  Created by koupoo on 12-12-21. Email: liaojinhua@angeleyes.it
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

#import "AppDelegate.h"
#import "BasicInfoManager.h"
#import "EvaGcsLocation.h"
#import "EvaAirlineFile.h"
#import "Transmitter.h"

@interface AppDelegate(){
    CLLocationManager *locationManager;
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [locationManager release];
    [super dealloc];
}

- (void)copyDefaultSettingsFileIfNeeded{
    NSString *documentsDir= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *userSettingsFilePath= [documentsDir stringByAppendingPathComponent:@"Settings.plist"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:userSettingsFilePath] == NO){
        
        NSString *settingsFilePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        [fileManager copyItemAtPath:settingsFilePath toPath:userSettingsFilePath error:NULL];
    }
}

- (void)copyDefaultConfigFileIfNeeded{
    NSString *documentsDir= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *userSettingsFilePath= [documentsDir stringByAppendingPathComponent:@"EvaConfig.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:userSettingsFilePath] == NO){
        NSString *settingsFilePath = [[NSBundle mainBundle] pathForResource:@"EvaConfig" ofType:@"plist"];
        [fileManager copyItemAtPath:settingsFilePath toPath:userSettingsFilePath error:NULL];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self copyDefaultSettingsFileIfNeeded];
    [self copyDefaultConfigFileIfNeeded];
    [EvaAirlineFile createAirlineDocumentIfNeeded];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.viewController = [[[HudViewController alloc] initWithNibName:@"HudViewController" bundle:[NSBundle mainBundle]] autorelease];
        
               // self.viewController = [[[HudViewController alloc] init
        
    } else {
#ifdef __DEMO__
        self.viewController = [[[HudViewController alloc] initWithNibName:@"HudViewController_iPhone_Demo" bundle:nil] autorelease];

#else
        self.viewController = [[[HudViewController alloc] initWithNibName:@"HudViewController_maptest" bundle:nil] autorelease];
#endif
    }
    
    self.window.rootViewController = _viewController;
    
    [self.window makeKeyAndVisible];
    
    [self startUpdateLocation];
        
    return YES;
}

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//     return UIInterfaceOrientationMaskLandscapeLeft;
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[Transmitter sharedTransmitter] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   [[Transmitter sharedTransmitter] start];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startUpdateLocation{
    locationManager = [[CLLocationManager alloc] init];

    if ([CLLocationManager locationServicesEnabled]){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
        [locationManager startUpdatingLocation];
    }
    else{
        NSLog(@"***sorry, location service is not availabled");
    }
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    NSLog(@"***lat:%f, lon:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    if (abs(howRecent) < 5.0){
        BasicInfoManager *basicInfoManager = [BasicInfoManager sharedManager];
        [basicInfoManager setLocation:newLocation.coordinate];
        [basicInfoManager setLocationIsUpdated:YES];
    }
}


//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    CLLocation *newLocation = [locations objectAtIndex:[locations count] - 1];
//    
//    NSDate *eventDate = newLocation.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//	
//    NSLog(@"***lat:%f, lon:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
//    
//    if (abs(howRecent) < 5.0){
//        BasicInfoManager *basicInfoManager = [BasicInfoManager sharedManager];
//        [basicInfoManager setLocation:newLocation.coordinate];
//        [basicInfoManager setLocationIsUpdated:YES];
//    }
//}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{  
    BasicInfoManager *basicInfoManager = [BasicInfoManager sharedManager];
    [basicInfoManager setLocationIsUpdated:NO];
}

@end
