//
//  WaypointViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaypointAnnotation.h"

@class WaypointViewController;

@protocol WaypointViewControllerDelegate <NSObject>

@optional

- (void)waypointMenuViewController:(WaypointViewController *)waypointVC didChangeWaypoint:(WaypointAnnotation *)waypoint;

@end

@interface WaypointViewController : UIViewController{
    IBOutlet UILabel *idxTextLabel;
    IBOutlet UITextField *longitudeTextLabel;
    IBOutlet UITextField *latidueTextLabel;
    IBOutlet UITextField *altitudeTextLabel;
    IBOutlet UITextField *hoverTimeTextLabel;
    
    IBOutlet UISlider *speedSlider;
    IBOutlet UILabel *speedTextLabel;
    IBOutlet UISegmentedControl *needsTakePhotoSegmentControl;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property(nonatomic, retain) WaypointAnnotation *waypoint;
@property(nonatomic, assign) id<WaypointViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil waypoint:(WaypointAnnotation *)waypoint;

- (IBAction)sliderValueDidChanged:(id)sender;
- (IBAction)sliderDidRelease:(id)sender;
- (IBAction)segmentControlValueDidChanged:(id)sender;
- (IBAction)resetToDefaultAltitude:(id)sender;
- (IBAction)save:(id)sender;


@end
