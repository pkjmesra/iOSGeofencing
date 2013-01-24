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
//  ARKViewController.m
//  GLFramework
//
//  Created by Rajesh Dongre on 06/01/11.
//  Copyright 2011 Research2Development Nagpur. All rights reserved.
//

#import "ARViewController.h"
#import <QuartzCore/QuartzCore.h>

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392
#define COMPASSVIEWTAG          1000

@implementation ARViewController

@synthesize locationManager, accelerometerManager;
@synthesize centerCoordinate;

@synthesize scaleViewsBasedOnDistance, rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor, maximumRotationAngle;
@synthesize updateFrequency;
@synthesize debugMode = ar_debugMode;

@synthesize coordinates = ar_coordinates;

@synthesize delegate;

@synthesize cameraController;

- (id)init {
	if (!(self = [super init])) return nil;
	
	ar_debugView = nil;
	ar_overlayView = nil;
	
	ar_debugMode = NO;
	
	ar_coordinates = [[NSMutableArray alloc] init];
	ar_coordinateViews = [[NSMutableArray alloc] init];
	
	_updateTimer = nil;
	self.updateFrequency = 1 / 20.0;
	currPoint = CGPointZero;	
#if !TARGET_IPHONE_SIMULATOR	
	self.cameraController = [[[UIImagePickerController alloc] init] autorelease];
	self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	self.cameraController.cameraViewTransform = CGAffineTransformScale(self.cameraController.cameraViewTransform,
																	   1.25f,
																	   1.25f);
	
	self.cameraController.showsCameraControls = NO;
	self.cameraController.navigationBarHidden = NO;
#endif
	
	self.scaleViewsBasedOnDistance = NO;
	self.maximumScaleDistance = 0.0;
	self.minimumScaleFactor = 1.0;
	
	self.rotateViewsBasedOnPerspective = NO;
	self.maximumRotationAngle = M_PI / 6.0;
	
	self.wantsFullScreenLayout = YES;
	
	return self;
}

- (void)setTarget:(id)arTarget action:(SEL)arAction
{
    target = arTarget;
    action = arAction;
}

- (id)initWithLocationManager:(CLLocationManager *)manager {
	
	if (!(self = [super init])) return nil;
	
	//use the passed in location manager instead of ours.
	self.locationManager = manager;
	self.locationManager.delegate = self;
	
	return self;
}

- (void)setUpdateFrequency:(double)newUpdateFrequency {
	
	updateFrequency = newUpdateFrequency;
	
	if (!_updateTimer) return;
	
	[_updateTimer invalidate];
	[_updateTimer release];
	
	_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
													 target:self
												   selector:@selector(updateLocations:)
												   userInfo:nil
													repeats:YES] retain];
}

- (void)setHomeButtonForOverlayView
{
	if(ar_overlayView != nil)
	{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];        
        UIImage *image = [self.delegate homeButtonImageForARView];
		CGRect rect = self.cameraController.view.frame; 
        [button setFrame:CGRectMake(rect.size.width-(image.size.width + 20), rect.size.height - (image.size.height + 10), image.size.width+10, image.size.height+5)];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];			
        [button setImage:image forState:UIControlStateNormal];
		[ar_overlayView addSubview:button];
	}
}

- (void)removeHomeButtonForOverlayView
{
	for (UIView *newView in [ar_overlayView subviews]) {
		if([newView isKindOfClass:[UIButton class]])
		{
			[newView removeFromSuperview];
			newView.transform = CGAffineTransformIdentity;
		}
	}
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[ar_overlayView release];
	ar_overlayView = [[UIView alloc] initWithFrame:CGRectZero];	
	[ar_debugView release];
	
	if (self.debugMode) {
		ar_debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		ar_debugView.textAlignment = UITextAlignmentCenter;
		ar_debugView.text = @"Waiting...";
		
		[ar_overlayView addSubview:ar_debugView];
	}
		
	self.view = ar_overlayView;
	[self setHomeButtonForOverlayView];
//    UIView *compassView = [self.delegate compassView:nil];
//    [compassView setTag:COMPASSVIEWTAG];
//	[self.view addSubview:compassView];
}

- (void)setDebugMode:(BOOL)flag {
	if (self.debugMode == flag) return;
	
	ar_debugMode = flag;
	
	//we don't need to update the view.
	if (![self isViewLoaded]) return;
	
	if (self.debugMode) [ar_overlayView addSubview:ar_debugView];
	else [ar_debugView removeFromSuperview];
}

- (BOOL)viewportContainsCoordinate:(ARDisCoordinate *)coordinate {
	double centerAzimuth = self.centerCoordinate.azimuth;
	double leftAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	double rightAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (rightAzimuth > 2 * M_PI) {
		rightAzimuth = rightAzimuth - 2 * M_PI;
	}
	
	BOOL result = (coordinate.azimuth > leftAzimuth && coordinate.azimuth < rightAzimuth);
	
	if(leftAzimuth > rightAzimuth) {
		result = (coordinate.azimuth < rightAzimuth || coordinate.azimuth > leftAzimuth);
	}
	
	double centerInclination = self.centerCoordinate.inclination;
	double bottomInclination = centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination = centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	//check the height.
	result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination);
    //Hack for simulator.
    //result = YES;
	return result;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	
	if (!self.locationManager) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		
		//we want every move.
		self.locationManager.headingFilter = kCLHeadingFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		//[self.locationManager startUpdatingLocation];
		[self.locationManager startUpdatingHeading];
		//steal back the delegate.
		self.locationManager.delegate = self;
	}
	
	
	
	if (!self.accelerometerManager) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = 0.01;
		self.accelerometerManager.delegate = self;
	}
	
	if (!self.centerCoordinate) {
		self.centerCoordinate = [ARDisCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0];
	}
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARDisCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	
	double pointAzimuth = coordinate.azimuth;
	
	//our x numbers are left based.
	double leftAzimuth = self.centerCoordinate.azimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	if (pointAzimuth < leftAzimuth) {
		//it's past the 0 point.
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	} else {
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	}
	
	//y coordinate.
	
	double pointInclination = coordinate.inclination;
	
	double topInclination = self.centerCoordinate.inclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	point.y = realityView.frame.size.height - ((pointInclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * realityView.frame.size.height;
	
	return point;
}

#define kFilteringFactor 0.05
UIAccelerationValue rollingX, rollingZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// -1 face down.
	// 1 face up.
	
	//update the center coordinate.
	
	//NSLog(@"x: %f y: %f z: %f", acceleration.x, acceleration.y, acceleration.z);
	
	//this should be different based on orientation.
	
	rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
	
	if (rollingZ > 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) + M_PI / 2.0;
	} else if (rollingZ < 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) - M_PI / 2.0;// + M_PI;
	} else if (rollingX < 0) {
		self.centerCoordinate.inclination = M_PI/2.0;
	} else if (rollingX >= 0) {
		self.centerCoordinate.inclination = 3 * M_PI/2.0;
	}
}

NSComparisonResult LocationSortClosestFirst(ARDisCoordinate *s1, ARDisCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedAscending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (void)addCoordinate:(ARDisCoordinate *)coordinate {
	[self addCoordinate:coordinate animated:YES];
}

- (void)addCoordinate:(ARDisCoordinate *)coordinate animated:(BOOL)animated {
	//do some kind of animation?
	[ar_coordinates addObject:coordinate];
		
	if (coordinate.radialDistance > self.maximumScaleDistance) {
		self.maximumScaleDistance = coordinate.radialDistance;
	}
	
	//message the delegate.
	UIView *coordinateView = [self.delegate viewForCoordinate:coordinate];
	[ar_coordinateViews addObject:coordinateView];
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	
	//go through and add each coordinate.
	for (ARDisCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate animated:NO];
	}
}

- (void)removeCoordinate:(ARDisCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARDisCoordinate *)coordinate animated:(BOOL)animated {
	//do some kind of animation?
	[ar_coordinates removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinates {	
	for (ARDisCoordinate *coordinateToRemove in coordinates) {
		NSUInteger indexToRemove = [ar_coordinates indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		
		[ar_coordinates removeObjectAtIndex:indexToRemove];
		[ar_coordinateViews removeObjectAtIndex:indexToRemove];
	}
}

- (void)removeAllCoordinates
{
	if(ar_coordinates != nil)
		[ar_coordinates removeAllObjects];
	if(ar_coordinateViews != nil)
		[ar_coordinateViews removeAllObjects];
}

- (void)handleLockEvent
{	
	NSLog(@"phone locked");	
	for (UIView *newView in [ar_overlayView subviews]) {		
		[newView removeFromSuperview];
		newView.transform = CGAffineTransformIdentity;
	}	
	[self dismissARView];
}

- (void)handleUnlockEvent
{
	NSLog(@"phone unlocked");				
	[self presentARView];
	[self setHomeButtonForOverlayView];
	if (!_updateTimer) {
		_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
														 target:self
													   selector:@selector(updateLocations:)
													   userInfo:nil
														repeats:YES] retain];
	}	
}

- (void)presentARView
{	
	if(self.cameraController == nil)
	{
#if !TARGET_IPHONE_SIMULATOR	
		self.cameraController = [[[UIImagePickerController alloc] init] autorelease];
		self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
		
		self.cameraController.cameraViewTransform = CGAffineTransformScale(self.cameraController.cameraViewTransform,
																		   1.25f,
																		   1.25f);
		
		self.cameraController.showsCameraControls = NO;
		self.cameraController.navigationBarHidden = NO;
		
		[self.cameraController setCameraOverlayView:ar_overlayView];
		[self presentModalViewController:self.cameraController animated:NO];
		[ar_overlayView setFrame:self.cameraController.view.bounds];		
#endif
		[self.locationManager startUpdatingHeading];
		self.accelerometerManager.delegate = self;
	}
}

- (void)dismissARView
{
#if !TARGET_IPHONE_SIMULATOR
	self.cameraController = nil;
	[self dismissModalViewControllerAnimated:YES];
#endif	
	[_updateTimer invalidate];	
	[_updateTimer release];
	_updateTimer = nil;				
	[locationManager stopUpdatingHeading];
	[accelerometerManager setDelegate:nil];
}

- (void)updateLocations:(NSTimer *)timer 
{
	//update locations!
	for (UIView *newView in [ar_overlayView subviews]) {
		if(![newView isKindOfClass:[UIButton class]])// && newView.tag != COMPASSVIEWTAG)
		{
			[newView removeFromSuperview];
			newView.transform = CGAffineTransformIdentity;
		}
	}
	
	if (!ar_coordinateViews || ar_coordinateViews.count == 0) {
		return;
	}
	
	ar_debugView.text = [self.centerCoordinate description];
	
	int index = 0;
	CGFloat currentY = ar_overlayView.frame.size.height;
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:ar_coordinates];
    [array addObject:centerCoordinate];
    UIView *compassView = [self.delegate compassView:array];
    [array release];
    [compassView setTag:COMPASSVIEWTAG];
	[self.view addSubview:compassView];
	for (ARDisCoordinate *item in ar_coordinates) {		
		UIView *viewToDraw = [ar_coordinateViews objectAtIndex:index];

		if ([self viewportContainsCoordinate:item]) {
			
			CGPoint loc = [self pointInView:ar_overlayView forCoordinate:item];
            //Hack for simulator.
            //loc.x = 320.0;
			
			CGFloat scaleFactor = 1.0;
			if (self.scaleViewsBasedOnDistance) {
				scaleFactor = 1.0 - self.minimumScaleFactor * (item.radialDistance / self.maximumScaleDistance);
			}
			
			float width = viewToDraw.bounds.size.width * scaleFactor;
			float height = viewToDraw.bounds.size.height * scaleFactor;
			
			viewToDraw.frame = CGRectMake(loc.x - width / 2.0, loc.y - height / 2.0, width, height);					
						
			//if we don't have a superview, set it up.			
			if (!(viewToDraw.superview) && currentY >= viewToDraw.frame.size.height/* AR_VIEW_HEIGHT*/) {				
				//Reset y co-ordinate for the view.
				CGRect rect = viewToDraw.frame;
				if(rect.origin.y > 0 || rect.origin.y < ar_overlayView.frame.size.height)
				{
					currentY -= viewToDraw.frame.size.height/*AR_VIEW_HEIGHT*/;
					viewToDraw.frame = CGRectMake(rect.origin.x/*(ar_overlayView.frame.size.width-width)/2*/, currentY, rect.size.width, rect.size.height);					[ar_overlayView addSubview:viewToDraw];
					[ar_overlayView sendSubviewToBack:viewToDraw];
				}				
			}			
		} 
		index++;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
		
	self.centerCoordinate.azimuth = fmod(newHeading.magneticHeading, 360.0) * (2 * (M_PI / 360.0));
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {	
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
	
}

- (void)viewDidAppear:(BOOL)animated {
#if !TARGET_IPHONE_SIMULATOR
	if(self.cameraController != nil)
	{
		[self.cameraController setCameraOverlayView:ar_overlayView];
		[self presentModalViewController:self.cameraController animated:NO];
		[ar_overlayView setFrame:self.cameraController.view.bounds];
	}    
#endif    
	if (!_updateTimer) {
		_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
														 target:self
													   selector:@selector(updateLocations:)
													   userInfo:nil
														repeats:YES] retain];
	}
	[super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.debugMode) {
		[ar_debugView sizeToFit];
		[ar_debugView setFrame:CGRectMake(0,
										  ar_overlayView.frame.size.height - ar_debugView.frame.size.height,
										  ar_overlayView.frame.size.width,
										  ar_debugView.frame.size.height)];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[ar_overlayView release];
	ar_overlayView = nil;			
	[locationManager stopUpdatingHeading];
	[accelerometerManager setDelegate:nil];
}


- (void)dealloc {
	[_updateTimer invalidate];	
	[_updateTimer release];
	_updateTimer = nil;
#if !TARGET_IPHONE_SIMULATOR
	[cameraController release];
#endif
	if(locationManager != nil)
	{
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
	}
	if(accelerometerManager != nil)
		[accelerometerManager setDelegate:nil];	

	[locationManager release];		
	locationManager = nil;
	[accelerometerManager release];
	accelerometerManager = nil;
	[ar_debugView release];	
	ar_debugView = nil;
	[ar_overlayView release];
	ar_overlayView = nil;
	[ar_coordinateViews release];
	ar_coordinateViews = nil;
	[ar_coordinates release];
	ar_coordinates = nil;
	[target release];
	target = nil;
    [super dealloc];
}

@end
