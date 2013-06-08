//
//  ConfigurationViewController.m
//  RCTouch
//
//  Created by koupoo on 13-3-25.
//  Copyright (c) 2013年 www.hexairbot.com. All rights reserved.
//

#import "ConfigViewController.h"
#import "DroneTypeListViewController.h"
#import "EvaConfig.h"
#import "EvaCommand.h"
#import "Transmitter.h"
#import "Macros.h"
#import "MaxFlightSpeedListViewController.h"
#import "MagCalibrationMenuViewController.h"
#import "MagCalibrationViewController.h"
#import "BlockViewStyle1.h"
#import "BlockViewStyle2.h"
#import "BasicInfoManager.h"
#import <mach/mach_time.h>


#define kConfigName     @"ConfigName"
#define kConfigPageView @"ConfigPageView"

typedef enum dialog{
    dialog_rc_calibration,
    dialog_mag_calibration,
    dialog_config_write,
}dialog_t;

typedef enum{
	config_view_block_view_invalid,
    config_view_block_view_total_ui,
	config_view_block_view_max
}config_view_block_view_t;


@interface ConfigViewController (){
    NSMutableArray *configList;
    UIView *currentPageView;
    
    NSMutableDictionary *blockViewDict;
    
    //iPhone
    NSMutableArray *pageViewArray;
    NSMutableArray *pageTitleArray;
    
    int pageCount;
    
    MagCalibrationViewController *magCalibrationVC;
    NSTimer *channelUpdateTimer;
}

@property (nonatomic, retain) UIPopoverController *droneTypeListPopoverVC;
@property (nonatomic, retain) UIPopoverController *maxFlightSpeedListPopverVC;
@property (nonatomic, retain) UIPopoverController *magCalibrationMenuPopoverVC;

@end

@implementation ConfigViewController
@synthesize droneTypeListPopoverVC = _droneTypeListPopoverVC;
@synthesize maxFlightSpeedListPopverVC = _maxFlightSpeedListPopverVC;
@synthesize magCalibrationMenuPopoverVC = _magCalibrationMenuPopoverVC;
@synthesize config = _config;
@synthesize osdData = _osdData;
@synthesize isConnected = _isConnected;
@synthesize delegate = _delegate;



- (void)setConfig:(EvaConfig *)config{
    [_config release];
    _config = [config retain];
    [self updateUI];
}

- (void)osdData:(EvaOSDData *)osdData{
    [_osdData release];
    _osdData = [osdData retain];
    [self updateUI];
}

- (void)setIsConnected:(BOOL)isConnected{
    _isConnected = isConnected;
    if (isConnected) {
        isConnectedTextLabel.text = getLocalizeString(@"connected");
    }
    else{
        isConnectedTextLabel.text = getLocalizeString(@"not connected");
    }
}

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

-(void)blockTotalUI{
    CGRect blockViewPart1Frame = self.view.frame;
    blockViewPart1Frame.origin.x = 0;
    blockViewPart1Frame.origin.y = 0;
    
	BlockViewStyle1 *blockViewPart1 = [[BlockViewStyle1 alloc] initWithFrame:blockViewPart1Frame];
	blockViewPart1.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
	blockViewPart1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	BlockViewStyle2 *blockViewPart2 = [[BlockViewStyle2 alloc] initWithFrame:CGRectMake(0, 0, 150, 100)
															  indicatorTitle:getLocalizeString(@"Adjusting channels...")];
	blockViewPart2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
	|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	blockViewPart2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
	[blockViewPart2.indicatorLabel setFont:[UIFont systemFontOfSize:11]];
	[blockViewPart2.indicatorLabel setTextColor:[UIColor whiteColor]];
	blockViewPart2.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[blockViewPart2.activityIndicatorView startAnimating];
	
	blockViewPart2.center = CGPointMake(blockViewPart1.frame.size.width / 2, blockViewPart1.frame.size.height / 2);
	[blockViewPart1 addSubview:blockViewPart2];
	
	[blockViewPart2 release];
	
	UIView *blockView = blockViewPart1;
    
	[self.view addSubview:blockView];
	[blockViewDict setValue:blockView forKey:[NSString stringWithFormat:@"%d", config_view_block_view_total_ui]];
	
	[blockViewPart1 release];
}

- (void)unblockTotalUIAnimated:(NSNumber *)animated_{
    BOOL animated = [animated_ boolValue];
    
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  config_view_block_view_total_ui];
	UIView *blockView = [blockViewDict valueForKey:blockViewIdentifier];
	
	if(blockView == nil)
		return;
	
	if (animated == YES) {
		[UIView animateWithDuration:1
						 animations:^{
							 blockView.alpha = 0;
						 } completion:^(BOOL finished){
							 [blockView removeFromSuperview];
							 [blockViewDict removeObjectForKey:blockViewIdentifier];
						 }
		 ];
	}
	else {
		[blockView removeFromSuperview];
		[blockViewDict removeObjectForKey:blockViewIdentifier];
	}
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil config:(EvaConfig *)config
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        _config = [config retain];
        [self updateUI];
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
	
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if(configList == nil){
            NSDictionary *fixConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                       getLocalizeString(@"Setup"), kConfigName,
                                       fixPageView, kConfigPageView, nil];
            NSDictionary *motorConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                         getLocalizeString(@"Motor Related"), kConfigName,
                                         motroConfigPageView, kConfigPageView, nil];
            NSDictionary *rcConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                      getLocalizeString(@"Transmitter"), kConfigName,
                                      rcConfigPageView, kConfigPageView, nil];
            NSDictionary *speedControlConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                                getLocalizeString(@"Speed Setting"), kConfigName,
                                                speedControlPageView, kConfigPageView, nil];
            NSDictionary *autoPilotSystemConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   getLocalizeString(@"Stab System"), kConfigName,
                                                   autoPilotSystemPageView, kConfigPageView, nil];
            NSDictionary *plzConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                       getLocalizeString(@"PTZ"), kConfigName,
                                       ptzConfigPageView, kConfigPageView, nil];
            NSDictionary *powerConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                         getLocalizeString(@"Power"), kConfigName,
                                         powerConfigPageView, kConfigPageView, nil];
            NSDictionary *interfaceConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                             getLocalizeString(@"Interface"), kConfigName,
                                             interfaceConfigPageView, kConfigPageView, nil];
            configList = [[NSMutableArray alloc] initWithObjects:
                          fixConfig,
                          motorConfig,
                          rcConfig,
                          speedControlConfig,
                          autoPilotSystemConfig,
                          plzConfig,
                          powerConfig,
                          interfaceConfig,
                          nil];
            
        }
        
        if(currentPageView == nil){
            currentPageView = [fixPageView retain];
        }
        
        NSString *configListTableBgFile = [[NSBundle mainBundle] pathForResource:@"category_list_table_bg" ofType:@"png"];
        
        UIImage *configListTableBgImg = [[UIImage alloc] initWithContentsOfFile:configListTableBgFile];
        
        UIView *configListTableBg = [[UIImageView alloc] initWithImage:configListTableBgImg];
        [configListTableBgImg release];
        
        [configListTableView setBackgroundView:configListTableBg];
        [configListTableBg release];
        
        [configListTableView  selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        [self showConfigPageViewAtIdx:0];
    }
    else{
        //iphone
        if(pageViewArray == nil){
            pageViewArray = [[NSMutableArray alloc] initWithCapacity:7];
            pageTitleArray = [[NSMutableArray alloc] initWithCapacity:7];
            
            [pageViewArray addObject:fixPageView];
            [pageTitleArray addObject:getLocalizeString(@"Setup")];
            [pageViewArray addObject:motroConfigPageView];
            [pageTitleArray addObject:getLocalizeString(@"Motor Related")];
            [pageViewArray addObject:rcConfigPageView];
            [pageTitleArray addObject:getLocalizeString(@"Transmitter")];
            [pageViewArray addObject:speedControlPageView];
            [pageTitleArray addObject:getLocalizeString(@"Speed Setting")];
            [pageViewArray addObject:autoPilotSystemPageView];
            [pageTitleArray addObject:getLocalizeString(@"Stab System")];
            [pageViewArray addObject:ptzConfigPageView];
            [pageTitleArray addObject:getLocalizeString(@"PTZ")];
            [pageViewArray addObject:powerConfigPageView];
            [pageTitleArray addObject:getLocalizeString(@"Power")];
            [pageViewArray addObject:interfaceConfigPageView];
            [pageTitleArray addObject:getLocalizeString(@"Interface")];
            
            pageCount = pageViewArray.count;
            
            CGFloat x = 0.f;
            for (UIView *pageView in pageViewArray)
            {
                CGRect frame = pageView.frame;
                frame.origin.x = x;
                [pageView setFrame:frame];
                [configPageScrollView addSubview:pageView];
                x += pageView.frame.size.width;
            }
            [configPageScrollView  setContentSize:CGSizeMake(x, configPageScrollView.frame.size.height)];
            
            [pageControl setNumberOfPages:pageCount];
            [pageControl setCurrentPage:0];
            
        }
    }
    [self updateUI];
    [channelView setOsdData:_osdData];
    [self setIsConnected:[[BasicInfoManager sharedManager] isConnected]];
    if(blockViewDict == nil){
        blockViewDict = [[NSMutableDictionary alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//**************UITableViewDataSource Method*******************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [configList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *cellIdentifier = @"ConfigCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = 	[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:nil] autorelease];
		
		cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithWhite:0.4 alpha:1];
        cell.textLabel.shadowOffset = CGSizeMake(0, 0);
		cell.textLabel.highlightedTextColor = [UIColor blackColor];//[UIColor colorWithWhite:0.3 alpha:1];
        
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        
		cell.backgroundColor = [UIColor clearColor];
	}
	
	int configIdx = [indexPath row];
 
    NSString *configName = [[configList objectAtIndex:configIdx] valueForKey:kConfigName];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = configName;
    
	UIImage *bgImg;
	UIImageView *bgImgView;
	
	UIImage *selectedBgImg;
	UIImageView *selectedBgImgView;
    
    bgImg = [UIImage imageNamed:@"config_cell_bg.png"];
    bgImgView = [[UIImageView alloc] initWithImage:bgImg];
    
    selectedBgImg = [UIImage imageNamed:@"config_cell_selected_bg.png"];
    selectedBgImgView = [[UIImageView alloc] initWithImage:selectedBgImg];
    
	cell.backgroundView = bgImgView;
	cell.selectedBackgroundView = selectedBgImgView;
	
	[bgImgView release];
	[selectedBgImgView release];
	
	return cell;
}
//************************************************************


//****************UITableViewDelegate Method******************
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	int pageViewIdx = [indexPath row];

    [self showConfigPageViewAtIdx:pageViewIdx];
}

//************************************************************

- (void)showConfigPageViewAtIdx:(int)idx{
    [currentPageView removeFromSuperview];
    [currentPageView release];

    UIView *configPageView = [[configList objectAtIndex:idx] objectForKey:kConfigPageView];
   
    [configPageViewHolder addSubview:configPageView];
    
     currentPageView = [configPageView retain];
}

- (void)dealloc {
    [_config release];
    [_osdData release];
    
    if(_droneTypeListPopoverVC != nil){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectDroneType object:nil];
        [_droneTypeListPopoverVC dismissPopoverAnimated:NO];
        [_droneTypeListPopoverVC release];
    }
    if (_maxFlightSpeedListPopverVC != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectMaxFlightSpeed object:nil];
        [_maxFlightSpeedListPopverVC dismissPopoverAnimated:NO];
        [_maxFlightSpeedListPopverVC release];
    }
    if (_magCalibrationMenuPopoverVC != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticationDidSelectMagCalibrationMenuItem object:nil];
        [_magCalibrationMenuPopoverVC dismissPopoverAnimated:NO];
        [_magCalibrationMenuPopoverVC release];
    }
    
    [fixPageView release];
    [motroConfigPageView release];
    [rcConfigPageView release];
    [ptzConfigPageView release];
    [powerConfigPageView release];
    [configListTableView release];
    [configList release];
    [currentPageView release];
    [configPageViewHolder release];
    [backButton release];
    [configReadButton release];
    [configWriteButton release];
    [autoPilotSystemPageView release];
    [interfaceConfigPageView release];
    [droneTypeLabel release];
    [escTypeSegmentControl release];
    [rcTypeSegmentControl release];
    [maxVerticleSpeedSegmentControl release];
    [overloadControlSegmentControl release];
    [batteryCellCountSegmentControl release];
    [batterryAlertVoltageSegmentControl release];
    [speedControlPageView release];
    [rollDSlider release];
    [pitchDSlider release];
    [throttlePSlider release];
    [rollISlider release];
    [rollDTextLabel release];
    [pitchDTextLabel release];
    [throttlePTextLabel release];
    [rollITextLabel release];
    [magDeclinationTextField release];
    [ptzRollSensitivitySlider release];
    [ptzPitchSensitivitySlider release];
    [ptzRollSensitivityTextLabel release];
    [ptzPitchSensitivityTextLabel release];
    [batteryTypeTextLabel release];
    [interfaceOpacitySlider release];
    [interfaceOpacityTextLabel release];
    [throttleModeSegmentControl release];
    [maxFlightSpeedSlider release];
    [maxFlightSpeedTextLabel release];
    [ptzOutputFreqSegmentControl release];
    [channelView release];
    [flightModeTextLabel release];
    [isConnectedTextLabel release];
    [configPageScrollView release];
    [nextPageButton release];
    [previousPageButton release];
    [pageControl release];
    [pageTitleLabel release];
    [pageViewArray release];
    [pageTitleArray release];
    [mapModeSegmentControl release];
    [super dealloc];
}

- (void)viewDidUnload {
    [blockViewDict release];
    [fixPageView release];
    fixPageView = nil;
    [motroConfigPageView release];
    motroConfigPageView = nil;
    [rcConfigPageView release];
    rcConfigPageView = nil;
    [ptzConfigPageView release];
    ptzConfigPageView = nil;
    [powerConfigPageView release];
    powerConfigPageView = nil;
    [configListTableView release];
    configListTableView = nil;
    [currentPageView release];
    currentPageView = nil;
    [configPageViewHolder release];
    configPageViewHolder = nil;
    [backButton release];
    backButton = nil;
    [configReadButton release];
    configReadButton = nil;
    [configWriteButton release];
    configWriteButton = nil;
    [autoPilotSystemPageView release];
    autoPilotSystemPageView = nil;
    [interfaceConfigPageView release];
    interfaceConfigPageView = nil;
    [droneTypeLabel release];
    droneTypeLabel = nil;
    [escTypeSegmentControl release];
    escTypeSegmentControl = nil;
    [rcTypeSegmentControl release];
    rcTypeSegmentControl = nil;
    [maxVerticleSpeedSegmentControl release];
    maxVerticleSpeedSegmentControl = nil;
    [overloadControlSegmentControl release];
    overloadControlSegmentControl = nil;
    [batteryCellCountSegmentControl release];
    batteryCellCountSegmentControl = nil;
    [batterryAlertVoltageSegmentControl release];
    batterryAlertVoltageSegmentControl = nil;
    [speedControlPageView release];
    speedControlPageView = nil;
    [rollDSlider release];
    rollDSlider = nil;
    [pitchDSlider release];
    pitchDSlider = nil;
    [throttlePSlider release];
    throttlePSlider = nil;
    [rollISlider release];
    rollISlider = nil;
    [rollDTextLabel release];
    rollDTextLabel = nil;
    [pitchDTextLabel release];
    pitchDTextLabel = nil;
    [throttlePTextLabel release];
    throttlePTextLabel = nil;
    [rollITextLabel release];
    rollITextLabel = nil;
    [magDeclinationTextField release];
    magDeclinationTextField = nil;
    [ptzRollSensitivitySlider release];
    ptzRollSensitivitySlider = nil;
    [ptzPitchSensitivitySlider release];
    ptzPitchSensitivitySlider = nil;
    [ptzRollSensitivityTextLabel release];
    ptzRollSensitivityTextLabel = nil;
    [ptzPitchSensitivityTextLabel release];
    ptzPitchSensitivityTextLabel = nil;
    [batteryTypeTextLabel release];
    batteryTypeTextLabel = nil;
    [interfaceOpacitySlider release];
    interfaceOpacitySlider = nil;
    [interfaceOpacityTextLabel release];
    interfaceOpacityTextLabel = nil;
    [throttleModeSegmentControl release];
    throttleModeSegmentControl = nil;
    [maxFlightSpeedSlider release];
    maxFlightSpeedSlider = nil;
    [maxFlightSpeedTextLabel release];
    maxFlightSpeedTextLabel = nil;
    [ptzOutputFreqSegmentControl release];
    ptzOutputFreqSegmentControl = nil;
    [channelView release];
    channelView = nil;
    [flightModeTextLabel release];
    flightModeTextLabel = nil;
    [isConnectedTextLabel release];
    isConnectedTextLabel = nil;
    [configPageScrollView release];
    configPageScrollView = nil;
    [nextPageButton release];
    nextPageButton = nil;
    [previousPageButton release];
    previousPageButton = nil;
    [pageControl release];
    pageControl = nil;
    [pageTitleLabel release];
    pageTitleLabel = nil;
    [magCalibrationVC release];
    magCalibrationVC = nil;
    [mapModeSegmentControl release];
    mapModeSegmentControl = nil;
    [super viewDidUnload];
}

- (IBAction)buttonDidTouchUpInside:(id)sender {
    if(sender == backButton){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissConfigView object:self userInfo:nil];
    }
}

- (void)handleDroneTypeDidSelect:(NSNotification *)notification{
    drone_type_t type = [[[notification userInfo] valueForKey:kDroneTypeKeyType] intValue];
    _config.droneType = type;
    NSString *typeName = [[notification userInfo] valueForKey:kDroneTypeKeyName];
    droneTypeLabel.text = typeName;
    
    [_config save];
};

- (void)handleMaxFlightSpeedDidSelect:(NSNotification *)notification{
    int maxSpeed = [[[notification userInfo] valueForKey:kMaxFlightKeySpeed] intValue];
    float realMaxSpeed = 0;

    switch (maxSpeed) {
        case 90:
            realMaxSpeed = 3.6;
            break;
        case 120:
            realMaxSpeed = 4.8;
            break;
        case 150:
            realMaxSpeed= 6.0;
            break;
        case 200:
            realMaxSpeed = 8.0;
            break;
        case 255:
            realMaxSpeed = 10.2;
            break;
    }
    
    maxFlightSpeedSlider.value = realMaxSpeed;
    maxFlightSpeedTextLabel.text = [NSString stringWithFormat:@"%.1fm/s", realMaxSpeed];
    _config.maxFlightSpeed = maxSpeed;
}

- (void)closeMagCalibrationView{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        [magCalibrationVC.view.superview removeFromSuperview];
        [magCalibrationVC release];
        magCalibrationVC = nil;
    }
}

- (void)showMagCalibrationView{
    MagCalibrationViewController *_magCalibrationVC = [[MagCalibrationViewController alloc]  initWithNibName:@"MagCalibrationViewController" bundle:nil config:_config];
    CGRect bounds = _magCalibrationVC.view.frame;
    
    _magCalibrationVC.navBar.topItem.rightBarButtonItem.action = @selector(closeMagCalibrationView);
    _magCalibrationVC.navBar.topItem.rightBarButtonItem.target = self;
    _magCalibrationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    _magCalibrationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [_magCalibrationVC showView:mag_calibration_view_h];
    
    [self presentModalViewController:_magCalibrationVC animated:YES];
    
    self.modalViewController.view.superview.bounds = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    
    [_magCalibrationVC release];
}

- (void)handleMagCalibrationMenuItemDidSelect:(NSNotification *)notification{
    [_magCalibrationMenuPopoverVC dismissPopoverAnimated:NO];
     mag_calibration_menu_item_t menuItem = [[[notification userInfo] valueForKey:kMagCalibrationMenuKeyItem] intValue];
    
    MagCalibrationViewController *_magCalibrationVC = [[MagCalibrationViewController alloc]  initWithNibName:@"MagCalibrationViewController" bundle:nil config:_config];
    CGRect bounds = _magCalibrationVC.view.frame;

    _magCalibrationVC.navBar.topItem.rightBarButtonItem.action = @selector(closeMagCalibrationView);
    _magCalibrationVC.navBar.topItem.rightBarButtonItem.target = self;
    _magCalibrationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    _magCalibrationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if (menuItem == mag_calibration_menu_item_state) {
        [_magCalibrationVC showView:mag_calibration_view_state];
    }
    else{
        [_magCalibrationVC showView:mag_calibration_view_h];
    }
    
    [self presentModalViewController:_magCalibrationVC animated:YES];
    
    self.modalViewController.view.superview.bounds = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    
    [_magCalibrationVC release];
}

- (IBAction)choseDroneType:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (_droneTypeListPopoverVC == nil) {
            NSArray *typeList = [NSArray arrayWithObjects:getLocalizeString(@"Quad X"), getLocalizeString(@"Quad +"), getLocalizeString(@"Hex X"), getLocalizeString(@"Hex +"), getLocalizeString(@"Oct X"), getLocalizeString(@"Oct +"), nil];
            
            DroneTypeListViewController *droneTypeListVC = [[DroneTypeListViewController alloc] initWithTypeList:typeList];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDroneTypeDidSelect:) name:kNoticationDidSelectDroneType object:nil];
            
            _droneTypeListPopoverVC = [[UIPopoverController alloc] initWithContentViewController:droneTypeListVC];
            [droneTypeListVC release];
        }
        
        UIButton *droneTypeChoseBtn = (UIButton *)sender;
        
        CGRect popoverRect;
        popoverRect.origin.x = droneTypeChoseBtn.frame.size.width - 15;
        popoverRect.origin.y = droneTypeChoseBtn.frame.size.height / 2.0;
        popoverRect.size.width = popoverRect.size.height = 1;
        _droneTypeListPopoverVC.popoverContentSize = _droneTypeListPopoverVC.contentViewController.view.frame.size;
        [_droneTypeListPopoverVC presentPopoverFromRect:popoverRect
                                                 inView:droneTypeChoseBtn
                               permittedArrowDirections:UIPopoverArrowDirectionLeft
                                               animated:YES];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"飞行器类型"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"X四轴",@"+四轴", @"X六轴", @"+六轴", @"X八轴", @"+八轴", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

- (void)updateDroneTypeLabel{
    switch (_config.droneType) {
        case DroneTypeQuadX:
            droneTypeLabel.text = getLocalizeString(@"Quad X");
            break;
        case DroneTypeQuadPlus:
            droneTypeLabel.text = getLocalizeString(@"Quad +");
            break;
        case DroneTypeHexX:
            droneTypeLabel.text = getLocalizeString(@"Hex X");
            break;
        case DroneTypeHexPlus:
            droneTypeLabel.text = getLocalizeString(@"Hex +");
            break;
        case DroneTypeOctoX:
            droneTypeLabel.text = getLocalizeString(@"Oct X");
            break;
        case DroneTypeOctoPlus:
            droneTypeLabel.text = getLocalizeString(@"Oct +");
            break;
        default:
            _config.droneType =DroneTypeQuadX;
            droneTypeLabel.text = getLocalizeString(@"Quad X");
            NSLog(@"error, unkonwn drone type.");
            break;
    }
}

- (void)updateMaxFlightSpeed{
    float maxFlightSpeed = 0;
    
    switch (_config.maxFlightSpeed) {
        case 90:
            maxFlightSpeed = 3.6;
            break;
        case 120:
            maxFlightSpeed = 4.8;
            break;
        case 150:
            maxFlightSpeed = 6.0;
            break;
        case 200:
            maxFlightSpeed = 8.0;
            break;
        case 255:
            maxFlightSpeed = 10.2;
            break;
        default:
            maxFlightSpeed = _config.maxFlightSpeed / 25.0;
            break;
    }
    
    maxFlightSpeedSlider.value = maxFlightSpeed;
    maxFlightSpeedTextLabel.text = [NSString stringWithFormat:@"%.1fm/s", maxFlightSpeed];
}

- (void)updateChannelView{
    [channelView setNeedsDisplay];
}

- (void)updateFilghtModeTextFiled{
    NSString *flightModeStr = nil;
        
    switch (_osdData.flightMode) {
        case FlightModeManual:
            flightModeStr = getLocalizeString(@"Manual");
            break;
        case FlightModeAutoHovering :
            flightModeStr = getLocalizeString(@"GPS Hover");
            break;
        case FlightModeAutoNavigation:
            flightModeStr = getLocalizeString(@"Auto Navigation");
            break;
        case FlightModeCirclePosition:
            flightModeStr = getLocalizeString(@"Circle");
            break;
        case FlightModeRealtimeWaypoint:
            flightModeStr = getLocalizeString(@"Target");
            break;
        case FlightModeAutoWaypointCircling:
            flightModeStr = getLocalizeString(@"Auto Waypoint Circling");
            break;
        case FlightModeSemiAutomatic:
            flightModeStr = getLocalizeString(@"Semi Auto");
            break;
        case FlightModeSettingsState:
            flightModeStr = getLocalizeString(@"Setting");
            break;
        case FlightModeZeroGyro:
            flightModeStr = getLocalizeString(@"Zero Gyro");
            break;
        case FlightModeAltitudeError:
            flightModeStr = getLocalizeString(@"Alt Error");
            break;
        case FlightModeAirSpeedError:
            flightModeStr = getLocalizeString(@"Air Speed Error");
            break;
        case FlightModeBackLanding:
            flightModeStr = getLocalizeString(@"Landing");
            break;
        case FlightModeMunualSetAltitude:
            flightModeStr = getLocalizeString(@"Alt Hold");
            break;
        default:
            flightModeStr = getLocalizeString(@"Unknown");
            break;
    }
    
    flightModeTextLabel.text = flightModeStr;
}

- (void)updateUI{
    [self updateDroneTypeLabel];
    escTypeSegmentControl.selectedSegmentIndex = _config.escType;
    
    switch (_config.rcType) {
        case RcTypeNormal:
            rcTypeSegmentControl.selectedSegmentIndex = 0;
            break;
        case RcTypePpm:
            rcTypeSegmentControl.selectedSegmentIndex = 1;
            break;
        case RcTypeSbus:
            rcTypeSegmentControl.selectedSegmentIndex = 2;
            break;
        case RcTypeAdaptive:
            rcTypeSegmentControl.selectedSegmentIndex = 3;
            break;
        default:
            NSLog(@"error, unknown rc type.");
            _config.rcType = RcTypeNormal;
            rcTypeSegmentControl.selectedSegmentIndex = 0;
            break;
    }
    
    [self updateMaxFlightSpeed];
    
    switch (_config.maxVerticleSpeed) {
        case MaxVerticleSpeed2:
            maxVerticleSpeedSegmentControl.selectedSegmentIndex = 0;
            break;
        case MaxVerticleSpeed4:
            maxVerticleSpeedSegmentControl.selectedSegmentIndex = 1;
            break;
        case MaxVerticleSpeed5:
            maxVerticleSpeedSegmentControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"error, unknown max verticle speed:%d", _config.maxVerticleSpeed);
            _config.maxVerticleSpeed = MaxVerticleSpeed2;
            maxVerticleSpeedSegmentControl.selectedSegmentIndex = 0;
            break;
    }
    
    switch (_config.overloadControlType) {
        case OverloadControlTypeSoft:
            overloadControlSegmentControl.selectedSegmentIndex = 0;
            break;
        case OverloadControlTypeNormal:
            overloadControlSegmentControl.selectedSegmentIndex = 1;
            break;
        case OverloadControlTypeHard:
            overloadControlSegmentControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"error, unknown overload control type.");
            _config.overloadControlType = OverloadControlTypeSoft;
            overloadControlSegmentControl.selectedSegmentIndex = 0;
            break;
    }
    
    rollDTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.rollD];
    rollDSlider.value = _config.rollD / 100.0;
    
    pitchDTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.pitchD];
    pitchDSlider.value = _config.pitchD / 100.0;
    
    throttlePTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.throttleP];
    throttlePSlider.value = _config.throttleP / 100.0;
    
    rollITextLabel.text = [NSString stringWithFormat:@"%d%%", _config.rollI];
    rollISlider.value = _config.rollI / 100.0;
    
    ptzRollSensitivityTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.ptzRollSensitivity];
    ptzRollSensitivitySlider.value = _config.ptzRollSensitivity / 100.0;
    
    ptzPitchSensitivityTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.ptzPitchSensitivity];
    ptzPitchSensitivitySlider.value = _config.ptzPitchSensitivity / 100.0;
    
    magDeclinationTextField.text = [NSString stringWithFormat:@"%.1f", _config.magDeclination];
    
    switch (_config.ptzOutputFreq) {
        case PtzOutputFreq50:
            ptzOutputFreqSegmentControl.selectedSegmentIndex = 0;
            break;
        case PtzOutputFreq250:
            ptzOutputFreqSegmentControl.selectedSegmentIndex = 1;
            break;
        case PtzOutputFreq333:
            ptzOutputFreqSegmentControl.selectedSegmentIndex = 2;
            break;
        case PtzOutputFreqOther:
            ptzOutputFreqSegmentControl.selectedSegmentIndex = 3;
            break;
        default:
            NSLog(@"error, unknown ptz output freq.");
            break;
    }
    
    switch (_config.batteryCellCount) {
        case 3:
            batteryCellCountSegmentControl.selectedSegmentIndex = 0;
            break;
        case 4:
            batteryCellCountSegmentControl.selectedSegmentIndex = 1;
            break;
        case 5:
            batteryCellCountSegmentControl.selectedSegmentIndex = 2;
            break;
        case 6:
            batteryCellCountSegmentControl.selectedSegmentIndex = 3;
            break;
        default:
            NSLog(@"error, unknown cell count.");
            _config.batteryCellCount = 3;
            batteryCellCountSegmentControl.selectedSegmentIndex = 0;
            break;
    }
    
    switch (_config.batterryAlertVoltage) {
        case BatterryAlertVoltage3_5_5:
            batterryAlertVoltageSegmentControl.selectedSegmentIndex = 0;
            break;
        case BatterryAlertVoltage3_6_0:
            batterryAlertVoltageSegmentControl.selectedSegmentIndex = 1;
            break;
        case BatterryAlertVoltage3_6_5:
            batterryAlertVoltageSegmentControl.selectedSegmentIndex = 2;
            break;
        case BatterryAlertVoltage3_7_0:
            batterryAlertVoltageSegmentControl.selectedSegmentIndex = 3;
            break;
        default:
            NSLog(@"error, unknown batterry alert voltage.");
            _config.batterryAlertVoltage = BatterryAlertVoltage3_7_0;
            batterryAlertVoltageSegmentControl.selectedSegmentIndex = 3;
            break;
    }
    
    interfaceOpacitySlider.value = _config.interfaceOpacity;
    interfaceOpacityTextLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_config.interfaceOpacity * 100)];
    
    if ( _config.isLeftHandMode) {
        throttleModeSegmentControl.selectedSegmentIndex = 0;
    }
    else{
        throttleModeSegmentControl.selectedSegmentIndex = 1;
    }
    
    switch (_config.mapMode) {
        case map_mode_standard:
            mapModeSegmentControl.selectedSegmentIndex = 0;
            break;
        case map_mode_satellite:
            mapModeSegmentControl.selectedSegmentIndex = 1;
            break;
        case map_mode_hybrid:
            mapModeSegmentControl.selectedSegmentIndex = 2;
            break;
        default:
            //mapModeSegmentControl.selectedSegmentIndex = 2;
            break;
    }
}

- (IBAction)readConfig:(id)sender {
    NSData *setupEnterCommand = [EvaCommand getSetupEnterCommand];
    [[Transmitter sharedTransmitter] transmmitData:setupEnterCommand];
    
    NSData *configReadcommand = [EvaCommand getConfigReadCommand];
    [[Transmitter sharedTransmitter] transmmitData:configReadcommand];
}

- (IBAction)writeConfig:(id)sender {
    [self showAlertViewWithTitle:getLocalizeString(@"Save")
                         message:getLocalizeString(@"Save current config?")
               cancelButtonTitle:getLocalizeString(@"No")
                   okButtonTitle:getLocalizeString(@"Yes")
                             tag:dialog_config_write];

}

- (IBAction)showMagCalibrationMenu:(id)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self showMagCalibrationView];
    }
    else{
        [self showAlertViewWithTitle:@"磁感计校准"
                             message:@"进行磁感计校准？"
                   cancelButtonTitle:@"取消"
                       okButtonTitle:@"校准"
                                 tag:dialog_mag_calibration];
    }
}

- (IBAction)choseMaxFlightSpeed:(id)sender {
    if (_maxFlightSpeedListPopverVC == nil) {
        NSArray *list = [NSArray arrayWithObjects:@"3.6m/s",@"4.8m/s", @"6.0m/s", @"8.0m/s", @"10.2m/s", nil];
        
        MaxFlightSpeedListViewController *listVC = [[MaxFlightSpeedListViewController alloc] initWithList:list];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMaxFlightSpeedDidSelect:) name:kNoticationDidSelectMaxFlightSpeed object:nil];
        
        _maxFlightSpeedListPopverVC= [[UIPopoverController alloc] initWithContentViewController:listVC];
        [listVC release];
    }
    
    UIButton *choseBtn = (UIButton *)sender;
    
    CGRect popoverRect;
    popoverRect.origin.x = choseBtn.frame.size.width - 15;
    popoverRect.origin.y = choseBtn.frame.size.height / 2.0;
    popoverRect.size.width = popoverRect.size.height = 1;
    _maxFlightSpeedListPopverVC.popoverContentSize = _maxFlightSpeedListPopverVC.contentViewController.view.frame.size;
    [_maxFlightSpeedListPopverVC presentPopoverFromRect:popoverRect
                                            inView:choseBtn
                          permittedArrowDirections:UIPopoverArrowDirectionLeft
                                          animated:YES];
}

- (IBAction)calibrateRc:(id)sender { 
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:getLocalizeString(@"Channel Adjustment")
                                                        message:getLocalizeString(@"Tap the 'Adjust' button, then put the channels to max and min value during 5 seconds.")
                                                       delegate:self
                                              cancelButtonTitle:getLocalizeString(@"Cancel")
                                              otherButtonTitles:getLocalizeString(@"Adjust"), nil];
    alertView.tag = dialog_rc_calibration;
    [alertView show];
    [alertView release];
}

- (IBAction)segmentControlValueDidChanged:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    
    if (segmentControl == escTypeSegmentControl) {
        switch (escTypeSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.escType = EscTypeNormal;
                break;
            case 1:
                _config.escType = EscTypeNarrow;
                break;
            case 2:
                _config.escType = EscTypeIic;
                break;
            case 3:
                _config.escType = EscTypeOther;
        }
    }
    else if(segmentControl == rcTypeSegmentControl){
        switch (rcTypeSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.rcType = RcTypeNormal;
                break;
            case 1:
                _config.rcType = RcTypePpm;
                break;
            case 2:
                _config.rcType = RcTypeSbus;
                break;
            case 3:
                _config.rcType = RcTypeAdaptive;
                break;
        }
    }
    else if(segmentControl == maxVerticleSpeedSegmentControl){
        switch (maxVerticleSpeedSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.maxVerticleSpeed = MaxVerticleSpeed2;
                break;
            case 1:
                _config.maxVerticleSpeed = MaxVerticleSpeed4;
                break;
            case 2:
                _config.maxVerticleSpeed = MaxVerticleSpeed5;
                break;
        }
    }
    else if(segmentControl == overloadControlSegmentControl){
        switch (overloadControlSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.overloadControlType = OverloadControlTypeSoft;
                break;
            case 1:
                _config.overloadControlType = OverloadControlTypeNormal;
                break;
            case 2:
                _config.overloadControlType = OverloadControlTypeHard;
                break;
        }
    }
    else if(segmentControl == ptzOutputFreqSegmentControl){
        switch (ptzOutputFreqSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.ptzOutputFreq = PtzOutputFreq50;
                break;
            case 1:
                _config.ptzOutputFreq = PtzOutputFreq250;
                break;
            case 2:
                _config.ptzOutputFreq = PtzOutputFreq333;
                break;
            case 3:
                _config.ptzOutputFreq = PtzOutputFreqOther;
                break;
        }
    }
    else if(segmentControl == batteryCellCountSegmentControl){
        switch (batteryCellCountSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.batteryCellCount = 3;
                break;
            case 1:
                _config.batteryCellCount = 4;
                break;
            case 2:
                _config.batteryCellCount = 5;
                break;
            case 3:
                _config.batteryCellCount = 6;
                break;
        }
    }
    else if(segmentControl == batterryAlertVoltageSegmentControl){
        switch (batterryAlertVoltageSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.batterryAlertVoltage = BatterryAlertVoltage3_5_5;
                break;
            case 1:
                _config.batterryAlertVoltage = BatterryAlertVoltage3_6_0;
                break;
            case 2:
                _config.batterryAlertVoltage = BatterryAlertVoltage3_6_5;
                break;
            case 3:
                _config.batterryAlertVoltage = BatterryAlertVoltage3_7_0;
                break;
        }
    }
    else if(segmentControl == throttleModeSegmentControl){
        switch (throttleModeSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.isLeftHandMode = YES;
                break;
            case 1:
                _config.isLeftHandMode = NO;
                break;
        }
        if ([_delegate respondsToSelector:@selector(configViewController:leftHandedValueDidChange:)]) {
            [_delegate configViewController:self leftHandedValueDidChange:_config.isLeftHandMode];
        }
    }
    else if(segmentControl == mapModeSegmentControl){
        switch (mapModeSegmentControl.selectedSegmentIndex) {
            case 0:
                _config.mapMode = map_mode_standard;
                break;
            case 1:
                _config.mapMode = map_mode_satellite;
                break;
            case 2:
                _config.mapMode = map_mode_hybrid;
                break;
        }
        if ([_delegate respondsToSelector:@selector(configViewController:mapModeDidChange:)]) {
            [_delegate configViewController:self mapModeDidChange:_config.mapMode];
        }
    }
    
    [_config save];
}

- (IBAction)sliderDidRelease:(id)sender {
    [_config save];
    
    if (sender == interfaceOpacitySlider) {
        if([_delegate respondsToSelector:@selector(configViewController:interfaceOpacityValueDidChange:)]){
            [_delegate configViewController:self interfaceOpacityValueDidChange:_config.interfaceOpacity];
        }
    }
}

- (IBAction)sliderValueDidChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    
    if(slider == rollDSlider){
        _config.rollD = (int)(rollDSlider.value * 100);
        rollDTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.rollD];
    }
    else if(slider == pitchDSlider){
        _config.pitchD = (int)(pitchDSlider.value * 100);
        pitchDTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.pitchD];
    }
    else if(slider == rollISlider){
        _config.rollI = (int)(rollISlider.value * 100);
        rollITextLabel.text = [NSString stringWithFormat:@"%d%%", _config.rollI];
    }
    else if(slider == throttlePSlider){
        _config.throttleP = (int)(throttlePSlider.value * 100);
        throttlePTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.throttleP];
    }
    else if(slider == maxFlightSpeedSlider){
        _config.maxFlightSpeed = (int)(25 * maxFlightSpeedSlider.value);
        maxFlightSpeedTextLabel.text = [NSString stringWithFormat:@"%.1fm/s", maxFlightSpeedSlider.value];
    }
    else if(slider == ptzRollSensitivitySlider){
        _config.ptzRollSensitivity = (int)(ptzRollSensitivitySlider.value * 100);
        ptzRollSensitivityTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.ptzRollSensitivity];
    }
    else if(slider == ptzPitchSensitivitySlider){
        _config.ptzPitchSensitivity = (int)(ptzPitchSensitivitySlider.value * 100);
        ptzPitchSensitivityTextLabel.text = [NSString stringWithFormat:@"%d%%", _config.ptzPitchSensitivity];
    }
    else if(slider == interfaceOpacitySlider){
        _config.interfaceOpacity = interfaceOpacitySlider.value;
        interfaceOpacityTextLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_config.interfaceOpacity * 100)];
    }
}

//iphone
- (IBAction)previousPage:(id)sender {
    [self showPreviousPageView];
}

//iphone
- (IBAction)nextPage:(id)sender {
    [self showNextPageView];
}

- (void)transmmitSimpleCommand:(eva_simple_command_t)cmd{
    NSData *cmdData = [EvaCommand getSimpleCommand:cmd];
    [[Transmitter sharedTransmitter] transmmitData:cmdData];
}

#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == dialog_rc_calibration) {
            [self transmmitSimpleCommand:eva_command_rc_calibrate];
            [self blockTotalUI];
            
            NSNumber *animated = [[NSNumber alloc] initWithBool:NO];
            [self performSelector:@selector(unblockTotalUIAnimated:) withObject:animated afterDelay:5];
            [animated release];
        }
        else if(alertView.tag == dialog_config_write){
            EvaConfig *config = [[Transmitter sharedTransmitter] config];
            
            config.magDeclination = [magDeclinationTextField.text floatValue];
            
            NSData *configWriteCommand = [EvaCommand getConfigWriteCommand:config];
            
            [[Transmitter sharedTransmitter] transmmitData:configWriteCommand];
            NSData *setupQuitCommand = [EvaCommand getSetupQuitCommand];
            [[Transmitter sharedTransmitter] transmmitData:setupQuitCommand];
        }
        else if(alertView.tag == dialog_mag_calibration){  //iPhone
            magCalibrationVC = [[MagCalibrationViewController alloc]  initWithNibName:@"MagCalibrationViewController" bundle:nil config:_config];
            [magCalibrationVC view];
            magCalibrationVC.navBar.topItem.rightBarButtonItem.action = @selector(closeMagCalibrationView);
            magCalibrationVC.navBar.topItem.rightBarButtonItem.target = self;
            [magCalibrationVC showView:mag_calibration_view_h];
            
            UIView *blockView = [[UIView alloc] initWithFrame:self.view.frame];
            
            [blockView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
            
            magCalibrationVC.view.center = CGPointMake(blockView.bounds.size.width / 2.0, blockView.bounds.size.height / 2.0);
            [blockView addSubview:magCalibrationVC.view];
            
            [self.view addSubview:blockView];
            
            [blockView release];
        }
    }
}

#pragma mark UIAlertViewDelegate Methods end

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle tag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:okButtonTitle, nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

//iPhone
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
	int currentPage = (int) (configPageScrollView.contentOffset.x + .5f * configPageScrollView.frame.size.width) / configPageScrollView.frame.size.width;
    
    if (currentPage == 0)
    {
        [previousPageButton setHidden:YES];
        [nextPageButton setHidden:NO];
    }
    else if (currentPage == (pageCount - 1))
    {
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:YES];
    }
    else if (currentPage >= pageCount)
    {
        currentPage = pageCount - 1;
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:YES];
    }
    else
    {
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:NO];
    }
    
    [pageControl setCurrentPage:currentPage];
    [pageTitleLabel setText:[pageTitleArray objectAtIndex:currentPage]];
}

//iphone
- (void)showPreviousPageView{
    int nextPage = ((int) (configPageScrollView.contentOffset.x + .5f * configPageScrollView.frame.size.width) / configPageScrollView.frame.size.width) - 1;
    if (0 > nextPage)
        nextPage = 0;
    CGFloat nextOffset = nextPage * configPageScrollView.frame.size.width;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [configPageScrollView setContentOffset:CGPointMake(nextOffset, 0.f) animated:NO];
    [UIView commitAnimations];
}

//iphone
- (void)showNextPageView{
    int nextPage = ((int) (configPageScrollView.contentOffset.x + .5f * configPageScrollView.frame.size.width) / configPageScrollView.frame.size.width) + 1;
    if (pageCount <= nextPage)
        nextPage = pageCount - 1;
    CGFloat nextOffset = nextPage *configPageScrollView.frame.size.width;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [configPageScrollView setContentOffset:CGPointMake(nextOffset, 0.f) animated:NO];
    [UIView commitAnimations];
}


//iPhone
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            _config.droneType = DroneTypeQuadX;
            droneTypeLabel.text = getLocalizeString(@"Quad X");
            break;
        case 1:
            _config.droneType = DroneTypeQuadPlus;
            droneTypeLabel.text = getLocalizeString(@"Quad +");
            break;
        case 2:
            _config.droneType = DroneTypeHexX;
            droneTypeLabel.text = getLocalizeString(@"Hex X");
            break;
        case 3:
            _config.droneType = DroneTypeHexPlus;
            droneTypeLabel.text = getLocalizeString(@"Hex +");
            break;
        case 4:
            _config.droneType = DroneTypeOctoX;
            droneTypeLabel.text = getLocalizeString(@"Oct X");
            break;
        case 5:
            _config.droneType = DroneTypeQuadPlus;
            droneTypeLabel.text = getLocalizeString(@"Oct +");
            break;
        default:
            break;
    }
}
@end
