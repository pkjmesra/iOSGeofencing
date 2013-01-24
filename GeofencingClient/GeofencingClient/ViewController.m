/**
 Copyright (c) 2011, Praveen K Jha, Research2Development Inc.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development Inc. nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE."
 **/
//
//  ViewController.m
//  iOSGeofencingClient
//
//  Created by Rajesh Dongre on 08/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "GFMenuContainerView.h"
#import "GFGeoFenceView.h"
//#import "MySlavesViewController.h"
#import "TrackingViewController.h"
#import "ARHomeViewController.h"
#import "GFMapViewController.h"
#import "LocationService.h"
#import "SBJsonParser.h"
#import "RoutesViewController.h"
#import "HelpViewController.h"
#import "GLSpeedViewController.h"
#import "Constants.h"
#import "SettingsViewController.h"


@implementation ViewController

@synthesize circleView = m_pCircleView;
@synthesize backgroundView = m_pBackgroundView;
@synthesize bottomView = m_bottomView;
@synthesize currentSpeed = m_pCurrentSpeed;
@synthesize avgSpeed = m_pAvgSpeed;
@synthesize menuView = _menuView;
@synthesize geoFenceView = _geoFenceView;
@synthesize locManager = m_pLocManager;
@synthesize monitoringBtn = m_pMonitoringBtn;

@synthesize needleImageView;
@synthesize speedometerCurrentValue;
@synthesize prevAngleFactor;
@synthesize angle;
@synthesize speedometer_Timer;
@synthesize speedometerReading;
@synthesize maxVal;
@synthesize timer;
@synthesize currentlyMonitoredSlave;
@synthesize receivedData;
@synthesize myMasterId;

@synthesize ballImage;
@synthesize deviceSpeed;
@synthesize view25, view50, view75;

@synthesize hideMenuTimer;

#define kRequiredAccuracy   500.0 //meters
#define kMaxAge             10.0 //seconds

#define OVERLAY_MENU_WIDTH  200

/// Time delay to close menu.
#define MENU_DISMISS_TIME_INTERVAL 3

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _lastLocation =nil;
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    [self.locManager startUpdatingLocation];
    
    self.receivedData = [[NSMutableData alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    self.menuView = [[GFMenuContainerView alloc]
                     initWithFrame:CGRectMake(- (OVERLAY_MENU_WIDTH),
                                              0.0f,
                                              OVERLAY_MENU_WIDTH,
                                              480.0f)];
    self.menuView.delegate = self;
    [self.view addSubview:self.menuView];
    
    self.geoFenceView = [[GFMapViewController alloc] init];
    NSLog(@"current location: %@", self.locManager.location);
    self.geoFenceView.currentLocation = self.locManager.location;
    [self.view addSubview:self.geoFenceView.view];
    [self.view bringSubviewToFront:self.menuView];

    [self.navigationController setNavigationBarHidden:YES];
    self.circleView.layer.cornerRadius = 20.0f;
    //self.circleView.backgroundColor = [UIColor clearColor];
    self.circleView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.circleView.layer.borderWidth = 1.0;
    self.circleView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.backgroundView.layer.borderWidth = 1.0;
    self.backgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.bottomView.layer.borderWidth = 1.0;
    self.bottomView.layer.borderColor = [[UIColor blackColor] CGColor];

    self.avgSpeed.text = [NSString stringWithFormat:@"40.0 km/h"];
    
    ballImage = [[UIImage alloc] init];
    ballImage = [UIImage imageNamed:@"Ball.png"];
	[NSTimer scheduledTimerWithTimeInterval:(0.30) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    self.view25 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 110.0, 30.0)];
    //[view25 setBackgroundColor:[UIColor colorWithRed:0.0 green:255.0 blue:0.0 alpha:1.0]];
    view25.layer.masksToBounds = YES;
    [self.circleView addSubview:self.view25];
    
    self.view50 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 50.0, 110.0, 60.0)];
    //[view50 setBackgroundColor:[UIColor colorWithRed:255.0 green:140.0 blue:0.0 alpha:0.5]];
    view50.layer.masksToBounds = YES;
    [self.circleView addSubview:self.view50];

    self.view75 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, 110.0, 90.0)];
    //[view75 setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:1.0]];
    view75.layer.masksToBounds = YES;
    [self.circleView addSubview:self.view75];
    [self.view bringSubviewToFront:self.backgroundView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.circleView];
    
    //[self startReadingLocation];    
    
    // Hide Buttons
    [self.backgroundView setHidden:YES];
    [self.circleView setHidden:YES];
    //[self.bottomView setHidden:YES];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Hide menu after time offset when it is displayed onscreen.
    // Show the menu initially, for few seconds.
    if (self.menuView.frame.origin.x < 0) {
        [self.menuView menuShowHideAction];
        
        // On launch, hide menu after some time offset.
        self.hideMenuTimer = [NSTimer
                              scheduledTimerWithTimeInterval:MENU_DISMISS_TIME_INTERVAL
                              target:self.menuView
                              selector:@selector(menuShowHideAction)
                              userInfo:nil
                              repeats:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    [m_pMonitoringBtn release];
    [m_pCircleView release];
    [m_pBackgroundView release];
    [m_pCurrentSpeed release];
    [m_pAvgSpeed release];
    [view25 release];
    [view50 release];
    [view75 release];
    [m_pLocManager release];
    [_menuView release];
    [geoFenceView release];
    [view25 release];
    [view50 release];
    [view75 release];
    [receivedData release];
    [super dealloc];
}

#pragma mark - 
#pragma mark BottomView Methods
/**
 Called when user tap on slave button from bottom view  HelpViewController
 */
-(IBAction)slavesButtonTapped:(id)sender
{
//    MySlavesViewController *slavesController = [[MySlavesViewController alloc] initWithNibName:@"MySlavesViewController" bundle:nil];
//    [self presentModalViewController:slavesController animated:YES];
    TrackingViewController *trackingController = [[TrackingViewController alloc] initWithNibName:@"TrackingViewController" bundle:nil];
    trackingController.currentLocation = self.locManager.location;
    trackingController.delegate = self;
    [self presentModalViewController:trackingController animated:YES];
}

/*!
 @method     helpButtonTapped:
 @abstract   Action for Help/Info button on bottom bar of home screen.
 @discussion
 @param      sender: button object.
 @result
 */
- (IBAction)helpButtonTapped:(id)sender{

    HelpViewController *helpVC = [[HelpViewController alloc] initWithNibName:@"HelpViewController"
                                                                    bundle:nil];
    [self presentModalViewController:helpVC animated:YES];
    [helpVC release];
}

/*!
 \internal
 @method     settingsButtonTapped:
 @abstract   Action for to open settings screen.
 @discussion
 @param      sender: button object.
 @result
 */
- (IBAction)settingsButtonTapped:(id)sender{
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc]
                                          initWithNibName:@"SettingsViewController"
                                          bundle:nil];
    [self presentModalViewController:settingsVC animated:YES];
    [settingsVC release];
}

-(void) updateSlaveForMonitoring:(NSString*)slaveId
{
    NSLog(@"slave info updated for monitoring %@", slaveId);
    self.currentlyMonitoredSlave = slaveId;
//    [self startReadingLocation];
}

-(void) updateDateForMonitoring:(NSString*)dateString
{
}

-(void) updateMasterForMonitoring:(NSString*)masterId
{
    NSLog(@"slave info updated for monitoring %@", masterId);
    self.myMasterId = masterId;
    [self startReadingLocation];
}

#pragma mark - 
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation.coordinate.latitude==oldLocation.coordinate.latitude && newLocation.coordinate.longitude ==oldLocation.coordinate.longitude)
        return;
    
//    if (_lastLocation && _lastLocation.coordinate.latitude==newLocation.coordinate.latitude && _lastLocation.coordinate.longitude == newLocation.coordinate.longitude)
//    {
//        return;
//    }
//    _lastLocation =newLocation;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceRegistered"]) {
        
        NSString *deviceId;
        if ([self.myMasterId length] == 0) {
            deviceId = [[UIDevice currentDevice] uniqueIdentifier];
        }
        else
        {
            deviceId = self.myMasterId;
        }
        
        queryType = QueryTypeUpdateSlaveLocation;
        NSURLRequest *theRequest = nil;
        if (kUseStaticServerIP) {
            
            theRequest = [NSURLRequest
                          requestWithURL:[NSURL
                                          URLWithString:[NSString
                                                         stringWithFormat:@"http://172.17.10.25:1208/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",
                                                         deviceId, [[UIDevice currentDevice] uniqueIdentifier], self.locManager.location.coordinate.latitude, self.locManager.location.coordinate.longitude]]];            
        }else{
            
            NSString *urlString = [NSString
                                   stringWithFormat:@"%@/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",
                                   kAppDelegate.serverIPURL,
                                   deviceId,
                                   [[UIDevice currentDevice] uniqueIdentifier],
                                   self.locManager.location.coordinate.latitude,
                                   self.locManager.location.coordinate.longitude];
            
            NSLog(@"Request updateslavelocation URL: %@", urlString);
            
            theRequest = [NSURLRequest
                          requestWithURL:[NSURL
                                          URLWithString:urlString]];
        }
        /* // Previous Implementation
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",deviceId,[[UIDevice currentDevice] uniqueIdentifier], self.locManager.location.coordinate.latitude, self.locManager.location.coordinate.longitude]]];*/
        
        NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection) {
        }
        else {
            NSLog(@"connection failed");
        }
        
        
        queryType = QueryTypeUpdateSlaveSpeed;
        NSURLRequest *aRequest = nil;
        if (kUseStaticServerIP) {
            
            aRequest = [NSURLRequest
                        requestWithURL:[NSURL
                                        URLWithString:[NSString
                                                       stringWithFormat:@"http://172.17.10.25:1208/updateslavespeed?master=%@&slave=%@&speed=%f",
                                                       deviceId, [[UIDevice currentDevice] uniqueIdentifier], newLocation.speed]]];
        }else{
            
            NSString *urlString = [NSString
                                   stringWithFormat:@"%@/updateslavespeed?master=%@&slave=%@&speed=%f",
                                   kAppDelegate.serverIPURL, deviceId, [[UIDevice currentDevice] uniqueIdentifier], newLocation.speed];
            
            NSLog(@"Request updateslavespeed URL: %@", urlString);
            aRequest = [NSURLRequest
                        requestWithURL:[NSURL
                                        URLWithString:urlString]
                        ];
        }
        /* // Previous Implementation
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/updateslavespeed?master=%@&slave=%@&speed=%f",deviceId,[[UIDevice currentDevice] uniqueIdentifier], newLocation.speed]]];*/
        
        NSURLConnection *aConnection= [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
        
        if (aConnection) {
        }
        else {
            NSLog(@"connection failed");
        }        
//        [theConnection release];
    }
    
    
    NSTimeInterval ageInSeconds = [newLocation.timestamp timeIntervalSinceNow];
    
    //ensure you have an accurate and non-cached reading
//    if( newLocation.horizontalAccuracy > kRequiredAccuracy || fabs(ageInSeconds) > kMaxAge )
//        return;
    
    //get current speed
    double currSpeed = newLocation.speed * 3.6;
    if (currSpeed < 0.0f) {
        currSpeed = 0.0f;
    }
    self.currentSpeed.text = [NSString stringWithFormat:@"%.2f km/h", currSpeed];
    deviceSpeed = currSpeed;
    //deviceSpeed = 45.0;
    NSLog(@"deviceSpeed : %.2f",deviceSpeed);
    [self speedComparison];
    
    //this puts the GPS to sleep, saving power
//    [self.locManager stopUpdatingLocation];
    
    //timer fires after 60 seconds, then stops
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timeIntervalEnded:) userInfo:nil repeats:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    UIAlertView *anErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [anErrorAlert show];
//    [anErrorAlert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
}

#pragma mark -
#pragma mark Animation View
- (void)speedComparison
{
    NSLog(@"comparison deviceSpeed : %.2f",deviceSpeed);
    if(deviceSpeed < 25.0f) {
        [view25 setBackgroundColor:[UIColor colorWithRed:0.0 green:255.0 blue:0.0 alpha:0.6]];
        [view50 setBackgroundColor:[UIColor clearColor]];
        [view75 setBackgroundColor:[UIColor clearColor]];
    } else if(deviceSpeed > 25.0f && deviceSpeed < 50.0f) {
        [view50 setBackgroundColor:[UIColor colorWithRed:255.0 green:140.0 blue:0.0 alpha:0.5]];
        [view25 setBackgroundColor:[UIColor clearColor]];
        [view75 setBackgroundColor:[UIColor clearColor]];
    } else if(deviceSpeed > 50.0f && deviceSpeed < 75.0f) {
        [view75 setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.8]];
        [view25 setBackgroundColor:[UIColor clearColor]];
        [view50 setBackgroundColor:[UIColor clearColor]];
    } else if(deviceSpeed > 75.0f) {
        
    }
}

- (void)onTimer
{
	// build a view from our flake image
	UIImageView* ballView = [[UIImageView alloc] initWithImage:ballImage];
	
	// use the random() function to randomize up our flake attributes
	int startX = round(random() % 90);
	int endX = round(random() % 90);
	double scale = 1 / round(random() % 80) + 1.0;
	double ballSpeed = 1 / round(random() % 80) + 1.0;
	
	// set the flake start position
    if(deviceSpeed < 25.0f)
    {
        ballView.frame = CGRectMake(endX, 65.0, 15.0 * scale, 15.0 * scale);
    }
    else if(deviceSpeed > 25.0f && deviceSpeed < 50.0f)
    {
        ballView.frame = CGRectMake(endX, 35.0, 15.0 * scale, 15.0 * scale);
    }
    else if(deviceSpeed > 50.0f && deviceSpeed < 75.0f)
    {
        ballView.frame = CGRectMake(endX, 7.0, 15.0 * scale, 15.0 * scale);
    }
    else if(deviceSpeed > 75.0f)
    {
        //ballView.frame = CGRectMake(endX, 65.0, 15.0 * scale, 15.0 * scale);
    }
	//ballView.frame = CGRectMake(endX, 85.0, 15.0 * scale, 15.0 * scale);
	ballView.alpha = 0.25;
	
	// put the flake in our main view
	//[self.view addSubview:ballView];
    [self.circleView addSubview:ballView];
	
	[UIView beginAnimations:nil context:ballView];
	// set up how fast the flake will fall
	[UIView setAnimationDuration:5 * ballSpeed];
	
	// set the postion where flake will move to
	ballView.frame = CGRectMake(startX, 0.0, 15.0 * scale, 15.0 * scale);
	
	// set a stop callback so we can cleanup the flake when it reaches the
	// end of its animation
	[UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
	
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	UIImageView *ballView = context;
	[ballView removeFromSuperview];
//	[ballView release];
}

#pragma mark -
#pragma mark Speedometer methods
/**
 Start reading the speed of iPhone after every 1 second
 */
- (void)startReadingLocation {
    [self.locManager startUpdatingLocation];
}

//this is a wrapper method to fit the required selector signature
- (void)timeIntervalEnded:(NSTimer*)timer {
    [self startReadingLocation];
}

#pragma mark - 
#pragma mark - Side Menu Delegates

-(void) menuShowAction
{
    if (self.hideMenuTimer != nil &&
        self.hideMenuTimer.isValid) {
        
        [self.hideMenuTimer invalidate];
        self.hideMenuTimer = nil;
    }
    
    /*
    if ([self.self.bottomView isHidden]) {
       [self.bottomView setHidden:NO];
    }
    else {
        [self.bottomView setHidden:YES];
    }*/
    
   /*
    if ([self.backgroundView isHidden]) {
        [self.backgroundView setHidden:NO];
        [self.circleView setHidden:NO];
        [self.bottomView setHidden:NO];
    }
    else {
        [self.backgroundView setHidden:YES];
        [self.circleView setHidden:YES];
        [self.bottomView setHidden:YES];
    }*/
}


/**
 Called when AR button is tapped from side view
 */
-(void)navigateToARScreenAction
{
    NSLog(@"view controller navigation method called");
    ARHomeViewController *controller = [[ARHomeViewController alloc] initWithNibName:@"ARHomeViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

-(void)navigateToRoutesScreenAction
{
    RoutesViewController *aRoutesController = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:[NSBundle mainBundle]];
    aRoutesController.currentLocation = self.locManager.location;
    [self.navigationController pushViewController:aRoutesController animated:YES];
    [aRoutesController release];
}

-(void)navigateToSpeedScreenAction{
    GLSpeedViewController *speedController = [[GLSpeedViewController alloc] initWithNibName:@"GLSpeedViewController" bundle:[NSBundle mainBundle]];
    speedController.currentLocation = self.locManager.location;
    [self.navigationController pushViewController:speedController animated:YES];
    [speedController release];
}
-(void)navigateToTrackingScreenAction{

    TrackingViewController *trackingController = [[TrackingViewController alloc]
                                                  initWithNibName:@"TrackingViewController"
                                                  bundle:nil];
    trackingController.currentLocation = self.locManager.location;
    trackingController.delegate = self;
    [self presentModalViewController:trackingController animated:YES];
    [trackingController release];    
}


@end