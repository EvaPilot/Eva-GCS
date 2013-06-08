//
//  PlaneAnnotationView.m
//  RCTouch
//
//  Created by koupoo on 13-4-11.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "ImageAnnotationView.h"
#import "ImageAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageAnnotationView{
    UIImageView *imageView;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self != nil){
        CGRect frame = self.frame;
        frame.size = CGSizeMake(32.0, 32.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0.0, 0.0);	
        
        imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 32, 32)];
        
        [self addSubview:imageView];
    }
    
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation{
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    ImageAnnotation *droneAnnotation = (ImageAnnotation *)self.annotation;
    
    UIImage *droneImage = [[UIImage alloc] initWithContentsOfFile:droneAnnotation.imagePath];
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, droneImage.size.width, droneImage.size.height);
    imageView.frame = CGRectMake(0, 0, droneImage.size.width, droneImage.size.height);
    
    if (droneImage != nil) {
        //[imageView removeFromSuperview];
        //CGAffineTransform rotation = CGAffineTransformMakeRotation(droneAnnotation.rotation);
        imageView.image = droneImage;
        //imageView.transform = rotation;
        //[self addSubview:imageView];
    }
    
    [droneImage release];
}

- (void)dealloc{
    [imageView release];
    [super dealloc];
}

@end
