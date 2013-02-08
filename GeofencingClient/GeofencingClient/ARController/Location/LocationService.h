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
//  LocationService.h
//  GLFramework
//
//  Created by Rajesh Dongre on 05/01/11.
//  Copyright 2011 Praveen K Jha. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
@class CLLocationManager;

@interface LocationService : NSObject<CLLocationManagerDelegate>
{
	CLLocationManager			*objLocationManager;
	CLLocationCoordinate2D		currentLocationCoords; 
    CLLocationCoordinate2D		newLocationCoords;  
	
	NSString					*callerNotificationName;
	NSTimer                     *trackTimer;
}
@property (nonatomic, retain) CLLocationManager *objLocationManager;
@property (nonatomic, retain) NSString *callerNotificationName;
@property (nonatomic, retain) NSTimer  *trackTimer;

+(LocationService*)sharedLocationService;
-(void) processCurrentLocation:(NSString*)notificationName;
-(CLLocationCoordinate2D)getCurrentLocation;
-(CLLocationCoordinate2D)getLocationForAddress:(NSString *)address;
-(double)getDistanceBetweenTwoPoints:(CLLocationCoordinate2D)firstPoint second:(CLLocationCoordinate2D)secondPoint;
- (void)getTimedOut:(NSTimer *)timer;
-(void)appWillTerminate;
@end
