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
//  LocationService.m
//  GLFramework
//
//  Created by Rajesh Dongre on 05/01/11.
//  Copyright 2011 Praveen K Jha. All rights reserved.
//

#import "LocationService.h"
#import <Foundation/Foundation.h>



@implementation LocationService
@synthesize objLocationManager;
@synthesize callerNotificationName; 
@synthesize trackTimer;

static LocationService *sharedLocationService = nil;

#pragma mark -
#pragma mark - init/dealloc -
+ (LocationService*)sharedLocationService
{
	if (sharedLocationService == nil)
	{
		[[LocationService alloc] init];
	}
	return sharedLocationService;
}

+ (id)alloc
{
	if(sharedLocationService == nil)
	{
		sharedLocationService = [super alloc];
		
	}
    return sharedLocationService;
}

-(id)init
{
    if((self = [super init]))
    {
		objLocationManager = [[CLLocationManager alloc] init];   
        objLocationManager.delegate = self;
        objLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
		//Modified for 3.2 compatibility.
		currentLocationCoords.latitude = 0.0;
		currentLocationCoords.longitude = 0.0;
		//CLLocationCoordinate2DMake(0.0,0.0);
        trackTimer = nil;
		
	}
    return self;
}

#pragma mark -
#pragma mark - locationManager start method Operation -
- (void)getTimedOut:(NSTimer *)timer
{	
	[objLocationManager stopUpdatingLocation];
	[timer invalidate];
    NSLog(@"Inside time out: request timed out.");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:callerNotificationName object:nil]];
}

-(void) processCurrentLocation:(NSString*)notificationName 
{
	callerNotificationName = notificationName;
	if(objLocationManager != nil)
    {
        [objLocationManager startUpdatingLocation];
		self.trackTimer =  [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getTimedOut:) userInfo:nil repeats:NO];
		NSLog(@"Location Manager: Started.");
    }
}

- (CLLocationCoordinate2D)getCurrentLocation
{
	//hardcode the values for simulator
//	currentLocationCoords.latitude = 21.08397;
//	currentLocationCoords.longitude = 79.08427;
//	NSLog(@"%@", @"Hardcoded value for simulator.");
	return currentLocationCoords;
}

-(void)appWillTerminate
{
	[objLocationManager stopUpdatingLocation];
	[trackTimer invalidate];
}
	
-(void)dealloc
{   
    [objLocationManager release];
	[callerNotificationName release];
	[trackTimer invalidate];
	
	[super dealloc];
}


#pragma mark -
-(CLLocationCoordinate2D) getLocationForAddress:(NSString *)address
{
    double latitude  = 0.0;
    double longitude = 0.0;
	
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                           [address stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	
    NSString *locationString = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]] autorelease];
	
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
	
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"])
    {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
       
        newLocationCoords.latitude=latitude;
        newLocationCoords.longitude=longitude;
    }
    else
    {
        // Error
    }
	
	return newLocationCoords;
}

-(double) getDistanceBetweenTwoPoints:(CLLocationCoordinate2D)firstPoint second:(CLLocationCoordinate2D)secondPoint
{
	double distance;
    CLLocation    *objLocationFirst = [[[CLLocation alloc] initWithLatitude:firstPoint.latitude longitude:firstPoint.longitude] autorelease];
    CLLocation    *objLocationSecond = [[[CLLocation alloc] initWithLatitude:secondPoint.latitude longitude:secondPoint.longitude] autorelease];
#ifdef __IPHONE_4_0
	if([objLocationFirst respondsToSelector:@selector(distanceFromLocation:)])
		distance = [objLocationFirst distanceFromLocation:objLocationSecond];
#else
		distance = [objLocationFirst getDistanceFrom:objLocationSecond];
#endif
   	return distance;
}

#pragma mark -
#pragma mark Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{   
	[trackTimer invalidate];
    [objLocationManager stopUpdatingLocation];
	currentLocationCoords.latitude=newLocation.coordinate.latitude;
	currentLocationCoords.longitude=newLocation.coordinate.longitude;
	
	NSLog(@"Inside didUpdateToLocation, %lf, %lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:callerNotificationName object:nil]];   
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{  
	NSLog(@"Inside the delegate: didFailWithError");
}

@end
