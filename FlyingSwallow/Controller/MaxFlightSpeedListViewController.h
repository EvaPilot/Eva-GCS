//
//  MaxFlightSpeedListViewController.h
//  RCTouch
//
//  Created by koupoo on 13-3-31.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationDidSelectMaxFlightSpeed @"NDidSelectMaxFlightSpeed"

#define kMaxFlightSpeedKeyDescription  @"description"
#define kMaxFlightKeySpeed  @"speed"

@interface MaxFlightSpeedListViewController : UIViewController{
    IBOutlet UITableView *listTableView;
}

@property (nonatomic, retain) NSArray *list;

- (id)initWithList:(NSArray *)list;

@end
