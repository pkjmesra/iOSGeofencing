//
//  GLCoreLocationController.m
//  GLGeofencing
//
//  Created by NAG1-DMAC-26707 on 08/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLCoreLocationController.h"

@implementation GLCoreLocationController
@synthesize locMgr, delegate;
@synthesize callerNotificationName;
@synthesize trackTimer;

static GLCoreLocationController *sharedLocationService = nil;

#pragma mark -
#pragma mark - init/dealloc -
+ (GLCoreLocationController*)sharedLocationService
{
	if (sharedLocationService == nil)
	{
		[[GLCoreLocationController alloc] init];
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

//-(id)init
//{
//    if((self = [super init]))
//    {
//        self.locMgr = [[CLLocationManager alloc] init];
//        locMgr.delegate = self;
//        locMgr.desiredAccuracy = kCLLocationAccuracyBest;
//		//Modified for 3.2 compatibility.
//		currentLocationCoords.latitude = 0.0;
//		currentLocationCoords.longitude = 0.0;
//		//CLLocationCoordinate2DMake(0.0,0.0);
//        trackTimer = nil;
//		
//	}
//    return self;
//}

#pragma mark -
#pragma mark - locationManager start method Operation -
- (void)getTimedOut:(NSTimer *)timer
{
	[self.locMgr stopUpdatingLocation];
	[timer invalidate];
    NSLog(@"Inside time out: request timed out.");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:callerNotificationName object:nil]];
}

-(void) processCurrentLocation:(NSString*)notificationName
{
	callerNotificationName = notificationName;
	if(self.locMgr != nil)
    {
        [self.locMgr startUpdatingLocation];
		self.trackTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTimedOut:) userInfo:nil repeats:NO];
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
	[self.locMgr stopUpdatingLocation];
	[trackTimer invalidate];
}

//-(void)dealloc
//{
//    [objLocationManager release];
//	[callerNotificationName release];
//	[trackTimer invalidate];
//	
//	[super dealloc];
//}


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

//#pragma mark -
//#pragma mark Location Manager Delegate Methods
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//	[trackTimer invalidate];
//    [self.locMgr stopUpdatingLocation];
//	currentLocationCoords.latitude=newLocation.coordinate.latitude;
//	currentLocationCoords.longitude=newLocation.coordinate.longitude;
//	
//	NSLog(@"Inside didUpdateToLocation, %lf, %lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
//	
//	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:callerNotificationName object:nil]];
//}
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error
//{
//	NSLog(@"Inside the delegate: didFailWithError");
//}

- (id)init {
	self = [super init];
	
	if(self != nil) {
		self.locMgr = [[[CLLocationManager alloc] init] autorelease];
		self.locMgr.delegate = self;
        self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
		//Modified for 3.2 compatibility.
		currentLocationCoords.latitude = 0.0;
		currentLocationCoords.longitude = 0.0;
		//CLLocationCoordinate2DMake(0.0,0.0);
        trackTimer = nil;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationUpdate:newLocation];
        
        [trackTimer invalidate];
        [locMgr stopUpdatingLocation];
        currentLocationCoords.latitude=newLocation.coordinate.latitude;
        currentLocationCoords.longitude=newLocation.coordinate.longitude;
        
        NSLog(@"Inside didUpdateToLocation, %lf, %lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:callerNotificationName object:nil]];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationError:error];
	}
}

- (void)dealloc {
    [callerNotificationName release];
	[trackTimer invalidate];
	[super dealloc];
}
@end
