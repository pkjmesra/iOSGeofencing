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
//  RouteHistoryViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 22/11/12.
//
//

#import "RouteHistoryViewController.h"
#import "SBJsonParser.h"
#import "RoutesViewController.h"
#import "Constants.h"
#import "SendMessageViewController.h"

@interface RouteHistoryViewController ()

@end

@implementation RouteHistoryViewController
@synthesize mapView, currentLocation, receivedData, allSlaves, dateToShowRoute, slaveId, navItem,slaveName;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize arrRoutePoints;
@synthesize isPushed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.navItem.title = @"Today's Routes";
    self.receivedData = [[NSMutableData alloc] init];
    
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setDateFormat:@"yyyyMMdd"];
    self.dateToShowRoute = [fmtr stringFromDate:[NSDate date]];
    arrRoutePoints = [[NSMutableArray alloc] init];
    
    UIBarButtonItem* composeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
    self.navigationItem.leftBarButtonItem = composeBtn;
    [composeBtn release];
    
    UIBarButtonItem* HistoryBtn = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain  target:self action:@selector(routesDateButton:)];
    self.navigationItem.rightBarButtonItem = HistoryBtn;
    [HistoryBtn release];
    
    self.navigationItem.leftItemsSupplementBackButton =YES;
    
    [self initializeMap];

    [self getRoutePoints];
}

-(void) addBarButtons
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [self.view addSubview:bar];

    UINavigationItem *navItem1 = [[UINavigationItem alloc] initWithTitle:@"Routes"];

    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    navItem1.leftBarButtonItem = cancelBtn;
    [cancelBtn release];
    
    UIBarButtonItem* HistoryBtn = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain  target:self action:@selector(routesDateButton:)];
    navItem1.rightBarButtonItem = HistoryBtn;
    [HistoryBtn release];
    
    [bar pushNavigationItem:navItem1 animated:YES];
    [navItem1 release];
    [bar release];
}

- (void)dealloc {
    [receivedData release];
    [super dealloc];
}

-(void)getRoutePoints
{
    NSURLRequest *theRequest = nil;
    
    if (kUseStaticServerIP) {
        
            theRequest = [NSURLRequest
                          requestWithURL:[NSURL
                                          URLWithString:[NSString
                                                         stringWithFormat:@"http://172.17.10.25:1208/getroutes?master=%@&slave=%@&date=%@",[[UIDevice currentDevice] uniqueIdentifier], self.slaveId, self.dateToShowRoute]]];
    }else{
    
        NSString *stringURL =    [NSString
                                  stringWithFormat:@"%@/getroutes?master=%@&slave=%@&date=%@",
                                  kAppDelegate.serverIPURL,[[UIDevice currentDevice] uniqueIdentifier], self.slaveId, self.dateToShowRoute];
        
        NSLog(@"Request getroutes URL: %@", stringURL);
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];        
    }
    
    
    /* // Previous Implementation
     NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/getroutes?master=%@&slave=%@&date=%@",[[UIDevice currentDevice] uniqueIdentifier], self.slaveId, self.dateToShowRoute]]];*/
    
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
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
    NSArray *dataReceivedArray = [jsonParser objectWithString:json_string error:nil];
    [jsonParser release];
    [json_string release];
    
    if ([dataReceivedArray count] != 0) {
        NSMutableArray *pointsArray = [[NSMutableArray alloc] init];
        for (NSDictionary *aPoint in dataReceivedArray) {
            CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:[[aPoint valueForKey:@"x"] doubleValue] longitude:[[aPoint valueForKey:@"y"] doubleValue]];
            [pointsArray addObject:aLocation];
            [aLocation release];
        }
        self.arrRoutePoints = pointsArray;
        [pointsArray release];
        
        [self loadRoute];
        [self.mapView addOverlay:self.routeLine];
        [self zoomInOnRoute];
    }
    else
    {
        [self.mapView removeOverlays:[self.mapView overlays]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: nil
                              message: @"No routes found for the selected date."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
        [alert release];
    }
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
//    self.mapView.showsUserLocation = YES;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) composeMessage:(id)sender
{
    SendMessageViewController *messageController = [[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:[NSBundle mainBundle]];
    messageController.slaveId = self.slaveId;
    messageController.slaveName = self.slaveName;
    
    [self.navigationController pushViewController:messageController animated:YES];
    [messageController release];

}

-(IBAction)cancelButtonTapped:(id)sender
{
    if (isPushed)
    {
        isPushed = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self dismissModalViewControllerAnimated:NO];
}

-(IBAction)routesDateButton:(id)sender
{
    if ([[sender title] isEqualToString:@"History"])
    {
        NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
        [fmtr setDateFormat:@"yyyyMMdd"];
        self.dateToShowRoute = [fmtr stringFromDate:[NSDate date]];

        UIDatePicker *aDatepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 236.0f, 320.0f, 200.0f)];
        aDatepicker.datePickerMode = UIDatePickerModeDate;
        [aDatepicker setDate:[NSDate date]];
        [aDatepicker setMaximumDate:[NSDate date]];
        [aDatepicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:aDatepicker];
        [self.view bringSubviewToFront:aDatepicker];
        [aDatepicker release];
        [sender setTitle:@"Done"];
    }
    else
    {
        [sender setTitle:@"History"];
        for (UIView *aView in [self.view subviews]) {
            if ([aView isKindOfClass:[UIDatePicker class]]) {
                [aView removeFromSuperview];
            }
        }
        
        self.navItem.title = @"Routes History";
        [self getRoutePoints];
    }
}

-(void)dateChanged:(id)sender
{
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setDateFormat:@"yyyyMMdd"];
    self.dateToShowRoute = [fmtr stringFromDate:[sender date]];
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
	return overlayView;
}

@end
