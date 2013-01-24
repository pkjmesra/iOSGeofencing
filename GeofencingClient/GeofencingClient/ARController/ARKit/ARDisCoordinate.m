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
//  ARDisCoordinate.m
//  GLFramework
//
//  Created by Rajesh Dongre on 06/01/11.
//  Copyright 2011 Research2Development Nagpur. All rights reserved.
//

#import "ARDisCoordinate.h"


@implementation ARDisCoordinate

@synthesize radialDistance, inclination, azimuth;
@synthesize title, subtitle, disttitle, objectID;

+ (ARDisCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth {
	ARDisCoordinate *newCoordinate = [[ARDisCoordinate alloc] init];
	newCoordinate.radialDistance = newRadialDistance;
	newCoordinate.inclination = newInclination;
	newCoordinate.azimuth = newAzimuth;
	
	newCoordinate.title     = @"";
	newCoordinate.subtitle  = @"";
	newCoordinate.disttitle = @"";
	newCoordinate.objectID  = @"";
	return [newCoordinate autorelease];
}

- (NSUInteger)hash{
	return ([self.title hash] ^ [self.subtitle hash]) + (int)(self.radialDistance + self.inclination + self.azimuth);
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCoordinate:other];
}

- (BOOL)isEqualToCoordinate:(ARDisCoordinate *)otherCoordinate {
    if (self == otherCoordinate) return YES;
    
	BOOL equal = self.radialDistance == otherCoordinate.radialDistance;
	equal = equal && self.inclination == otherCoordinate.inclination;
	equal = equal && self.azimuth == otherCoordinate.azimuth;
		
	if (self.title && otherCoordinate.title || self.title && !otherCoordinate.title || !self.title && otherCoordinate.title) {
		equal = equal && [self.title isEqualToString:otherCoordinate.title];
	}
	
	return equal;
}

- (void)dealloc {
	
	self.title = nil;
	self.subtitle = nil;
	self.disttitle = nil;
	self.objectID = nil;
	
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ r: %.3fm φ: %.3f° θ: %.3f°", self.title, self.radialDistance, radiansToDegrees(self.azimuth), radiansToDegrees(self.inclination)];
}

@end
