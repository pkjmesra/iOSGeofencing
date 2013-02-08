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
//  RouteHistoryViewController.h
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 22/11/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RouteHistoryViewController : UIViewController <MKMapViewDelegate>
{
    MKMapView *mapView;
    CLLocation *currentLocation;
    NSMutableData *receivedData;
    NSMutableArray *allSlaves;
    NSString *dateToShowRoute;
    NSString *slaveId;
    MKPolyline* _routeLine;
    NSMutableArray *arrRoutePoints;
	MKPolylineView* _routeLineView;
	MKMapRect _routeRect;
    BOOL isPushed;
    UINavigationItem *navItem;
}

@property(nonatomic, strong) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic,retain) NSMutableData *receivedData;
@property (nonatomic,retain) NSMutableArray *allSlaves;
@property (nonatomic,retain) NSString *dateToShowRoute;
@property (nonatomic,retain) NSString *slaveId;
@property (nonatomic,retain) NSString *slaveName;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property(nonatomic, strong) NSMutableArray *arrRoutePoints;
@property(assign) BOOL isPushed;
@property(nonatomic, strong) IBOutlet UINavigationItem *navItem;
-(void) addBarButtons;
@end
