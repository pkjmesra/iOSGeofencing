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
//  ShowRouteWindowViewController.m
//  GeofencingServer
//
//  Created by NAG1-LMAC-26589 on 26/11/12.
//
//

#import "ShowRouteWindowViewController.h"
#import "Master.h"
#import "Slave.h"
#import "AppDelegate.h"

@implementation ShowRouteWindowViewController
@synthesize master1;
@synthesize slaveUDID;
@synthesize dateToShowTheRoute;


-(void)windowDidLoad
{
    [mapView setShowsUserLocation: YES];
    [mapView setDelegate: self];
    
    self.dateToShowTheRoute = [[NSMutableString alloc] initWithCapacity:0];
    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    

    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setDateFormat:@"yyyyMMdd"];
    NSDate * date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [self.dateToShowTheRoute setString:[fmtr stringFromDate:date]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    [datePicker setDateValue:[dateFormat dateFromString:self.dateToShowTheRoute]];
    [datePicker setDelegate:self];
    
    if(callTimer)
    {
        [callTimer invalidate];
        callTimer=nil;
    }
    callTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(routeDrawWithDelay:) userInfo:nil repeats:NO];

    
}
-(void) windowWillLoad
{
    //    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    //    [fmtr setDateFormat:@"yyyyMMdd"];
    //    NSDate * date = [NSDate date];
    //    NSString *today = [fmtr stringFromDate:date];
    //    [datePicker setDateValue:[NSDate dateWithString:today]];
}

-(void)routeDrawWithDelay:(NSTimer *) timer
{
    if(callTimer)
    {
        [callTimer  invalidate];
        callTimer = nil;
    }
    [self showRoute];
}

#pragma mark - DatePicker Delegate
- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
validateProposedDateValue:(NSDate **)proposedDateValue
          timeInterval:(NSTimeInterval *)proposedTimeInterval
{
    NSLog(@"Proposed Date: %@",*proposedDateValue);
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"IST"]];
    [fmtr setDateFormat:@"yyyyMMdd"];

    NSString *changeDate = [fmtr stringFromDate:*proposedDateValue];
    NSLog(@"changed Date %@",changeDate);
    [self.dateToShowTheRoute setString:changeDate];
    NSLog(@"dateToShowTheRoute %@",self.dateToShowTheRoute);
    [self removeAnnotationAndOverlay];
    [self showRoute];
}



-(void) showRoute
{
    NSArray *routesForDate;
    BOOL slaveExists =NO;
    BOOL masterExists =NO;
    Master *foundMaster;
    NSArray * allMasters =delegate.masters;
    for(Master *ms in allMasters)
    {
        for(Slave *sl in ms.slaves)
        {
            if ([[sl UDID] isEqualToString:slaveUDID])
            {
                masterExists =YES;
                foundMaster = ms;
                foundSlave = sl;
                slaveExists =YES;
                break;
            }
        }
    }
    if (slaveExists)
    {
        NSString *routeTravel=@"";
        for (GeoLocation *gl in [foundSlave.routes objectForKey:self.dateToShowTheRoute])
        {
            routeTravel =[NSString stringWithFormat:@"%@%@,%@ \n",routeTravel,gl.x,gl.y];
        }
        
        if ([routeTravel length] >0)
        {
            CLLocationCoordinate2D point = CLLocationCoordinate2DMake(foundSlave.location.x ,foundSlave.location.y);
            GeoLocation *gL = [[GeoLocation alloc] initWithCoordinateLocation:point];
            // Add last location
            [self addPinForPoint:gL];
        }
        if([routeTravel length] >0)
        {
            pl =[self loadRouteFromNewLineSeparatedPoints:routeTravel];
            if (pl)
                [mapView performSelector:@selector(addOverlay:) withObject:pl afterDelay:1];
            
        }
    }
}

-(void) removeAnnotationAndOverlay
{
    [mapView removeAnnotation:_pin];
    [mapView removeOverlay:pl];
}
- (void)addPinForPoint:(GeoLocation *) location
{
    
    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake([location.x doubleValue],[location.y doubleValue]);
    NSMutableDictionary *pinObj = nil;
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
    
    MKCircle *cle;
    
    cle = [MKCircle circleWithCenterCoordinate:point radius:30];
    
    NSMutableDictionary *coreLocationPin = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            _pin, @"pin",
                                            cle, @"circle",
                                            nil];
    [[delegate getCoreLocationPinsArray] addObject:coreLocationPin];
    [mapView addAnnotation:_pin];
    [mapView addOverlay: [self loadRouteFromNewLineSeparatedPoints:routeTravel]];

}

-(MKPolyline*) loadRouteFromNewLineSeparatedPoints:(NSString*)pointStringsNewLines
{
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"route" ofType:@"csv"];
    //    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSCharacterSet *dontWantChar = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray* pointStrings = [pointStringsNewLines componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * pointStrings.count);
    NSLog(@"pointStrings:%@",pointStrings);
    int cordPoints = 0;
    for(int idx = 0; idx < pointStrings.count; idx++)
    {
        NSString* currentPointString = [pointStrings objectAtIndex:idx];
        NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        if ([latLonArr count]>=2)
        {
            CLLocationDegrees latitude = [[latLonArr objectAtIndex:0] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            MKMapPoint point = MKMapPointMake(latitude, longitude);
            
            pointArr[cordPoints] = point;
            ++cordPoints;
        }
    }
    
    return [MKPolyline polylineWithCoordinates:pointArr count:cordPoints];
}






#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    //NSLog(@"found placemark: %@", placemark);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //NSLog(@"MKReverseGeocoder didFailWithError: %@", error);
}

#pragma mark MKGeocoderDelegate

- (void)geocoder:(MKGeocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate
{
    //NSLog(@"MKGeocoder found (%f, %f) for %@", coordinate.latitude, coordinate.longitude, geocoder.address);
}

- (void)geocoder:(MKGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //NSLog(@"MKGeocoder didFailWithError: %@", error);
}

#pragma mark MapView Delegate

// Responding to Map Position Changes

- (void)mapView:(MKMapView *)aMapView regionWillChangeAnimated:(BOOL)animated
{
    //NSLog(@"mapView: %@ regionWillChangeAnimated: %d", aMapView, animated);
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"mapView: %@ regionDidChangeAnimated: %d", aMapView, animated);
}

//Loading the Map Data
- (void)mapViewWillStartLoadingMap:(MKMapView *)aMapView
{
    //NSLog(@"mapViewWillStartLoadingMap: %@", aMapView);
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)aMapView
{
    //NSLog(@"mapViewDidFinishLoadingMap: %@", aMapView);
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)aMapView withError:(NSError *)error
{
    //NSLog(@"mapViewDidFailLoadingMap: %@ withError: %@", aMapView, error);
}

// Tracking the User Location
- (void)mapViewWillStartLocatingUser:(MKMapView *)aMapView
{
    //NSLog(@"mapViewWillStartLocatingUser: %@", aMapView);
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)aMapView
{
    //NSLog(@"mapViewDidStopLocatingUser: %@", aMapView);
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //NSLog(@"mapView: %@ didUpdateUserLocation: %@", aMapView, userLocation);
}

- (void)mapView:(MKMapView *)aMapView didFailToLocateUserWithError:(NSError *)error
{
    // NSLog(@"mapView: %@ didFailToLocateUserWithError: %@", aMapView, error);
}

// Managing Annotation Views


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"mapView: %@ viewForAnnotation: %@", aMapView, annotation);
    //MKAnnotationView *view = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"] autorelease];
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
    NSLog(@"foundSlave.pinColorValue; %d",foundSlave.pinColorValue);
    view.pinColor = foundSlave.pinColorValue;
//    if ([annotation title] && [[annotation title] hasPrefix:@"Master"])
//        view.pinColor = MKPinAnnotationColorGreen;
//    else
//        view.pinColor =MKPinAnnotationColorRed;
    
    view.draggable = NO;
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"MarkerTest" ofType:@"png"];
    //NSURL *url = [NSURL fileURLWithPath:path];
    //view.imageUrl = [url absoluteString];
    return view;
}

- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views
{
    //NSLog(@"mapView: %@ didAddAnnotationViews: %@", aMapView, views);
}
/*
 - (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 NSLog(@"mapView: %@ annotationView: %@ calloutAccessoryControlTapped: %@", aMapView, view, control);
 }
 */

// Dragging an Annotation View
/*
 - (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)annotationView
 didChangeDragState:(MKAnnotationViewDragState)newState
 fromOldState:(MKAnnotationViewDragState)oldState
 {
 NSLog(@"mapView: %@ annotationView: %@ didChangeDragState: %d fromOldState: %d", aMapView, annotationView, newState, oldState);
 }
 */


// Selecting Annotation Views

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"mapView: %@ didSelectAnnotationView: %@", aMapView, view);
    //    [[NSColorPanel sharedColorPanel] orderFront:self];
    //    [[NSColorPanel sharedColorPanel] setTarget:self];
    //    [[NSColorPanel sharedColorPanel] setAction:@selector(changeColor:)];
    
}

-(void) changeColor:(id) sender
{
    //[[self selectedGraphics] makeObjectsPerformSelector:@selector(setColor:) withObject:[sender color]];
    float color[4];
    NSColor* colors = [[sender color] colorUsingColorSpaceName:
                    @"NSCalibratedRGBColorSpace"];
    color[0] = [colors redComponent];
    color[1] = [colors greenComponent];
    color[2] = [colors blueComponent];
    color[3] = [colors alphaComponent];
    
    NSLog(@"color [0] %f,color [1] %f,color [2] %f,color [3] %f",color[0],color[1],color[2],0.4);
}



- (void)mapView:(MKMapView *)aMapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"mapView: %@ didDeselectAnnotationView: %@", aMapView, view);
}


// Managing Overlay Views

- (MKOverlayView *)mapView:(MKMapView *)aMapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"mapView: %@ viewForOverlay: %@", aMapView, overlay);
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
        return circleView;
    }
    /*
     MKOverlayView* overlayView = nil;
     
     if(overlay == self.routeLine)
     {
     //if we have not yet created an overlay view for this overlay, create it now.
     if(nil == self.routeLineView)
     {
     self.routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
     self.routeLineView.fillColor = [UIColor redColor];
     self.routeLineView.strokeColor = [UIColor redColor];
     self.routeLineView.lineWidth = 3;
     }
     
     overlayView = self.routeLineView;
     
     }
     
     return overlayView;
     */
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    return polylineView;
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    return polygonView;
}

- (void)mapView:(MKMapView *)aMapView didAddOverlayViews:(NSArray *)overlayViews
{
    //NSLog(@"mapView: %@ didAddOverlayViews: %@", aMapView, overlayViews);
}

- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    //NSLog(@"mapView: %@ annotationView: %@ didChangeDragState:%d fromOldState:%d", aMapView, annotationView, newState, oldState);
    //
    //    if (newState ==  MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateNone)
    //    {
    //        // create a new circle view
    //        MKPointAnnotation *pinAnnotation = annotationView.annotation;
    //        for (NSMutableDictionary *pin in coreLocationPins)
    //        {
    //            if ([[pin objectForKey:@"pin"] isEqual: pinAnnotation])
    //            {
    //                // found the pin.
    //                MKCircle *circle = [pin objectForKey:@"circle"];
    //                CLLocationDistance pinCircleRadius = circle.radius;
    //                [aMapView removeOverlay:circle];
    //
    //                circle = [MKCircle circleWithCenterCoordinate:pinAnnotation.coordinate radius:pinCircleRadius];
    //                [pin setObject:circle forKey:@"circle"];
    //                [aMapView addOverlay:circle];
    //            }
    //        }
    //    }
    //    else {
    //        // find old circle view and remove it
    //        MKPointAnnotation *pinAnnotation = annotationView.annotation;
    //        for (NSMutableDictionary *pin in coreLocationPins)
    //        {
    //            if ([[pin objectForKey:@"pin"] isEqual: pinAnnotation])
    //            {
    //                // found the pin.
    //                MKCircle *circle = [pin objectForKey:@"circle"];
    //                [aMapView removeOverlay:circle];
    //            }
    //        }
    //    }
    //
    //
    //MKPointAnnotation *annotation = annotationView.annotation;
    //NSLog(@"annotation = %@", annotation);
    
}

// MacMapKit additions
- (void)mapView:(MKMapView *)aMapView userDidClickAndHoldAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    return;
    //NSLog(@"mapView: %@ userDidClickAndHoldAtCoordinate: (%f, %f)", aMapView, coordinate.latitude, coordinate.longitude);
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinate;
    pin.title = @"Hi.";
    [mapView addAnnotation:pin];
}

- (NSArray *)mapView:(MKMapView *)mapView contextMenuItemsForAnnotationView:(MKAnnotationView *)view
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Delete It" action:@selector(delete:) keyEquivalent:@""];
    return [NSArray arrayWithObject:item];
}


-(MKMapView *)currentMapView
{
    return mapView;
}


#pragma mark - extended Callout view options
- (void)mapView:(MKMapView *)mapView didSelectAnnotationRouteHistory:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationRouteHistory");
    
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationSendMessage:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationSendMessage");
}
- (void)mapView:(MKMapView *)mapView delegateSelectedAnnotationPaletteChange:(MKAnnotationView *)view
{
    NSLog(@"delegateSelectedAnnotationPaletteChange");
}

@end
