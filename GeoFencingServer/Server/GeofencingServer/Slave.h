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
//  Slave.h
//  GeofencingServer
//
//  Created by Praveen Jha on 19/11/12.
//
//
#import "SlaveBase.h"
#import "Region.h"
#import <MapKit/MapKit.h>



@interface Slave : SlaveBase <MKMapViewDelegate>
{
    BOOL _wentOutOfRegion;
    float _frequency;
    MKPointAnnotation *_pin;
    MKCircle *_circle;
    NSColor *pinColor;
    NSInteger pinColorValue;
}

@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *UDID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CGPoint location;
//@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic) CGFloat speed;
@property (nonatomic, strong) NSString *master;
@property (nonatomic, strong) NSString *masterName;
@property (nonatomic, strong) Region *regionMonitored;
@property (nonatomic,strong)     NSColor *pinColor;
@property (nonatomic)     NSInteger pinColorValue;

-(void) setRegionX:(NSString*)x Y:(NSString*)y Radius:(NSString*)r Frequency:(NSString*)frequency;
-(void) setLocationForCoordinate:(NSString *) latitude longitude:(NSString *)longitude;
-(void) setLocationForPoint:(CGPoint) location;
-(void) setLocationForLatitude:(NSString *) lat longitude:(NSString *)longitude;

- (void)addPinForPoint:(GeoLocation *) location;
-(MKPolyline*) loadRouteFromNewLineSeparatedPoints:(NSString*)pointStringsNewLines;
-(void)sendMessage:(NSString *)message;
@end
