//
//  FlightModeViewControl.h
//  RCTouch
//
//  Created by koupoo on 13-4-16.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightModeViewController;

@protocol FlightModeViewControlDelegate<NSObject>

- (void)flightModeViewController:(FlightModeViewController *)flightModeVC buttonDidTouchUpInside:(UIButton *)button;

@end

@interface FlightModeViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) IBOutlet UIButton *hoverButton;
@property (retain, nonatomic) IBOutlet UIButton *manualModeButton;
@property (retain, nonatomic) IBOutlet UIButton *altHoldButton;
@property (retain, nonatomic) IBOutlet UIButton *circleButton;
@property (retain, nonatomic) IBOutlet UIButton *fixedPositionButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@property (retain, nonatomic) IBOutlet UILabel *followTextLabel;

@property (nonatomic, assign) id<FlightModeViewControlDelegate> delegate;

- (IBAction)handleButtonDidTouchInside:(id)sender;


@end
