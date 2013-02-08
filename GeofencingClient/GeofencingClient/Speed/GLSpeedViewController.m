
/**
Copyright (c) 2011, Praveen K Jha, Praveen K Jha.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list
    of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.
    Neither the name of the Praveen K Jha. nor the names of its contributors may be
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
//  GLSpeedViewController.m
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 06/12/12.
//
//

#import "GLSpeedViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GLSpeedViewController ()

@end

@implementation GLSpeedViewController
@synthesize needleImageView;
@synthesize speedometerCurrentValue;
@synthesize prevAngleFactor;
@synthesize angle;
@synthesize speedometer_Timer;
@synthesize speedometerReading;
@synthesize maxVal;
@synthesize currentLocation;
@synthesize locManager = m_pLocManager;

@synthesize currSpeed;
@synthesize avgSpeed;
@synthesize currSpeedLbl;
@synthesize avgSpeedLbl;

@synthesize ballImage;
@synthesize deviceSpeed;
@synthesize view25;
@synthesize avgSpeedLabel, currentSpeedLabel;

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
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Speedometer";
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    [self resetNavigationButton];
    
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    [self.locManager startUpdatingLocation];
    
    ballImage = [[UIImage alloc] init];
    ballImage = [UIImage imageNamed:@"Ball.png"];
	[NSTimer scheduledTimerWithTimeInterval:(0.30) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    self.view25 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 436.0)];
    view25.layer.masksToBounds = YES;
    [self.view addSubview:self.view25];
    
    // Add Meter Contents //
	[self addMeterViewContents];
    self.avgSpeedLbl.text = [NSString stringWithFormat:@"40 km/h"];
    [self.view bringSubviewToFront:self.avgSpeedLbl];
    [self.view bringSubviewToFront:self.currSpeedLbl];
    [self.view bringSubviewToFront:self.avgSpeedLabel];
    [self.view bringSubviewToFront:self.currentSpeedLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[maxVal release];
	[needleImageView release];
	[speedometer_Timer release];
	[speedometerReading release];
    [currentLocation release];
    [currSpeed release];
    [avgSpeed release];
    //[m_pLocManager release];
    [view25 release];

    [super dealloc];
}

#pragma mark -
#pragma mark Custom methods
- (void)resetNavigationButton
{
    self.navigationItem.hidesBackButton = YES;
		UIImage *image = [UIImage imageNamed:@"cancel.png"];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setFrame:CGRectMake(0, 0, 65.0, 27)];
		[button addTarget:self action:@selector(onCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:image forState:UIControlStateNormal];
		UIBarButtonItem *mainMenuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
		self.navigationItem.rightBarButtonItem = mainMenuButton;
		[mainMenuButton release];
}

#pragma mark -
#pragma mark Animation View
- (void)onTimer
{
	// build a view from our flake image
	UIImageView* ballView = [[UIImageView alloc] initWithImage:ballImage];
	
	// use the random() function to randomize up our flake attributes
	int startX = round(random() % 320);
	int endX = round(random() % 320);
	double scale = 1 / round(random() % 80) + 1.0;
    double ballSpeed;
    if (speedometerCurrentValue <= 20.0f) {
        ballSpeed = 4.0f;
    }
    else if (speedometerCurrentValue >= 20.0f && speedometerCurrentValue <= 40.0f) {
        ballSpeed = 3.0f;
    }
    else if (speedometerCurrentValue >= 40.0f && speedometerCurrentValue <= 60.0f) {
        ballSpeed = 2.0f;
    }
    else if (speedometerCurrentValue >= 60.0f && speedometerCurrentValue <= 80.0f) {
        ballSpeed = 1.0f;
    }
    else if (speedometerCurrentValue >= 80.0f) {
        ballSpeed = 0.4f;
    }
	//double ballSpeed = 1 / round(random() % 80) + 1.0;
    //NSLog(@"ballSpeed : %f",ballSpeed);
	
	// set the flake start position
	ballView.frame = CGRectMake(endX, 480.0, 15.0 * scale, 15.0 * scale);
	ballView.alpha = 0.25;

	// put the flake in our main view
	//[self.view addSubview:ballView];
    [self.view addSubview:ballView];
	
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
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //get current speed
    currSpeed = [NSString stringWithFormat:@"%.2f",newLocation.speed];
    NSLog(@"currSpeed :%@",currSpeed);
    //self.currSpeedLbl.text = [NSString stringWithFormat:@"%@", currSpeed];
    double currentSpeed = currentLocation.speed * 3.6;
    if (currentSpeed < 0.0f) {
        currentSpeed = 0.0f;
    }
    self.speedometerCurrentValue = currentSpeed;
    NSLog(@"speed :%f",self.speedometerCurrentValue);
    self.currSpeedLbl.text = [NSString stringWithFormat:@"%.2f km/h", currentSpeed];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

#pragma mark -
#pragma mark UserActions
-(IBAction)onCancelBtn:(id)sender
{
    //[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Public Methods

-(void) addMeterViewContents
{
	
	UIImageView *meterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 43, 286,286)];
	meterImageView.image = [UIImage imageNamed:@"meter-m.png"];
	[self.view addSubview:meterImageView];
	[meterImageView release];
	
	
	//  Needle //
	UIImageView *imgNeedle = [[UIImageView alloc]initWithFrame:CGRectMake(148,155, 22, 84)];
	self.needleImageView = imgNeedle;
	[imgNeedle release];
	
	self.needleImageView.layer.anchorPoint = CGPointMake(self.needleImageView.layer.anchorPoint.x, self.needleImageView.layer.anchorPoint.y*2);
	self.needleImageView.backgroundColor = [UIColor clearColor];
	self.needleImageView.image = [UIImage imageNamed:@"arrow.png"];
	[self.view addSubview:self.needleImageView];
	
	// Needle Dot //
	UIImageView *meterImageViewDot = [[UIImageView alloc]initWithFrame:CGRectMake(136.5, 175, 45,44)];
	meterImageViewDot.image = [UIImage imageNamed:@"center_wheel.png"];
	[self.view addSubview:meterImageViewDot];
	[meterImageViewDot release];
	
	// Speedometer Reading //
	UILabel *tempReading = [[UILabel alloc] initWithFrame:CGRectMake(127, 260, 60, 30)];
	self.speedometerReading = tempReading;
	[tempReading release];
	self.speedometerReading.textAlignment = UITextAlignmentCenter;
	self.speedometerReading.backgroundColor = [UIColor blackColor];
	self.speedometerReading.text= @"0";
	self.speedometerReading.textColor = [UIColor colorWithRed:114/255.f green:146/255.f blue:38/255.f alpha:1.0];
	[self.view addSubview:self.speedometerReading ];
	
	// Set Max Value //
	self.maxVal = @"100";
	
	/// Set Needle pointer initialy at zero //
	[self rotateIt:-118.4];
	
	// Set previous angle //
	self.prevAngleFactor = -118.4;
	
	// Set Speedometer Value //
	[self setSpeedometerCurrentValue];
}

#pragma mark -
#pragma mark calculateDeviationAngle Method

-(void) calculateDeviationAngle
{
	
	if([self.maxVal floatValue]>0)
	{
		self.angle = ((self.speedometerCurrentValue *237.4)/[self.maxVal floatValue])-118.4;  // 237.4 - Total angle between 0 - 100 //
	}
	else
	{
		self.angle = 0;
	}
	
	if(self.angle<=-118.4)
	{
		self.angle = -118.4;
	}
	if(self.angle>=119)
	{
		self.angle = 119;
	}
	
	
	// If Calculated angle is greater than 180 deg, to avoid the needle to rotate in reverse direction first rotate the needle 1/3 of the calculated angle and then 2/3. //
	if(abs(self.angle-self.prevAngleFactor) >180)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		[self rotateIt:self.angle/3];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		[self rotateIt:(self.angle*2)/3];
		[UIView commitAnimations];
		
	}
	
	self.prevAngleFactor = self.angle;
	
	
	// Rotate Needle //
	[self rotateNeedle];
	
	
}


#pragma mark -
#pragma mark rotateNeedle Method
-(void) rotateNeedle
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[self.needleImageView setTransform: CGAffineTransformMakeRotation((M_PI / 180) * self.angle)];
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark setSpeedometerCurrentValue

-(void) setSpeedometerCurrentValue
{
	if(self.speedometer_Timer)
	{
		[self.speedometer_Timer invalidate];
		self.speedometer_Timer = nil;
	}
	//self.speedometerCurrentValue =  arc4random() % 100; // Generate Random value between 0 to 100. //
    //self.speedometerCurrentValue = currSpeed;
    NSLog(@"%f",self.speedometerCurrentValue);
	
	self.speedometer_Timer = [NSTimer  scheduledTimerWithTimeInterval:2 target:self selector:@selector(setSpeedometerCurrentValue) userInfo:nil repeats:YES];
	
	self.speedometerReading.text = [NSString stringWithFormat:@"%.2f",self.speedometerCurrentValue];
    //self.speedometerReading.text = [NSString stringWithFormat:@"%@",self.currSpeed];
                                    
	
	// Calculate the Angle by which the needle should rotate //
	[self calculateDeviationAngle];
}
#pragma mark -
#pragma mark Speedometer needle Rotation View Methods

-(void) rotateIt:(float)angl
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.01f];
	
	[self.needleImageView setTransform: CGAffineTransformMakeRotation((M_PI / 180) *angl)];
	
	[UIView commitAnimations];
}


@end
