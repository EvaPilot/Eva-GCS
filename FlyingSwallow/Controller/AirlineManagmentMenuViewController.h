//
//  AirlineManagmentMenuViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-8.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationDidSelectAirlineManagmentMenuItem @"DidSelectAirlineManagmentMenuItem"
#define kAirlineManagmentMenuKeyItem @"Item"

typedef enum airline_managment_menu_item{
    airline_managment_menu_item_new = 0,
    airline_managment_menu_item_airline_list = 1
}airline_managment_menu_item_t;

@interface AirlineManagmentMenuViewController : UIViewController{
    IBOutlet UITableView *listTableView;
}

@property (nonatomic, retain) NSArray *list;

- (id)initWithList:(NSArray *)list;

@end
