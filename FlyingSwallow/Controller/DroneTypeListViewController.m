//
//  DroneTypeListViewController.m
//  RCTouch
//
//  Created by koupoo on 13-3-27.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "DroneTypeListViewController.h"
#import "EvaConfig.h"

@interface DroneTypeListViewController ()

@end

@implementation DroneTypeListViewController
@synthesize typeList = _typeList;

- (id)initWithTypeList:(NSArray *)typeList{
    if (self = [super init]) {
        _typeList = [typeList retain];
    }
    return self;
}

- (NSArray *)typeList{
    return _typeList;
}

- (void)setTypeList:(NSArray *)durationList_{
    if (_typeList == durationList_) {
        [typeListTableView reloadData];
    }
    else{
        [_typeList release];
        _typeList = [durationList_ retain];
        
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height = 35 * [_typeList count];
        self.view.frame = viewFrame;
        
        [typeListTableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowIdx = [indexPath row];
    drone_type_t droneType;
    switch (rowIdx) {
        case 0:
            droneType = DroneTypeQuadX;
            break;
        case 1:
            droneType = DroneTypeQuadPlus;
            break;
        case 2:
            droneType = DroneTypeHexX;
            break;
        case 3:
            droneType = DroneTypeHexPlus;
            break;
        case 4:
            droneType = DroneTypeOctoX;
            break;
        case 5:
            droneType = DroneTypeOctoPlus;
            break;
        default:
            droneType = DroneTypeQuadX;
            NSLog(@"error, unkonwn drone type");
            break;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:droneType], kDroneTypeKeyType, [_typeList objectAtIndex:rowIdx], kDroneTypeKeyName, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoticationDidSelectDroneType
                                                        object:self
                                                      userInfo:userInfo];
}

//**************UITableViewDataSource Method*******************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_typeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *cellIdentifier = @"DroneTypeCellIdentifier";
	
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
    
    NSString *description = [_typeList objectAtIndex:rowIdx];
    
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
	[typeListTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [typeListTableView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [_typeList release];
    [typeListTableView release];
    typeListTableView = nil;
    [super viewDidUnload];
}
@end
