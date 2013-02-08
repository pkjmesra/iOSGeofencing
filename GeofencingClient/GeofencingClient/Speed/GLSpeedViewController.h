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
//  GLSpeedViewController.h
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 06/12/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GLSpeedViewController : UIViewController <CLLocationManagerDelegate>{
	UIImageView *needleImageView;
	float speedometerCurrentValue;
	float prevAngleFactor;
	float angle;
	NSTimer *speedometer_Timer;
	UILabel *speedometerReading;
	NSString *maxVal;
	CLLocation *currentLocation;
    CLLocationManager *_locManager;
    
    UILabel *currSpeedLbl;
    NSString *currSpeed;
    UILabel *avgSpeedLbl;
    NSString *avgSpeed;
    UILabel *avgSpeedLabel;
    UILabel *currentSpeedLabel;
    UIImage* ballImage;
    float deviceSpeed;
    UIView *view25;
}
@property(nonatomic, retain) UIImageView *needleImageView;
@property(nonatomic, assign) float speedometerCurrentValue;
@property(nonatomic, assign) float prevAngleFactor;
@property(nonatomic, assign) float angle;
@property(nonatomic, retain) NSTimer *speedometer_Timer;
@property(nonatomic, retain) UILabel *speedometerReading;
@property(nonatomic, retain) NSString *maxVal;
@property(nonatomic, retain) CLLocation *currentLocation;
@property(nonatomic, retain) CLLocationManager               *locManager;
@property (nonatomic, retain) IBOutlet UILabel *avgSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentSpeedLabel;

@property (nonatomic, retain) IBOutlet UILabel *currSpeedLbl;
@property (nonatomic, retain) NSString *currSpeed;
@property (nonatomic, retain) IBOutlet UILabel *avgSpeedLbl;
@property (nonatomic, retain) NSString *avgSpeed;

@property (nonatomic, retain) UIImage* ballImage;
@property (assign) float deviceSpeed;
@property (nonatomic, retain) UIView *view25;

-(void) addMeterViewContents;
-(void) rotateIt:(float)angl;
-(void) rotateNeedle;
-(void) setSpeedometerCurrentValue;

-(IBAction)onCancelBtn:(id)sender;
- (void)resetNavigationButton;

@end
