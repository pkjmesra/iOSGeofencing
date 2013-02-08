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
//  os4MapsViewController.m
//  os4Maps
//

#import "GFMapViewController.h"
#import "RegexKitLite.h"
#import "GFLocationAnnotation.h"
#import "RouteHistoryViewController.h"
#import "SBJsonParser.h"
#import "Constants.h"
#import "SendMessageViewController.h"
#import "ZSPinAnnotation.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation GFMapViewController
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize arrRoutePoints, currentLocation;
@synthesize receivedData, allSlaves, allMasters;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    self.receivedData = [[NSMutableData alloc] init];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
//    [self setRoundedView:self.mapView toDiameter:200.0f];
//    self.mapView.layer.borderWidth = 2.0f;
//    self.mapView.layer.borderColor = [UIColor darkGrayColor].CGColor;

    [self.view addSubview:self.mapView];
    arrRoutePoints = [[NSMutableArray alloc] init];
    
    [self initializeMap];
    [self getSlavesForMaster];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timeIntervalEnded:) userInfo:nil repeats:YES];

//    [self drawAnnotationForDestination:self.currentLocation.coordinate];
//    CLLocationCoordinate2D initialLocation;
//    initialLocation.latitude = 21.15;
//    initialLocation.longitude = 79.083;
//    
//    CLLocationCoordinate2D desiredLocation;
//    desiredLocation.latitude = 26.233;
//    desiredLocation.longitude = 78.167;
    
//    arrRoutePoints = [self getRoutePointFrom:initialLocation to:desiredLocation];

//	[self loadRoute];
	
	// add the overlay to the map
//	if (nil != self.routeLine) {
//		[self.mapView addOverlay:self.routeLine];
//	}
	
	// zoom in on the route.
//	[self zoomInOnRoute];
}

- (void)timeIntervalEnded:(NSTimer*)timer {
//    if (hasSlaves) {
        [self getSlavesForMaster];
        [self getMyMasters];
//    }
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

// creates the route (MKPolyline) overlay
-(void) loadRoute
{
	MKMapPoint northEastPoint;
	MKMapPoint southWestPoint; 
	
	// create a c array of points. 
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * arrRoutePoints.count);
	
	for(int idx = 0; idx < arrRoutePoints.count; idx++)
	{        
        CLLocation *aLocation = [arrRoutePoints objectAtIndex:idx];
        
		CLLocationDegrees latitude  = aLocation.coordinate.latitude;
		CLLocationDegrees longitude = aLocation.coordinate.longitude;
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		// if it is the first point, just use them, since we have nothing to compare to yet. 
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

		pointArr[idx] = point;

	}
	
	// create the polyline based on the array of points. 
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:arrRoutePoints.count];

	_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
		
	// clear the memory allocated earlier for the points
	free(pointArr);
}

-(void) zoomInOnRoute
{
	[self.mapView setVisibleMapRect:_routeRect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc 
{
    [_mapView release];
    [_routeLine release];
    [_routeLineView release];
	self.mapView = nil;
	self.routeLine = nil;
	self.routeLineView = nil;
	[arrRoutePoints release];
    [super dealloc];
}

- (void)initializeMap
{    
    CLLocationCoordinate2D initialCoordinate;
    initialCoordinate.latitude = self.currentLocation.coordinate.latitude;
    initialCoordinate.longitude = self.currentLocation.coordinate.longitude;
    
    self.mapView.delegate = self;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(initialCoordinate, 200, 200) animated:YES];
    self.mapView.centerCoordinate = initialCoordinate;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
}

-(void)getMyMasters
{
    queryType = QueryTypeGetMasters;
    NSString *stringURL = nil;
    if (kUseStaticServerIP) {
        
        stringURL = @"http://172.17.10.25:1208/getmasters";
    }else{
        
        stringURL = [NSString stringWithFormat:@"%@/getmasters", kAppDelegate.serverIPURL];
    }
    
    NSLog(@"Request URL: %@", stringURL);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
    }
    else {
        NSLog(@"connection failed");
    }
    
    //    [theConnection release];
}

-(void)getSlavesForMaster
{
    queryType = QueryTypeGetSlaves;
    NSString *stringURL = nil;
    if (kUseStaticServerIP) {
        
        stringURL = [NSString stringWithFormat:@"http://172.17.10.25:1208/getslaves?master=%@",[[UIDevice currentDevice] uniqueIdentifier]];
    }else{
        
        stringURL = [NSString stringWithFormat:@"%@/getslaves?master=%@", kAppDelegate.serverIPURL, [[UIDevice currentDevice] uniqueIdentifier]];
    }
    NSLog(@"Request URL: %@", stringURL);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
    }
    else {
        NSLog(@"connection failed");
    }
    
    //    [theConnection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    UIAlertView *anErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [anErrorAlert show];
//    [anErrorAlert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");

    NSLog(@"%d",[receivedData length]);
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSString *json_string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *dataReceivedDictionary = [jsonParser objectWithString:json_string error:nil];
    
    switch (queryType) {
        case QueryTypeGetMasters:
        {
            NSString * udid = [[[UIDevice currentDevice] uniqueIdentifier] lowercaseString];
            self.allMasters = [dataReceivedDictionary valueForKey:@"masters"];
            NSMutableArray *myMasters = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *masterDict in self.allMasters) {
                NSMutableArray * slaves = [masterDict valueForKey:@"slaves"];
                for (NSDictionary *aSlave in self.allSlaves) {
                    if ([udid isEqualToString:[aSlave objectForKey:@"UDID"]])
                    {
                        [myMasters addObject:masterDict];
                    }
                }
            }
            self.allMasters = myMasters;
            if ([self.allMasters count] > 0) {
                [self drawAnnotationForSlaves:self.allMasters];
            }
            break;
        }
        
        case QueryTypeGetSlaves:
        {
            self.allSlaves = [dataReceivedDictionary valueForKey:@"slaves"];
            if ([self.allSlaves count] == 0 && !_monitoringStarted) {
                _monitoringStarted =YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: nil
                                      message: @"You are not monitoring anyone. Use tracker to start monitoring!"
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                alert.delegate = self;
                [alert show];
                [alert release];
            }
            else if ([self.allSlaves count] > 0)
            {
                hasSlaves = YES;
                [self drawAnnotationForSlaves:self.allSlaves];
            }
            break;
        }
        
        default:
        break;
    }
    
    [json_string release];
    [jsonParser release];
}

- (void)drawAnnotationForSlaves:(NSArray*)slaves
{
    self.mapView.showsUserLocation = YES;
    for (NSDictionary *aSlave in slaves) {
        NSString *aPointString = [aSlave valueForKey:@"location"];
        CGPoint aPoint = CGPointFromString(aPointString);
        CLLocationCoordinate2D aLocation;
        aLocation.latitude = aPoint.x;
        aLocation.longitude = aPoint.y;
        
        // Show all but yourself
        if (![[aSlave valueForKey:@"UDID"] isEqualToString:[[UIDevice currentDevice] uniqueIdentifier]])
        {
            GFLocationAnnotation *anAnnotation = [[GFLocationAnnotation alloc] init];
            NSLog(@"%@", [aSlave valueForKey:@"location"]);
            
            anAnnotation.coordinate = aLocation;
            anAnnotation.title = [[aSlave valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            anAnnotation.subtitle = [NSString stringWithFormat:@"Speed: %.2f Kmph", [[aSlave valueForKey:@"speed"] doubleValue]];
            anAnnotation.slaveId = [aSlave valueForKey:@"UDID"];
            anAnnotation.deviceSpeed = [[aSlave valueForKey:@"speed"] doubleValue];
            [self.mapView addAnnotation:anAnnotation];
            
            [anAnnotation release];
        }
        else
        {
            if (circleAdded && _circle)
            {
                [self.mapView removeOverlay:_circle];
                _circle =nil;
            }
//            NSLog(@"radius that we have here:%@",[[aSlave valueForKey:@"regionMonitored"] valueForKey:@"r"]);
            double radius = [[[aSlave valueForKey:@"regionMonitored"] valueForKey:@"r"] doubleValue];
            _circle = [MKCircle circleWithCenterCoordinate:aLocation radius:radius];
            [self.mapView addOverlay:_circle];
            circleAdded=YES;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        [self.mapView removeAnnotation:annotation];
    }
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    GFLocationAnnotation *anAnnotation = (GFLocationAnnotation *)annotation;

    // handle our two custom annotations
    //
    // try to dequeue an existing pin view first
    static NSString* GFLocationAnnotationIdentifier = @"locationAnnotationIdentifier";
    MKAnnotationView* pinView = (MKAnnotationView *)
    [self.mapView dequeueReusableAnnotationViewWithIdentifier:GFLocationAnnotationIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        if (pinView == nil){
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:anAnnotation reuseIdentifier:GFLocationAnnotationIdentifier] autorelease];
            //pinView.animatesDrop = YES;
        }
        
        // Build our annotation
        if ([anAnnotation isKindOfClass:[GFLocationAnnotation class]]) {
            
            UIColor *color = RGB(anAnnotation.deviceSpeed*2, 255-anAnnotation.deviceSpeed,0);
            
            GFLocationAnnotation *a = (GFLocationAnnotation *)anAnnotation;
            UIImage *image = [ZSPinAnnotation pinAnnotationWithColor:color];// ZSPinAnnotation Being Used
            pinView.image = [ZSPinAnnotation drawText:[NSString stringWithFormat:@"%.0f",anAnnotation.deviceSpeed] inImage:image atPoint:CGPointMake(1, 1)];
            pinView.annotation = a;
            pinView.enabled = YES;
            pinView.centerOffset=CGPointMake(6.5,-16);
            pinView.calloutOffset = CGPointMake(-11,0);
        }

        pinView.canShowCallout = YES;
    
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
        
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
        //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
        //
//        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        //            [rightButton addTarget:self
//        //                            action:@selector(showRoutes:)
//        //                  forControlEvents:UIControlEventTouchUpInside];
//        customPinView.rightCalloutAccessoryView = rightButton;
        
        return pinView;
    }
    else
    {
        UIColor *color = RGB(anAnnotation.deviceSpeed*2, 255-anAnnotation.deviceSpeed,0);
        
        UIImage *image = [ZSPinAnnotation pinAnnotationWithColor:color];// ZSPinAnnotation Being Used
        pinView.image = [ZSPinAnnotation drawText:[NSString stringWithFormat:@"%.0f",anAnnotation.deviceSpeed] inImage:image atPoint:CGPointMake(1, 1)];
        pinView.annotation = annotation;
    }
    return pinView;
}

- (NSMutableArray*)getRoutePointFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}


- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
        [latitude release];
        [longitude release];
        [loc release];
    }
    
    return [array autorelease];
}

#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
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
    else if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
        return [circleView autorelease];
    }

	return overlayView;
}

- (void)mapView:(MKMapView *)aMapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    if (view.annotation == aMapView.userLocation)
        return;
    
    
    if([view.annotation isKindOfClass:[GFLocationAnnotation class]])
    {
        GFLocationAnnotation *newannotation = (GFLocationAnnotation *)view.annotation;
        NSLog(@"Slave Id: %@", newannotation.slaveId);
        
        SendMessageViewController *messageController = [[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:[NSBundle mainBundle]];
        messageController.slaveId = newannotation.slaveId;
        messageController.slaveName = newannotation.title;
        
        AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [del.navigationController pushViewController:messageController animated:YES];
        [messageController release];
    }
}

- (void)drawAnnotationForDestination:(CLLocationCoordinate2D)destination
{    
    GFLocationAnnotation *destinationPoint = [[GFLocationAnnotation alloc] init];
    destinationPoint.coordinate = destination;
    destinationPoint.title = @"Test title";
    [self.mapView addAnnotation:destinationPoint];
    
    [destinationPoint release];
}

@end