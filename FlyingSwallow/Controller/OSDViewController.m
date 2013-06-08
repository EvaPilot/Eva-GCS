//
//  OSDViewController.m
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "OSDViewController.h"

@interface OSDViewController (){
    BOOL osdViewVisible;
}

@end

@implementation OSDViewController
@synthesize osdData = _osdData;

- (void)updateUI{
    float roll = _osdData.roll / 180.0 * M_PI;
    float pitch = _osdData.pitch / 180.0 * M_PI;
    
    [artificalHorizonView setRoll:roll pitch:pitch];
    
    float width = MIN(artificalHorizonView.bounds.size.width, artificalHorizonView.bounds.size.height);
    
    artificalHorizonView.bounds = CGRectMake(0, 0, width, width);
    artificalHorizonView.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
    [artificalHorizonView requestRedraw];
}

- (IBAction)switchOsdViewVisibleState:(id)sender {
    [self setOsdViewVisibleState:!osdViewVisible];
}

- (void)setOsdViewVisibleState:(BOOL)visible{
    if (visible == osdViewVisible) {
        return;
    }
    
    CGPoint newCenter;
    
    if (visible) {
        newCenter = CGPointMake(self.view.center.x - 222, self.view.center.y);
    }
    else{
        newCenter = CGPointMake(self.view.center.x + 222, self.view.center.y);
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.center = newCenter;
                         
                     } completion:^(BOOL finished){
                         osdViewVisible = visible;
                     }
     ];
}

- (void)setOsdData:(EvaOSDData *)osdData{
    [_osdData release];
    _osdData = [osdData retain];
    [self updateUI];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(EvaOSDData *)osdData{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _osdData = [osdData retain];
        osdViewVisible = YES;
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
    [artificalHorizonView setRoll: 0 pitch: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_osdData release];
    [artificalHorizonView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [artificalHorizonView release];
    artificalHorizonView = nil;
    [super viewDidUnload];
}
@end
