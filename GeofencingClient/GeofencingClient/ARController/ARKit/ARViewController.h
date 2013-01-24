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
//  ARKViewController.h
//  GLFramework
//
//  Created by Rajesh Dongre on 06/01/11.
//  Copyright 2011 Research2Development Nagpur. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "ARDisCoordinate.h"

@protocol ARViewDelegate
@required
- (UIView *)viewForCoordinate:(ARDisCoordinate *)coordinate;
- (UIImage *)homeButtonImageForARView;
@optional
- (UIView *)compassView:(NSArray *)positionArray;
@end


@interface ARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
	
	ARDisCoordinate *centerCoordinate;
	
	UIImagePickerController *cameraController;
	
	NSObject<ARViewDelegate> *delegate;	
	
	BOOL scaleViewsBasedOnDistance;
	double maximumScaleDistance;
	double minimumScaleFactor;
		
	BOOL rotateViewsBasedOnPerspective;
	double maximumRotationAngle;
	
	//defaults to 20hz;
	double updateFrequency;
	CGPoint   currPoint;
@private
	BOOL ar_debugMode;
	
	NSTimer *_updateTimer;
	
	UIView *ar_overlayView;
	
	UILabel *ar_debugView;
	
	NSMutableArray *ar_coordinates;
	NSMutableArray *ar_coordinateViews;
	id target;
    SEL action;
}

@property (readonly) NSArray *coordinates;

@property BOOL debugMode;

@property BOOL scaleViewsBasedOnDistance;
@property double maximumScaleDistance;
@property double minimumScaleFactor;

@property BOOL rotateViewsBasedOnPerspective;
@property double maximumRotationAngle;
@property double updateFrequency;

//adding coordinates to the underlying data model.
- (void)addCoordinate:(ARDisCoordinate *)coordinate;
- (void)addCoordinate:(ARDisCoordinate *)coordinate animated:(BOOL)animated;

- (void)addCoordinates:(NSArray *)newCoordinates;


//removing coordinates
- (void)removeCoordinate:(ARDisCoordinate *)coordinate;
- (void)removeCoordinate:(ARDisCoordinate *)coordinate animated:(BOOL)animated;

- (void)removeCoordinates:(NSArray *)coordinates;
- (void)removeAllCoordinates;

- (id)initWithLocationManager:(CLLocationManager *)manager;

- (void)startListening;
- (void)updateLocations:(NSTimer *)timer;

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARDisCoordinate *)coordinate;

- (BOOL)viewportContainsCoordinate:(ARDisCoordinate *)coordinate;

- (void)presentARView;
- (void)dismissARView;
- (void)handleLockEvent;
- (void)handleUnlockEvent;
- (void)removeHomeButtonForOverlayView;
- (void)setTarget:(id)arTarget action:(SEL)arAction;

@property (nonatomic, retain) UIImagePickerController *cameraController;
@property (nonatomic, assign) NSObject<ARViewDelegate> *delegate;
@property (retain)            ARDisCoordinate *centerCoordinate;
@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
