//
//  GLCoreLocationController.h
//  GLGeofencing
//
//  Created by NAG1-DMAC-26707 on 08/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CoreLocationControllerDelegate
@required

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
@interface GLCoreLocationController : NSObject<CLLocationManagerDelegate> {
	CLLocationManager *locMgr;
	id delegate;
    CLLocationCoordinate2D		currentLocationCoords;
    CLLocationCoordinate2D		newLocationCoords;
	
	NSString					*callerNotificationName;
	NSTimer                     *trackTimer;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSString *callerNotificationName;
@property (nonatomic, retain) NSTimer  *trackTimer;

+(GLCoreLocationController*)sharedLocationService;
-(void) processCurrentLocation:(NSString*)notificationName;
-(CLLocationCoordinate2D)getCurrentLocation;
-(CLLocationCoordinate2D)getLocationForAddress:(NSString *)address;
-(double)getDistanceBetweenTwoPoints:(CLLocationCoordinate2D)firstPoint second:(CLLocationCoordinate2D)secondPoint;
- (void)getTimedOut:(NSTimer *)timer;
-(void)appWillTerminate;

@end
