//
//  BlockViewStyle2.h
//  LogOnView
//
//  Created by koupoo on 11-5-24.
//  Copyright 2011 emotioncg.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BlockViewStyle2 : UIView {

}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *indicatorLabel;

//只使用该方法进行初始化，并且确保frame是合适的，而不该在初始化完毕后在进行修改view的frame
- (id)initWithFrame:(CGRect)frame indicatorTitle:(NSString *)indicatorTitle;

@end
