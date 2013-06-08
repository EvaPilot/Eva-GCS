//
//  MyAlertView.m
//  EVA GCS
//
//  Created by 11 on 11-12-14.
//  Copyright 2011 Hex Airbot. All rights reserved.
//

#import "MyAlertView.h"


@implementation MyAlertView

- (int)showModal 
{     
	self.delegate = self;     
	self.tag = -1; 
    [self setAlpha:0.1];
	[self show];    
	CFRunLoopRun();    
	return self.tag;
}  
- (void)alertView:(UIAlertView *)alertview didDismissWithButtonIndex:(NSInteger)buttonIndex
{     
	alertview.tag = buttonIndex;    
	alertview.delegate = nil;     
	CFRunLoopStop(CFRunLoopGetCurrent());
} 
@end 
