//
//  AirlineListViewController.h
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNoticationAirlineOpen @"NAirlineOpen"
#define kAirlineKeyFileName    @"FileName"

@interface AirlineListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    IBOutlet UITableView *listTableView;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;

@property(nonatomic, retain) NSMutableArray *airlineList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil airlineList:(NSArray *)airlineList;

@end
