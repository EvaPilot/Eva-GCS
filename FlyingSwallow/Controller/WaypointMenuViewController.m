//
//  WaypointMenuViewController.m
//  RCTouch
//
//  Created by koupoo on 13-4-9.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "WaypointMenuViewController.h"

@interface WaypointMenuViewController()

@end

@implementation WaypointMenuViewController
@synthesize list = _list;

- (id)initWithList:(NSArray *)list{
    if (self = [super init]) {
        _list = [list retain];
    }
    return self;
}

- (NSArray *)list{
    return _list;
}

- (void)setList:(NSArray *)durationList_{
    if (_list == durationList_) {
        [listTableView reloadData];
    }
    else{
        [_list release];
        _list = [durationList_ retain];
        
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height = 35 * [_list count];
        self.view.frame = viewFrame;
        
        [listTableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowIdx = [indexPath row];
    
    waypoint_menu_item_t menuItem = waypoint_menu_item_edit;
    
    if (_list.count == 1) {
        menuItem = waypoint_menu_item_flight_to;
    }
    else{
        switch (rowIdx) {
            case 0:
                menuItem = waypoint_menu_item_edit;
                break;
            case 1:
                menuItem = waypoint_menu_item_delete;
                break;
        }
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:menuItem], kWaypointMenuKeyItem, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoticationDidSelectWaypointMenuItem
                                                        object:self
                                                      userInfo:userInfo];
}

//**************UITableViewDataSource Method*******************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *cellIdentifier = @"AirlineManagmentMenuCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = 	[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:nil] autorelease];
		
		cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithWhite:0.4 alpha:1];
        cell.textLabel.shadowOffset = CGSizeMake(0, 0);
		cell.textLabel.highlightedTextColor = [UIColor blackColor];//[UIColor colorWithWhite:0.3 alpha:1];
        
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        
		//cell.backgroundColor = [UIColor clearColor]; 加了这句，显示出来的cell背景两边有白边
	}
	
	int rowIdx = [indexPath row];
    
    NSString *description = [_list objectAtIndex:rowIdx];
    
    float fontSize = 14;
    
    UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:fontSize];
    
    cell.textLabel.font = font;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = description;
    
	UIImage *bgImg;
	UIImageView *bgImgView;
	
	UIImage *selectedBgImg;
	UIImageView *selectedBgImgView;
    
    bgImg = [UIImage imageNamed:@"cell_bg.png"];
    bgImgView = [[UIImageView alloc] initWithImage:bgImg];
    
    selectedBgImg = [UIImage imageNamed:@"cell_selected_bg.png"];
    selectedBgImgView = [[UIImageView alloc] initWithImage:selectedBgImg];
    
	cell.backgroundView = bgImgView;
	cell.selectedBackgroundView = selectedBgImgView;
	
	[bgImgView release];
	[selectedBgImgView release];
	
	return cell;
}
//************************************************************


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[listTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [listTableView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [_list release];
    [listTableView release];
    listTableView = nil;
    [super viewDidUnload];
}

@end
