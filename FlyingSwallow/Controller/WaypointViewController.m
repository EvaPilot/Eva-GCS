//
//  WaypointViewController.m
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "WaypointViewController.h"
#import "Macros.h"

@interface WaypointViewController (){

}

@end

@implementation WaypointViewController
@synthesize waypoint = _waypoint;
@synthesize delegate = _delegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil waypoint:(WaypointAnnotation *)waypoint{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _waypoint = [waypoint retain];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    idxTextLabel.text = [NSString stringWithFormat:@"%d", _waypoint.no];
    longitudeTextLabel.text = [NSString stringWithFormat:@"%.7f", _waypoint.coordinate.longitude];
    latidueTextLabel.text = [NSString stringWithFormat:@"%.7f", _waypoint.coordinate.latitude];
    
    if (_waypoint.altitude == 9999) {
        altitudeTextLabel.text = [NSString stringWithFormat:@"%@", getLocalizeString(@"Default")];
    }
    else{
        altitudeTextLabel.text = [NSString stringWithFormat:@"%d", _waypoint.altitude];
    }
    
    hoverTimeTextLabel.text = [NSString stringWithFormat:@"%d", _waypoint.hoverTime];
    speedSlider.value = _waypoint.speed / 25.0;
    speedTextLabel.text = [NSString stringWithFormat:@"%.1fm/s", speedSlider.value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_waypoint release];
    [idxTextLabel release];
    [longitudeTextLabel release];
    [latidueTextLabel release];
    [altitudeTextLabel release];
    [hoverTimeTextLabel release];
    [speedSlider release];
    [needsTakePhotoSegmentControl release];
    [_navBar release];
    [speedTextLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [idxTextLabel release];
    idxTextLabel = nil;
    [longitudeTextLabel release];
    longitudeTextLabel = nil;
    [latidueTextLabel release];
    latidueTextLabel = nil;
    [altitudeTextLabel release];
    altitudeTextLabel = nil;
    [hoverTimeTextLabel release];
    hoverTimeTextLabel = nil;
    [speedSlider release];
    speedSlider = nil;
    [needsTakePhotoSegmentControl release];
    needsTakePhotoSegmentControl = nil;
    [self setNavBar:nil];
    [speedTextLabel release];
    speedTextLabel = nil;
    [super viewDidUnload];
}

- (IBAction)sliderValueDidChanged:(id)sender {
    if (sender == speedSlider) {
        speedTextLabel.text = [NSString stringWithFormat:@"%.1fm/s", speedSlider.value];
    }
}

- (IBAction)sliderDidRelease:(id)sender {
}

- (IBAction)segmentControlValueDidChanged:(id)sender {

}

- (IBAction)resetToDefaultAltitude:(id)sender {
    altitudeTextLabel.text = getLocalizeString(@"Default");
    _waypoint.altitude = 9999;
}

- (IBAction)save:(id)sender {
    NSString *errMsg = nil;
    
    NSString *longitudeStr = [longitudeTextLabel.text retain];
    NSString *latitudeStr  = [latidueTextLabel.text retain];
    NSString *altitudeStr  = [altitudeTextLabel.text retain];
    NSString *hoverTimeStr = [hoverTimeTextLabel.text retain];

    int altitude;
    
    if ([self isPureFloat:longitudeStr] == NO) {
        errMsg = getLocalizeString(@"The field of longitude is not a valid number.");
    }
    else if([longitudeStr floatValue] > 180 || [longitudeStr floatValue] < -180){
        errMsg = getLocalizeString(@"The longtitude must be between -180 and 180.");
    }
    else if ([self isPureFloat:latitudeStr] == NO) {
        errMsg = getLocalizeString(@"The field of latitude is not a valid number.");
    }
    else if([latitudeStr floatValue] > 90|| [latitudeStr floatValue] < -90){
        errMsg = getLocalizeString(@"The latitude must be between -90 and 90.");
    }
    else
        ;
    
    if (errMsg == nil) {
        if ([altitudeStr isEqualToString:getLocalizeString(@"Default")]) {
            altitude = 9999;
        }
        else{
            if ([self isPureInt:altitudeStr]) {
                if([hoverTimeStr intValue] > 9999 || [hoverTimeStr intValue] < -9999){
                    errMsg = getLocalizeString(@"The altitude must be between -2000 and 2000.");
                }
                else{
                    altitude = [altitudeStr intValue];
                }
            }
            else{
                errMsg = getLocalizeString(@"The field of altitude is not a valid integer");
            }
        }
    }

    if (errMsg != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:getLocalizeString(@"Modification Failed")
                                                            message:errMsg
                                                           delegate:self
                                                  cancelButtonTitle:getLocalizeString(@"I known")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else{
        _waypoint.coordinate = CLLocationCoordinate2DMake([latitudeStr floatValue], [longitudeStr floatValue]);
        _waypoint.altitude   = altitude;
        _waypoint.hoverTime  = [hoverTimeStr intValue];
        _waypoint.speed = (int)(25 * speedSlider.value);    
    }
    
    [longitudeStr release];
    [latitudeStr release];
    [altitudeStr release];
    [hoverTimeStr release];
    
    if ([_delegate respondsToSelector:@selector(waypointMenuViewController:didChangeWaypoint:)]) {
        [_delegate waypointMenuViewController:self didChangeWaypoint:_waypoint];
    }
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
} 

@end
