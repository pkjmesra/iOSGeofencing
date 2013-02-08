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
//  RoutesViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 26/11/12.
//
//

#import "RoutesViewController.h"
#import "SBJsonParser.h"
#import "GFLocationAnnotation.h"
#include <CoreGraphics/CGBase.h>
#include <CoreFoundation/CFDictionary.h>
#import "RouteHistoryViewController.h"
#import "SlaveCell.h"
#import "SendMessageViewController.h"
#import "Constants.h"

#define CHECKED_KEY @"checked"
#define ANIMATION_DURATION 0.5
@interface RoutesViewController ()

@end

@implementation RoutesViewController
@synthesize mapView, currentLocation, receivedData, allSlaves, tableView, checkedSlaveArray;

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
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    self.navigationController.title = @"My Reportees";
    
    UIBarButtonItem *lftBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = lftBtn;
    [lftBtn release];
    
    mapButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    UIImage *mapImage = [UIImage imageNamed:@"white_menu_icon.png"];
    [mapButton addTarget:self action:@selector(mapButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    mapButton.frame = CGRectMake(0.0,0.0,35,35);
    [mapButton setImage:mapImage forState:UIControlStateNormal];
    UIBarButtonItem *rtBtn = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
    self.navigationItem.rightBarButtonItem = rtBtn;
    [rtBtn release];
    
    self.receivedData = [[NSMutableData alloc] init];
    self.checkedSlaveArray = [[NSMutableArray alloc] init];
    
    [self initializeMap];
    [self getSlavesForMaster];
    isMapViewVisible = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc {
    [receivedData release];
    [checkedSlaveArray release];
    [mapButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)getSlavesForMaster
{
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
         theRequest = [NSURLRequest
                       requestWithURL:[NSURL
                                       URLWithString:[NSString
                                                      stringWithFormat:@"http://172.17.10.25:1208/getslaves?master=%@",
                                                      [[UIDevice currentDevice] uniqueIdentifier]]]];
    }else{
     
        NSString *stringURL =    [NSString
                                  stringWithFormat:@"%@/getslaves?master=%@",
                                  kAppDelegate.serverIPURL,
                                  [[UIDevice currentDevice] uniqueIdentifier]];
        
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    }    
    
    /* // Previous Implementation
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/getslaves?master=%@",[[UIDevice currentDevice] uniqueIdentifier]]]];*/
    
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
    self.allSlaves = [dataReceivedDictionary valueForKey:@"slaves"];
    for(NSDictionary *dict in self.allSlaves)
    {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        [mDict setObject:[NSNumber numberWithBool:YES] forKey:CHECKED_KEY];
        [self.checkedSlaveArray addObject:mDict];
        [mDict release];
    }
    
    [json_string release];
    [jsonParser release];
    if ([self.allSlaves count] == 0) {
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
    else
    {
        [self.tableView reloadData];
        [self drawAnnotationForSlaves];
    }
}

#pragma mark - Button Actions

-(void)mapButtonTapped:(id)sender
{
    UIView *fromView;
    UIView *toView;
    UIViewAnimationOptions animationOption;
    UIViewAnimationTransition animationTransition;
    UIImage *mapBtnImage;
    if(isMapViewVisible)
    {
        fromView = self.mapView;
        toView = self.tableView;
        animationOption = UIViewAnimationOptionTransitionFlipFromRight;
        animationTransition = UIViewAnimationTransitionFlipFromRight;
        mapBtnImage = [UIImage imageNamed:@"globe_map_icon.png"];
    }
    else
    {
        fromView = self.tableView;
        toView = self.mapView;
        animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
        animationTransition = UIViewAnimationTransitionFlipFromLeft;
        mapBtnImage = [UIImage imageNamed:@"white_menu_icon.png"];
    }
    isMapViewVisible = !isMapViewVisible;
    [UIView transitionFromView:fromView toView:toView duration:ANIMATION_DURATION options:animationOption completion:^(BOOL finished){
        [mapButton setImage:mapBtnImage forState:UIControlStateNormal];
    }];
    
    /*
    [UIView beginAnimations:@"flipbutton" context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationTransition:animationTransition forView:mapButton cache:YES];
    [mapButton setImage:mapBtnImage forState:UIControlStateNormal];
    [UIView commitAnimations];*/
}

-(void)checkBoxButtonTapped:(UIButton *)sender
{
    NSMutableDictionary *slaveDict = [self.checkedSlaveArray objectAtIndex:sender.tag];
    
    //SlaveCell *cell = [self findCellForButton:sender];
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //NSMutableDictionary *slaveDict = [self.checkedSlaveArray objectAtIndex:indexPath.row];
    BOOL value = [[slaveDict objectForKey:CHECKED_KEY] boolValue];
    [slaveDict setObject:[NSNumber numberWithBool:!value] forKey:CHECKED_KEY];
    sender.selected = !sender.selected;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self drawAnnotationForSlaves];
}

-(SlaveCell *)findCellForButton:(UIView *)btn
{
    if([btn isKindOfClass:[SlaveCell class]])
    {
        SlaveCell *cell = (SlaveCell *)btn;
        return cell;
    }
    else
        [self findCellForButton:btn.superview];
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)drawAnnotationForSlaves
{
    for (NSDictionary *aSlave in self.checkedSlaveArray) {
        if([[aSlave objectForKey:CHECKED_KEY]boolValue]){
            GFLocationAnnotation *anAnnotation = [[GFLocationAnnotation alloc] init];
            NSLog(@"%@", [aSlave valueForKey:@"location"]);
            
            NSString *aPointString = [aSlave valueForKey:@"location"];
            CGPoint aPoint = CGPointFromString(aPointString);
            CLLocationCoordinate2D aLocation;
            aLocation.latitude = aPoint.x;
            aLocation.longitude = aPoint.y;
            
            anAnnotation.coordinate = aLocation;
            anAnnotation.title = [[aSlave valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            anAnnotation.subtitle = @"View Routes";
            anAnnotation.slaveId = [aSlave valueForKey:@"UDID"];
            [self.mapView addAnnotation:anAnnotation];
            
            [anAnnotation release];
        }
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate

//- (void)showRoutes:(id)sender
//{
//    
//}

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
        RouteHistoryViewController *aController = [[RouteHistoryViewController alloc] initWithNibName:@"RouteHistoryViewController" bundle:[NSBundle mainBundle]];
        aController.slaveId = newannotation.slaveId;
        aController.slaveName = newannotation.title;
        aController.currentLocation = self.currentLocation;
        aController.isPushed = YES;
        [self.navigationController pushViewController:aController animated:YES];

        [aController release];
    }
    
    [self.mapView annotations];
    //    buttonDetail = (MyCustomAnnotationClass *)view.annotation;
    
    //show detail view using buttonDetail...
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    //
        // try to dequeue an existing pin view first
        static NSString* GFLocationAnnotationIdentifier = @"locationAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:GFLocationAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:GFLocationAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            [rightButton addTarget:self
//                            action:@selector(showRoutes:)
//                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RouteHistoryViewController *aController = [[RouteHistoryViewController alloc] initWithNibName:@"RouteHistoryViewController" bundle:[NSBundle mainBundle]];
    NSDictionary *aSlave = [self.checkedSlaveArray objectAtIndex:indexPath.row];
    aController.slaveId = [aSlave valueForKey:@"UDID"];
    aController.currentLocation = self.currentLocation;
    aController.isPushed = YES;
    [self.navigationController pushViewController:aController animated:YES];
    [aController release];
}

#pragma mark - Table View Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allSlaves count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SlaveCell";
    SlaveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSString *nibName = @"SlaveCell";
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        for(SlaveCell *slaveCell in nibContents)
        {   if([slaveCell isMemberOfClass:[SlaveCell class]])
            cell = slaveCell;
            break;
        }    
    }
    
    NSDictionary *aSlave = [self.checkedSlaveArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = [[aSlave valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    [cell.checkBoxButton addTarget:self action:@selector(checkBoxButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkBoxButton.selected = [[aSlave objectForKey:CHECKED_KEY] boolValue];
    cell.checkBoxButton.tag = indexPath.row;
    return cell;
}

@end
