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

#import "AppDelegate.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Master.h"
#import "ShowRouteWindowViewController.h"
#import "SendMessageWindowController.h"


// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@implementation AppDelegate
@synthesize masters =_masters;
//@synthesize window=_window;
@synthesize pinTitle=_pintitle;

+ (BOOL) AMCEnabled
{
    return YES;
}

-(void)saveContentData
{
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self filePathWithSuffix:@"Content"];
    NSDictionary *dictRepr =[self dictionaryRepresentation];
    NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
    [finalDict addEntriesFromDictionary:dictRepr];
    NSArray * msters = [finalDict objectForKey:@"masters"];
    [finalDict removeObjectForKey:@"window"];
    [finalDict removeObjectForKey:@"pinTitle"];
    
    if ([msters count]>0)
    {
        for (NSMutableDictionary *mstr in msters) {
            NSArray *slvs =[mstr objectForKey:@"slaves"];
            if ([slvs count]>0)
            {
                for (NSMutableDictionary *slv in slvs) {
                    [slv removeObjectForKey:@"pushSender"];
                    [slv removeObjectForKey:@"region"];
                    [slv removeObjectForKey:@"scheduler"];
//                    [slv removeObjectForKey:@"routes"];
                }
            }
        }
    }
    NSLog(@"Saving data to disk:\n%@",finalDict);
    if ([finalDict writeToFile: path atomically:YES])
    {
        NSLog(@"Saved data to disk @ %@\n",path);
    }
    else
        NSLog(@"Failed saving data to disk @ %@\n",path);
}

-(void) applicationWillTerminate:(NSNotification *)aNotification
{
    [self saveContentData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
//	[httpServer setType:@"_http._tcp."];
	
	// Note: Clicking the bonjour service in Safari won't work because Safari will use http and not https.
	// Just change the url to https for proper access.
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	[httpServer setPort:1208];
	
	// We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
	// This allows us to customize the server for things such as SSL and password-protection.
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	// Serve files from the standard Sites folder
	NSString *docRoot = [@"~/Sites" stringByExpandingTildeInPath];
	DDLogInfo(@"Setting document root: %@", docRoot);
	
	[httpServer setDocumentRoot:docRoot];
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
    [self performApplicationDidFinishLaunching];
    self.masters = [NSMutableArray arrayWithCapacity:0];
    NSString *path = [self filePathWithSuffix:@"content"];
    AppDelegate *mstrs = [AppDelegate objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]];
//    NSLog(@"mstrs:%@",mstrs);
    if(mstrs)
    {
        self.masters = mstrs.masters;
        for (Master *ms in self.masters) {
            // check to see if masters have their locations set ?
            if (ms.location.x !=0 || ms.location.y !=0)
            {
                [ms performSelector:@selector(addPinForPoint:) withObject:[[GeoLocation alloc] initWithLocation:ms.location] afterDelay:5];
                [self performSelector:@selector(setCenterCoordinateAtLastMaster:) withObject:ms afterDelay:5];
            }
            for (Slave *sl in ms.slaves) {
                // check to see if masters have their locations set ?
                if (sl.location.x !=0 || sl.location.y !=0)
                {
                    // Drop a pin and draw a circle around the last known location
                    [sl performSelector:@selector(addPinForPoint:) withObject:[[GeoLocation alloc] initWithLocation:sl.location] afterDelay:5];
                    
                    // Draw the route history for the slaves, only for today
                    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
                    [fmtr setDateFormat:@"yyyyMMdd"];
                    NSDate * date = [NSDate date];
                    NSString *today = [fmtr stringFromDate:date];
                    NSString *routeTravel=@"";
                    NSLog(@"sl.routes:%@",sl.routes);
                    for (GeoLocation *gl in [sl.routes objectForKey:today])
                    {
                        NSLog(@"GeoLocation:%@: X:%@ , Y:%@",gl, gl.x,gl.y);
                        routeTravel =[NSString stringWithFormat:@"%@%@,%@\n ",routeTravel,gl.x,gl.y];
                    }
                    
                    if ([routeTravel length] >0)
                    {
                        // Add last location
                        routeTravel =[NSString stringWithFormat:@"%@%f,%f\n ",routeTravel,sl.location.x,sl.location.y];
                        NSLog(@"routeTravel with last location included:%@",routeTravel);
                        // Found some coordinates in today's route
                        MKPolyline *pl =[sl loadRouteFromNewLineSeparatedPoints:routeTravel];
                        if (pl)
                            [[self currentMapView] performSelector:@selector(addOverlay:) withObject:pl afterDelay:10];
                    }
                }
                if (sl.regionMonitored)
                {
                    [sl setRegionX:sl.regionMonitored.x
                                 Y:sl.regionMonitored.y
                            Radius:sl.regionMonitored.r
                         Frequency:sl.regionMonitored.frequency];
                }
            }
        }
    }
    [self performSelector:@selector(addAdditionalCSS:) withObject:nil afterDelay:3.0];
    
}

-(void) setCenterCoordinateAtLastMaster:(Master *)ms
{
    [[self currentMapView] setCenterCoordinate:CLLocationCoordinate2DMake(ms.location.x, ms.location.y)];
}

-(NSString *)description
{
    NSString *me = @"{\"Masters\":";
    
    int i=0;
    for (Master *ms in self.masters) {
        if (i<=0)
            me = [NSString stringWithFormat:@"%@ %@",me,[ms description]];
        else
            me = [NSString stringWithFormat:@"%@, %@",me,[ms description]];
        i++;
    }
    me = [NSString stringWithFormat:@"%@}",me];

    NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
    [finalDict addEntriesFromDictionary:[self dictionaryRepresentation]];
    NSArray * msters = [finalDict objectForKey:@"masters"];
    [finalDict removeObjectForKey:@"window"];
    [finalDict removeObjectForKey:@"pinTitle"];
    if ([msters count]>0)
    {
        for (NSMutableDictionary *mstr in msters) {
            NSArray *slvs =[mstr objectForKey:@"slaves"];
            if ([slvs count]>0)
            {
                for (NSMutableDictionary *slv in slvs) {
                    [slv removeObjectForKey:@"pushSender"];
                    [slv removeObjectForKey:@"region"];
                    [slv removeObjectForKey:@"scheduler"];
                    [slv removeObjectForKey:@"routes"];                    
                }
            }
        }
    }

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

- (NSString *) filePathWithSuffix: (NSString *) aSuffix
{
    if (!aSuffix)
        aSuffix = @"";
    
    NSString *filename = [NSString stringWithFormat:@"%@%@.plist", [self className], aSuffix ];
    
    NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent: filename ];
	return fullPath;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
	return YES;
}

#pragma mark-
#pragma mark -Mapkit

- (void)performApplicationDidFinishLaunching
{
    //NSLog(@"applicationDidFinishLaunching:");
    [mapView setShowsUserLocation: YES];
    [mapView setDelegate: self];
    
    pinNames = [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", @"Eleven", @"Twelve", nil];
    
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 21.10;
    coordinate.longitude = 79.16;
    MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate: coordinate];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
    
    coreLocationPins = [NSMutableArray array];
    
    MKGeocoder *geocoderNoCoord = [[MKGeocoder alloc] initWithAddress:@"46, Harihar Nagar, Lambent IT Park, Besa, Nagpur"];
    geocoderNoCoord.delegate = self;
    [geocoderNoCoord start];
    
    MKGeocoder *geocoderCoord = [[MKGeocoder alloc] initWithAddress:@"Besa, Nagpur, India" nearCoordinate:coordinate];
    geocoderCoord.delegate = self;
    [geocoderCoord start];
    
}

- (IBAction)setMapType:(id)sender
{
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    [mapView setMapType:[segmentedControl selectedSegment]];
}

- (IBAction)addCircle:(id)sender
{
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:[mapView centerCoordinate] radius:[circleRadius intValue]];
    [mapView addOverlay:circle];
}

- (IBAction)addPin:(id)sender
{
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = [mapView centerCoordinate];
    pin.title = self.pinTitle;
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:[mapView centerCoordinate] radius:0];
    
    NSMutableDictionary *coreLocationPin = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            pin, @"pin",
                                            circle, @"circle",
                                            nil];
    
    [coreLocationPins addObject:coreLocationPin];
    
    [mapView addAnnotation:pin];
    [mapView addOverlay:circle];
}

- (IBAction)searchAddress:(id)sender
{
    [mapView showAddress:[addressTextField stringValue]];
}

- (IBAction)demo:(id)sender
{
    for (int i = 0; i<[pinNames count]; i++)
    {
        [self performSelector:@selector(addPinForIndex:) withObject:[NSNumber numberWithInt:i] afterDelay: i * 0.25];
    }
}

- (void)addPinForIndex:(NSNumber *)indexNumber
{
    CLLocationCoordinate2D centerCoordinate = [mapView centerCoordinate];
    NSUInteger total = [pinNames count];
    NSUInteger index = [indexNumber intValue];
    double maxLatOffset = 0.01;
    double maxLngOffset = 0.02;
    NSString *name = [pinNames objectAtIndex:[indexNumber intValue]];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D pinCoord = centerCoordinate;
    double latOffset = maxLatOffset * cosf(2*M_PI * ((double)index/(double)total));
    double lngOffset = maxLngOffset * sinf(2*M_PI * ((double)index/(double)total));
    pinCoord.latitude += latOffset;
    pinCoord.longitude += lngOffset;
    pin.coordinate = pinCoord;
    pin.title = name;
    [mapView addAnnotation:pin];
    
}

- (IBAction)addAdditionalCSS:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MapViewAdditions" ofType:@"css"];
    [mapView performSelector:@selector(addStylesheetTag:) withObject:path afterDelay:1.0];
}

- (IBAction)searchDeviceAction:(id)sender
{
    NSTextField * textField =(NSTextField *)sender;
    NSString *searchText = [textField stringValue];
    NSMutableArray * foundObjArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *arr = [[searchText lowercaseString] componentsSeparatedByString:@" "];
    for(NSString * str1 in arr)
    {
        for(Master *master in self.masters)
        {
            for(Slave *sl in master.slaves)
            {
                NSArray *nameArr = [[sl.name lowercaseString] componentsSeparatedByString:@" "];
                NSRange  rng =[[sl.name lowercaseString] rangeOfString:[str1 lowercaseString]];
                if([nameArr containsObject:str1] ||
                   rng.location !=NSNotFound)
                {
                    [foundObjArr addObject:sl];
                }
            }
            NSArray *nameArr = [[master.name lowercaseString] componentsSeparatedByString:@" "];
            NSRange  rngMaster =[[master.name lowercaseString] rangeOfString:[str1 lowercaseString]];
            if([nameArr containsObject:str1] || rngMaster.location !=NSNotFound)
            {
                [foundObjArr addObject:master];
            }
        }
    }

    int maxFind=0;
    int curFind =0;
    Slave *bestMatch;
    for (id element in [NSSet setWithArray:foundObjArr])
    {
        Slave *sl = (Slave *)element;
        for (int i=[foundObjArr count]-1; i>= 0; i--)
        {
            Slave *slc = [foundObjArr objectAtIndex:i];
            if ([sl.UDID isEqualToString:slc.UDID])
            {
                [foundObjArr removeObject:slc];
                curFind++;
                if (maxFind <curFind)
                {
                    bestMatch = sl;
                    maxFind =curFind;
                }
//                NSLog(@"maxFind:%d, curFind:%d, bestmatch:%@",maxFind,curFind,bestMatch);
            }
        }
    }
    
    if ([bestMatch.latitude length] >0 && [bestMatch.longitude length]>0)
        [mapView setCenterCoordinate:CLLocationCoordinate2DMake([bestMatch.latitude doubleValue], [bestMatch.longitude doubleValue])];
    else if (bestMatch.location.x != CGPointZero.x && bestMatch.location.y != CGPointZero.y)
        [mapView setCenterCoordinate:CLLocationCoordinate2DMake(bestMatch.location.x, bestMatch.location.y)];
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
    //NSLog(@"mapView: %@ viewForAnnotation: %@", aMapView, annotation);
    //MKAnnotationView *view = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"] autorelease];
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
    if ([annotation title] && [[annotation title] hasPrefix:@"Master"])
        view.pinColor = MKPinAnnotationColorGreen;
    else
        view.pinColor =MKPinAnnotationColorRed;
    
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
}

-(void) changeColor:(id) sender
{
    //[[self selectedGraphics] makeObjectsPerformSelector:@selector(setColor:) withObject:[sender color]];
    float color[4];
    NSColor* someColor = [[sender color] colorUsingColorSpaceName:
                       @"NSCalibratedRGBColorSpace"];
    
    uint8_t r = (uint8_t)(MIN(1.0f, MAX(0.0f, [someColor redComponent])) * 255.0f);
    uint8_t g = (uint8_t)(MIN(1.0f, MAX(0.0f, [someColor greenComponent])) * 255.0f);
    uint8_t b = (uint8_t)(MIN(1.0f, MAX(0.0f, [someColor blueComponent])) * 255.0f);
    uint8_t a = (uint8_t)(MIN(1.0f, MAX(0.0f, [someColor alphaComponent])) * 255.0f);
    
    color[0] = r;
    color[1] = g;
    color[2] = b;
    color[3] = a;
    
    const CGFloat* components;
    components = CGColorGetComponents((__bridge CGColorRef)someColor);
    NSString *colors;
    if ([someColor alphaComponent] <1.0f)
        colors = [NSString stringWithFormat:@"#%0.8X",
             (r << 24) + (g << 16) + (b << 8) + a];
    else
        colors = [NSString stringWithFormat:@"#%0.6X",
                  (r << 16) + (g << 8) + b];
    
//    NSLog(@"colors:%@, color [0] %f,color [1] %f,color [2] %f,color [3] %f",colors,color[0],color[1],color[2],color[3]);
    [mapView updateAnnotationColor:colors annotation:_currentAnnotationView.annotation scriptObject:_currentScriptObject];
}



- (void)mapView:(MKMapView *)aMapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"mapView: %@ didDeselectAnnotationView: %@", aMapView, view);
}


// Managing Overlay Views

- (MKOverlayView *)mapView:(MKMapView *)aMapView viewForOverlay:(id <MKOverlay>)overlay
{
    //NSLog(@"mapView: %@ viewForOverlay: %@", aMapView, overlay);
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
    
    if (newState ==  MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateNone)
    {
        // create a new circle view
        MKPointAnnotation *pinAnnotation = annotationView.annotation;
        for (NSMutableDictionary *pin in coreLocationPins)
        {
            if ([[pin objectForKey:@"pin"] isEqual: pinAnnotation])
            {
                // found the pin.
                MKCircle *circle = [pin objectForKey:@"circle"];
                CLLocationDistance pinCircleRadius = circle.radius;
                [aMapView removeOverlay:circle];
                
                circle = [MKCircle circleWithCenterCoordinate:pinAnnotation.coordinate radius:pinCircleRadius];
                [pin setObject:circle forKey:@"circle"];
                [aMapView addOverlay:circle];
            }
        }
    }
    else {
        // find old circle view and remove it
        MKPointAnnotation *pinAnnotation = annotationView.annotation;
        for (NSMutableDictionary *pin in coreLocationPins)
        {
            if ([[pin objectForKey:@"pin"] isEqual: pinAnnotation])
            {
                // found the pin.
                MKCircle *circle = [pin objectForKey:@"circle"];
                [aMapView removeOverlay:circle];
            }
        }
    }
    
    
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

-(NSMutableArray *)getCoreLocationPinsArray
{
    return coreLocationPins;
}

-(MKMapView *)currentMapView
{
    return mapView;
}


#pragma mark - extended Callout view options
- (void)mapView:(MKMapView *)mapView didSelectAnnotationRouteHistory:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationRouteHistory");
    showRouteWindow = [[ShowRouteWindowViewController alloc] initWithWindowNibName:@"ShowRouteWindowViewController"];
    showRouteWindow.master1 = view.annotation.title;

    showRouteWindow.slaveUDID = view.annotation.UDID;
//    [showRouteWindow.window makeKeyAndOrderFront:self];    
//    [showRouteWindow showWindow:self];
    
    NSWindow * pWindow = [showRouteWindow window];
    [NSApp runModalForWindow: pWindow];
    [NSApp endSheet: pWindow];
    [pWindow orderOut: self];
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationSendMessage:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationSendMessage");
    sendMessageWC = [[SendMessageWindowController alloc] initWithWindowNibName:@"SendMessageWindowController"];
    sendMessageWC.slaveUDID = view.annotation.UDID;
    [sendMessageWC.window makeKeyAndOrderFront:self];
    [sendMessageWC showWindow:self];
}
- (void)mapView:(MKMapView *)mapView delegateSelectedAnnotationPaletteChange:(MKAnnotationView *)view
     withObject:(WebScriptObject *)scriptObject
{
    NSLog(@"delegateSelectedAnnotationPaletteChange");
    [[NSColorPanel sharedColorPanel] orderFront:self];
    [[NSColorPanel sharedColorPanel] setTarget:self];
    [[NSColorPanel sharedColorPanel] setAction:@selector(changeColor:)];
    _currentAnnotationView = view;
    _currentScriptObject = scriptObject;
}

-(void) addMessageBox
{
    return;
    sendMessageWC = [[SendMessageWindowController alloc] initWithWindowNibName:@"SendMessageWindowController"];
    [sendMessageWC.window makeKeyAndOrderFront:self];
    [sendMessageWC showWindow:self];

}



@end
