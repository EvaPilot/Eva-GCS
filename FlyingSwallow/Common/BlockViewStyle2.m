//
//  BlockViewStyle2.m
//  LogOnView
//
//  Created by koupoo on 11-5-24.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import "BlockViewStyle2.h"
#import <QuartzCore/QuartzCore.h>


@implementation BlockViewStyle2

@synthesize activityIndicatorView;
@synthesize indicatorLabel;

- (id)initWithFrame:(CGRect)frame indicatorTitle:(NSString *)indicatorTitle{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		activityIndicatorView= [[UIActivityIndicatorView alloc] 
								initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		
	
		[self addSubview:activityIndicatorView];
		[activityIndicatorView startAnimating];
		
		indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
																   frame.size.height * 2 / 3,
																   frame.size.width, 
																   frame.size.height / 7)];
		UIFont *textFont = [UIFont systemFontOfSize:14];
		
		indicatorLabel.font = textFont;
		
		[indicatorLabel setTextAlignment:UITextAlignmentCenter];
		[indicatorLabel setBackgroundColor:[UIColor clearColor]];
		[indicatorLabel setText:indicatorTitle];
		
		[self addSubview:indicatorLabel];

		self.layer.cornerRadius = frame.size.height / 12;;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
	[activityIndicatorView release];
	[indicatorLabel release];
    [super dealloc];
}

@end
