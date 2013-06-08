//
//  FlightModeViewControl.m
//  RCTouch
//
//  Created by koupoo on 13-4-16.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "FlightModeViewController.h"

@interface FlightModeViewController ()

@end

@implementation FlightModeViewController
@synthesize delegate;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_followButton release];
    [_hoverButton release];
    [_manualModeButton release];
    [_altHoldButton release];
    [_circleButton release];
    [_fixedPositionButton release];
    [_closeButton release];
    [_followTextLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFollowButton:nil];
    [self setHoverButton:nil];
    [self setManualModeButton:nil];
    [self setAltHoldButton:nil];
    [self setCircleButton:nil];
    [self setFixedPositionButton:nil];
    [self setCloseButton:nil];
    [self setFollowTextLabel:nil];
    [super viewDidUnload];
}

- (IBAction)handleButtonDidTouchInside:(id)sender{
    if (sender == _closeButton) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.view.alpha = 0;
                         } completion:^(BOOL finished){
                             [self.view removeFromSuperview];
                             self.view.alpha = 1;
                         }
         ];
    }
    if (delegate != nil && [delegate respondsToSelector:@selector(flightModeViewController:buttonDidTouchUpInside:)]) {
        [delegate flightModeViewController:self buttonDidTouchUpInside:sender];
    }
}


@end
