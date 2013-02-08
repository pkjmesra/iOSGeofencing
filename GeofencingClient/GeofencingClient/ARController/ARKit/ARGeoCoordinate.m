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
//  ARGeoCoordinate.m
//  GLFramework
//
//  Created by Rajesh Dongre on 06/01/11.
//  Copyright 2011 Praveen K Jha Nagpur. All rights reserved.
//

#import "ARGeoCoordinate.h"


@implementation ARGeoCoordinate

@synthesize geoLocation;

- (float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second {
	float longitudinalDifference = second.longitude - first.longitude;
	float latitudinalDifference = second.latitude - first.latitude;
	float possibleAzimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
	if (longitudinalDifference > 0) return possibleAzimuth;
	else if (longitudinalDifference < 0) return possibleAzimuth + M_PI;
	else if (latitudinalDifference < 0) return M_PI;
	
	return 0.0f;
}

- (void)calibrateUsingOrigin:(CLLocation *)origin {
	
	if (!self.geoLocation) return;
	
	double baseDistance = [origin distanceFromLocation:self.geoLocation];
	
	self.radialDistance = sqrt(pow(origin.altitude - self.geoLocation.altitude, 2) + pow(baseDistance, 2));
		
	float angle = sin(ABS(origin.altitude - self.geoLocation.altitude) / self.radialDistance);
	
	if (origin.altitude > self.geoLocation.altitude) angle = -angle;
	
	self.inclination = angle;
	self.azimuth = [self angleFromCoordinate:origin.coordinate toCoordinate:self.geoLocation.coordinate];
}

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location {
	ARGeoCoordinate *newCoordinate = [[ARGeoCoordinate alloc] init];
	newCoordinate.geoLocation = location;
	
	newCoordinate.title    = @"";
	newCoordinate.subtitle = @"";
	newCoordinate.objectID = @"";
	
	return [newCoordinate autorelease];
}

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin {
	ARGeoCoordinate *newCoordinate = [ARGeoCoordinate coordinateWithLocation:location];
	
	[newCoordinate calibrateUsingOrigin:origin];
		
	return newCoordinate;
}

@end
