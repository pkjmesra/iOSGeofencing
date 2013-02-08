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
//  ViewController.h
//  iOSGeofencingClient
//
//  Created by Rajesh Dongre on 08/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "GFMenuContainerView.h"
#import "TrackingViewController.h"

@class GFMenuContainerView, GFGeoFenceView, GFMapViewController;

@interface ViewController : UIViewController<MenuActionDelegate, CLLocationManagerDelegate, UpdateSlaveInfoDelegate> {
    UIView      *m_pCircleView;
    UIView      *m_pBackgroundView;
    UILabel     *m_pCurrentSpeed;
    UIView      *m_bottomView;
    UIButton    *m_pMonitoringBtn;
    
    GFMenuContainerView     *_menuView;
    GFMapViewController     *geoFenceView;
    UIImageView             *needleImageView;
	float                   speedometerCurrentValue;
	float                   prevAngleFactor;
	float                   angle;
	NSTimer                 *speedometer_Timer;
	UILabel                 *speedometerReading;
	NSString                *maxVal;
    
    CLLocationManager       *m_pLocManager;
    CLLocationSpeed         speed;
    NSTimer                 *timer;
    NSString    *currentlyMonitoredSlave;
    NSString    *myMasterId;
    QueryType queryType;
    NSMutableData *receivedData;
    
    UIImage* ballImage;
    float deviceSpeed;
    UIView *view25;
    UIView *view50;
    UIView *view75;
    
    /// Timer to hide menu if its visible onscreen.
    NSTimer *hideMenuTimer;
    CLLocation *_lastLocation;
}

@property (strong, nonatomic) GFMapViewController           *geoFenceView;
@property (nonatomic, retain) IBOutlet UIView               *circleView;
@property (nonatomic, retain) IBOutlet UIView               *backgroundView;
@property (nonatomic, retain) IBOutlet UIView               *bottomView;
@property (nonatomic, retain) IBOutlet UILabel              *currentSpeed;
@property (nonatomic, retain) IBOutlet UILabel              *avgSpeed;
@property (nonatomic, retain) IBOutlet GFMenuContainerView  *menuView;
@property (nonatomic, retain) IBOutlet UIButton             *monitoringBtn;

@property(nonatomic,retain) UIImageView                     *needleImageView;
@property(nonatomic,assign) float                           speedometerCurrentValue;
@property(nonatomic,assign) float                           prevAngleFactor;
@property(nonatomic,assign) float                           angle;
@property(nonatomic,retain) NSTimer                         *speedometer_Timer;
@property(nonatomic,retain) UILabel                         *speedometerReading;
@property(nonatomic,retain) NSString                        *maxVal;
@property(nonatomic,retain) CLLocationManager               *locManager;
@property(nonatomic,retain) NSTimer                         *timer;
@property(nonatomic,retain) NSString    *currentlyMonitoredSlave;
@property(nonatomic,retain) NSMutableData *receivedData;
@property(nonatomic,retain) NSString    *myMasterId;
@property (nonatomic, retain) UIImage* ballImage;
@property (assign) float deviceSpeed;
@property (nonatomic, retain) UIView *view25;
@property (nonatomic, retain) UIView *view50;
@property (nonatomic, retain) UIView *view75;

@property (nonatomic, retain) NSTimer *hideMenuTimer;

- (void)onTimer;
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)speedComparison;

-(void) startReadingLocation;

/*!
 \internal
 @method     helpButtonTapped:
 @abstract   Action for Help/Info button on bottom bar of home screen.
 @discussion
 @param      sender: button object.
 @result
 */
- (IBAction)helpButtonTapped:(id)sender;

/*!
 \internal
 @method     settingsButtonTapped:
 @abstract   Action for to open settings screen.
 @discussion
 @param      sender: button object.
 @result
 */
- (IBAction)settingsButtonTapped:(id)sender;

@end
