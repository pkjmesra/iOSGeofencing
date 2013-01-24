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
//  ARHomeViewController.h
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 31/10/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARViewController.h"
#import "Defines.h"
#import "PlaceDetailController.h"

@class ARGeoViewController;
@class PoiImage;
@class ARHomeViewController;

@interface ARHomeViewController : UIViewController <ARViewDelegate, UIAlertViewDelegate, PlaceDetailProtocol> {
	ARGeoViewController	      *arViewController;
	CLLocationCoordinate2D	  currentRetrievedCoords;
	UINavigationController    *rootNavController;
	ObjectType                selectedType;
	
	//Keep all the lists here.
	NSMutableArray           *poiHotelList;
	NSMutableArray           *poiBankList;
	NSMutableArray           *poiHealthList;
	NSMutableArray           *poiEducationList;
    NSMutableArray           *poiImageList;
}
@property (nonatomic, retain) ARGeoViewController       *arViewController;
@property (nonatomic)         CLLocationCoordinate2D	currentRetrievedCoords;
@property (nonatomic, retain) UINavigationController    *rootNavController;
@property (nonatomic)         ObjectType                selectedType;
@property (nonatomic, retain) NSMutableArray            *poiHotelList;
@property (nonatomic, retain) NSMutableArray            *poiBankList;
@property (nonatomic, retain) NSMutableArray            *poiHealthList;
@property (nonatomic, retain) NSMutableArray            *poiEducationList;
@property (nonatomic, retain) NSMutableArray            *poiImageList;

//- (void)appDataRefreshed:(id)object;
- (void)getCurrentLocationCoordinates:(NSNotification*)notification;
- (void)homepageIconSelected:(int)iconIndex;

- (void)requestARObjects;
- (void)processCurrentLocation:(NSString *)notificationName;
- (void)appWillTerminate;
- (UIView *)viewForCoordinate:(ARDisCoordinate *)coordinate;
- (void)handleLockEventForAR;
- (void)handleUnlockEventForAR;
- (void)moveToMainPage;
- (NSString *)getDistanceLabel:(double)distance;
- (void)loadPoiImage:(NSArray *)array;
- (PoiImage *)getPoiImageForURL:(NSString *)imgURL;

- (IBAction)homeIconSelected:(id)sender;
- (IBAction)onBackBtn:(id)sender;

@end
