//
//  AirlineListViewController.m
//  RCTouch
//
//  Created by koupoo on 13-4-10.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "AirlineListViewController.h"
#import "EvaAirlineFile.h"
#import "Macros.h"

@interface AirlineListViewController (){
    int selectedAirlineIdx;
}

@end

@implementation AirlineListViewController
@synthesize airlineList = _airlineList;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)shouldAutorotate{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedAirlineIdx = [indexPath row];
    
    NSString *airlineFileName = [_airlineList objectAtIndex:selectedAirlineIdx];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:getLocalizeString(@"Airline")
                                                        message:[NSString stringWithFormat:getLocalizeString(@"How do you want to handle airline '%@'?"), airlineFileName]
                                                       delegate:self
                                              cancelButtonTitle:getLocalizeString(@"Cancel")
                                              otherButtonTitles:getLocalizeString(@"Delete Airline"), getLocalizeString(@"Open Airline"), nil];
    [alertView show];
    [alertView release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_airlineList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *cellIdentifier = @"MaxFlightSpeedCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = 	[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:nil] autorelease];
		
		cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithWhite:0.4 alpha:1];
        cell.textLabel.shadowOffset = CGSizeMake(0, 0);
		cell.textLabel.highlightedTextColor = [UIColor blackColor];//[UIColor colorWithWhite:0.3 alpha:1];
        
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.8];
	}
	
	int rowIdx = [indexPath row];
    
    NSString *airlineFileName = [_airlineList objectAtIndex:rowIdx];
    
    float fontSize = 14;
    
    UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:fontSize];
    
    cell.textLabel.font = font;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = airlineFileName;
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil airlineList:(NSArray *)airlineList{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _airlineList = [[NSMutableArray alloc] initWithArray:airlineList];
    }
    return self;
}

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [listTableView release];
    [_navBar release];
    [_airlineList release];
    [super dealloc];
}
- (void)viewDidUnload {
    [listTableView release];
    listTableView = nil;
    [self setNavBar:nil];
    [super viewDidUnload];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { //删除航线
        NSString *airlineFileName = [_airlineList objectAtIndex:selectedAirlineIdx];

        [EvaAirlineFile remove:airlineFileName];
        [_airlineList removeObject:airlineFileName];
        [listTableView reloadData];
    }
    else if(buttonIndex == 2){ //打开航线
        NSString *airlineFileName = [_airlineList objectAtIndex:selectedAirlineIdx];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:airlineFileName, kAirlineKeyFileName, nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoticationAirlineOpen                                                                                object:self
                                                          userInfo:userInfo];
    }
}

@end
