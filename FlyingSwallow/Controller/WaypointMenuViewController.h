//
//  WaypointMenuViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-9.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationDidSelectWaypointMenuItem @"DidSelectWaypointMenuItem"
#define kWaypointMenuKeyItem @"Item"

typedef enum waypoint_menu_item{
    waypoint_menu_item_edit   = 0,
    waypoint_menu_item_delete = 1,
    waypoint_menu_item_flight_to   = 2,
}waypoint_menu_item_t;


@interface WaypointMenuViewController : UIViewController{
    IBOutlet UITableView *listTableView;
}

@property (nonatomic, retain) NSArray *list;

- (id)initWithList:(NSArray *)list;

@end
