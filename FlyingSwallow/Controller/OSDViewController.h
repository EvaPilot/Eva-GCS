//
//  OSDViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-2.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "VerticalScaleView.h"
#import "EvaOSDData.h"

@interface OSDViewController : UIViewController{
    IBOutlet ArtificialHorizonView *artificalHorizonView;
    
}

@property(nonatomic, retain) EvaOSDData *osdData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(EvaOSDData *)osdData;

- (void)updateUI;
- (IBAction)switchOsdViewVisibleState:(id)sender;
- (void)setOsdViewVisibleState:(BOOL)visible;

@end
