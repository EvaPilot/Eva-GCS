//
//  DroneTypeListViewController.h
//  RCTouch
//
//  Created by koupoo on 13-3-27.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationDidSelectDroneType @"NDidSelectDroneType"

#define kDroneTypeKeyName  @"name"
#define kDroneTypeKeyType  @"type"

@interface DroneTypeListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *typeListTableView;
}

@property (nonatomic, retain) NSArray *typeList;

- (id)initWithTypeList:(NSArray *)typeList;


@end
