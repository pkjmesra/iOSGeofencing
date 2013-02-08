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
//  Slave.m
//  GeofencingServer
//
//  Created by Praveen Jha on 19/11/12.
//
//

#import "Slave.h"
#import "AppDelegate.h"

@implementation Slave

@synthesize master =_master;
@synthesize UDID =_UDID;
@synthesize location =_location;
@synthesize speed =_speed;
@synthesize name=_name;
@synthesize regionMonitored=_regionMonitored;
@synthesize masterName =_masterName;
@synthesize pinColor = _pinColor;
@synthesize pinColorValue;

+ (BOOL) AMCEnabled
{
    return YES;
}

-(id)init
{
    if (self = [super init])
    {
        self.UDID = @"";
        self.master =@"";
        self.name =@"";
        self.location = CGPointZero;
        self.speed = 0;
    }
    return self;
}

-(void) setRegionX:(NSString*)x Y:(NSString*)y Radius:(NSString*)r Frequency:(NSString*)frequency
{
    NSString *xl = [x stringByTrimmingCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *yl = [y stringByTrimmingCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *rl = [r stringByTrimmingCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *f = [frequency stringByTrimmingCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];

    if(!self.regionMonitored)
        self.regionMonitored = [[Region alloc] init];
    
    self.regionMonitored.x=x;
    self.regionMonitored.y=y;
    self.regionMonitored.r=r;
    self.regionMonitored.frequency=frequency;
    
    _frequency = [f floatValue];
    
    self.region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake([xl floatValue], [yl floatValue])
                                                      radius:[rl floatValue]
                                                  identifier:self.UDID];
    if ([f floatValue] ==0)
    {
        [self.scheduler invalidate];
        self.scheduler = nil;
    }
    else
    {
//        [self deliverReminder];
        [self performSelectorOnMainThread:@selector(deliverReminder) withObject:nil waitUntilDone:NO];
    }
}

-(void) setLocationForLatitude:(NSString *) latitude longitude:(NSString *)longitude
{
    self.location = CGPointMake([latitude doubleValue], [longitude doubleValue]);
    self.latitude = latitude;
    self.longitude = longitude;
    // Add the pin only for masters or slaves
    if (![self.master isEqualToString:self.UDID])
         [self performSelectorOnMainThread:@selector(addPinForPoint:)
                            withObject:[[GeoLocation alloc] initWithLatitude:latitude longitude:longitude] waitUntilDone:NO];
}
-(void) setLocationForPoint:(CGPoint) location
{
    self.location  = location;
    [self performSelectorOnMainThread:@selector(addPinForPoint:) withObject:[[GeoLocation alloc] initWithLocation:location] waitUntilDone:NO];

}



-(void) setLocationForCoordinate:(NSString *) latitude longitude:(NSString *)longitude
{
    [self performSelectorOnMainThread:@selector(addPinForPoint:)
                           withObject:[[GeoLocation alloc] initWithLatitude:latitude longitude:longitude] waitUntilDone:NO];

    
}

- (void)addPinForPoint:(GeoLocation *) location
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake([location.x doubleValue],[location.y doubleValue]);
    NSMutableDictionary *pinObj = nil;
    if(_pin)
    {
        for (pinObj in [delegate getCoreLocationPinsArray])
        {
            if ([[pinObj objectForKey:@"pin"] isEqual: _pin])
            {
                // found the pin.
                MKCircle *circle = [pinObj objectForKey:@"circle"];
                [[delegate currentMapView] removeOverlay:circle];
                break;
            }
        }
    }
    [[delegate getCoreLocationPinsArray] removeObject:pinObj];
    NSString *routeTravel;
    if(_pin)
    {
        routeTravel = [NSString stringWithFormat:@"%.6f,%.6f\n%.6f,%.6f", _pin.coordinate.latitude,_pin.coordinate.longitude, point.latitude,point.longitude];
        [[delegate currentMapView] removeAnnotation:_pin];
        _pin =nil;
    }
    else
    {
        routeTravel = [NSString stringWithFormat:@"%.6f,%.6f\n%.6f,%.6f", point.latitude,point.longitude, point.latitude,point.longitude];

    }
    _pin = [[MKPointAnnotation alloc] init];
    _pin.coordinate = point;
    _pin.UDID = self.UDID;
    MKCircle *cle;
    if ([self isMaster] || [self.UDID isEqualToString:self.master])
    {
        _pin.title = [NSString stringWithFormat:@"Master:%@",[self.name stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
        if ([self.regionMonitored.r length] > 0)
        {
            NSString *rl = [self.regionMonitored.r stringByTrimmingCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
            cle = [MKCircle circleWithCenterCoordinate:point radius:[rl doubleValue]];
        }
    }
    else
    {
        _pin.title = [NSString stringWithFormat:@"%@ |%@",[self.name stringByReplacingOccurrencesOfString:@"%20" withString:@""], [self.masterName stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
        cle = [MKCircle circleWithCenterCoordinate:point radius:0]; // no circle for slave
    }

    NSMutableDictionary *coreLocationPin = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        _pin, @"pin",
                                        cle, @"circle",
                                        nil];
//
    [[delegate getCoreLocationPinsArray] addObject:coreLocationPin];
    [[delegate currentMapView] addAnnotation:_pin];
    [[delegate currentMapView] addOverlay: [self loadRouteFromNewLineSeparatedPoints:routeTravel]];
    [[delegate currentMapView] addOverlay: cle];//_circle];
}

-(void)addPinForPoint1:(GeoLocation *) location
{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
    view.draggable = YES;
    self.pinColorValue = 2;
    NSLog(@"self.pinColorValue %ld",self.pinColorValue);
    self.pinColor = [NSColor greenColor];
    view.pinColor = 1;
    return view;
}


-(void)deliverReminder{
    if (self.scheduler)
    {
        [self.scheduler invalidate];
        self.scheduler = nil;
    }
    if ([self.regionMonitored.r length]>0 && [self.regionMonitored.r floatValue]>0 && _frequency>0)
    {
        NSLog(@"Monitoring started for slave:%@",self.name);
        self.scheduler =[NSTimer scheduledTimerWithTimeInterval:_frequency target:self selector:@selector(checkIfWithinRegion) userInfo:nil repeats:YES];
        NSString *xl = [self.regionMonitored.x stringByTrimmingCharactersInSet:
                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *yl = [self.regionMonitored.y stringByTrimmingCharactersInSet:
                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        [self addPinForPoint:[[GeoLocation alloc] initWithLocation:CGPointMake([xl floatValue], [yl floatValue])]];
    }
}

-(void)sendMessage:(NSString *)message
{
    if (!self.pushSender)
    {
        self.pushSender =[[PushSender alloc] init];
        [self.pushSender connect];
    }
    self.pushSender.deviceToken = self.deviceToken;
    self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@\",\"badge\":1}}", [message stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
    [self.pushSender push];

}

-(void) checkIfWithinRegion
{
    if (self.region)
    {
        if ([self.region containsCoordinate:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue])])
        {
            if (_wentOutOfRegion)
            {
                // Slave came back into defined region
                // Send PUSH notification here for the slave came back within boundary
                NSLog(@"Slave :%@ is back within region", self.name);
                _wentOutOfRegion =NO;
                if (!self.pushSender)
                {
                    self.pushSender =[[PushSender alloc] init];
                    [self.pushSender connect];
                }
                self.pushSender.deviceToken = self.deviceToken;
                self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@ is back within region.\",\"badge\":1}}", [self.name stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
                [self.pushSender push];
            }
        }
        else
        {
            if (!_wentOutOfRegion)
            {
                // Send PUSH notification here for the slave went out of boundary
                NSLog(@"Slave :%@ is out of the defined region", self.name);
                if (!self.pushSender)
                {
                    self.pushSender =[[PushSender alloc] init];
                    [self.pushSender connect];
                }
                self.pushSender.deviceToken = self.deviceToken;
                self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@ is out of the region.\",\"badge\":1}}", [self.name stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
                
                [self.pushSender push];
                _wentOutOfRegion =YES;
            }
        }
    }
}

-(NSString *)description
{
    NSString *me = [NSString stringWithFormat:@"{\"Slave\":{\"UDID\":\"%@\",\"master\":\"%@\",\"location\":{\"x\":\"%f\",\"y\":\"%f\"}, \"speed\":\"%f\"}}", self.UDID, self.master, [self.latitude doubleValue], [self.longitude doubleValue], self.speed];


    NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
    [finalDict addEntriesFromDictionary:[self dictionaryRepresentation]];
    
    [finalDict removeObjectForKey:@"pushSender"];
    [finalDict removeObjectForKey:@"region"];
    [finalDict removeObjectForKey:@"scheduler"];
    [finalDict removeObjectForKey:@"routes"];
    NSLog(@"Slave:%@", finalDict);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString =@"";
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

-(MKPolyline*) loadRouteFromNewLineSeparatedPoints:(NSString*)pointStringsNewLines
{
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"route" ofType:@"csv"];
//    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    int currentCordCount = 0;
    NSArray* pointStrings = [pointStringsNewLines componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * pointStrings.count);
    NSLog(@"pointStrings:%@",pointStrings);
    for(int idx = 0; idx < pointStrings.count; idx++)
    {
        NSString* currentPointString = [pointStrings objectAtIndex:idx];
        NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSLog(@"latLonArr %@",latLonArr);
        if ([latLonArr count]>=2)
        {
            CLLocationDegrees latitude = [[latLonArr objectAtIndex:0] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            MKMapPoint point = MKMapPointMake(latitude, longitude);
            
            if (idx == 0) {
                northEastPoint = point;
                southWestPoint = point;
            }
            else
            {
                if (point.x > northEastPoint.x)
                    northEastPoint.x = point.x;
                if(point.y > northEastPoint.y)
                    northEastPoint.y = point.y;
                if (point.x < southWestPoint.x)
                    southWestPoint.x = point.x;
                if (point.y < southWestPoint.y)
                    southWestPoint.y = point.y;
            }
            
            pointArr[currentCordCount] = point;
            currentCordCount++;
        }
    }
    
    return [MKPolyline polylineWithCoordinates:pointArr count:currentCordCount];
    
//    _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    
//    free(pointArr);
//    
//    [self.mapView addOverlay:self.routeLine];

}

-(BOOL) isMaster
{
    return NO;
}
@end
