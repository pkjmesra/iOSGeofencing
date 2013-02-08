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
//  ARHomeViewController.m
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 31/10/12.
//
//

#import "ARHomeViewController.h" 
#import "AppObjects.h"
#import "Helper.h"

#import "ARGeoViewController.h"
#import "LocationService.h"
#import "ARAnnotationView.h"
#import "Defines.h"
#import "PlaceDetailController.h"
#import "ARCompassView.h"

@interface ARHomeViewController ()

@end

@implementation ARHomeViewController
@synthesize arViewController, currentRetrievedCoords, rootNavController, selectedType;
@synthesize poiHotelList, poiBankList, poiHealthList, poiEducationList, poiImageList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentRetrievedCoords.latitude = 0.0;
        currentRetrievedCoords.longitude = 0.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showARScreen:) name:NEARBY_AR_NOTIFICATION object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self loadHomeButton];
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_background_linen.png"]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor darkTextColor]];
    self.title = @"Point of Interest";
    [self.view setUserInteractionEnabled:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.rootNavController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Custom Methods

- (void) loadHomeButton
{
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)] autorelease];
    [button setBackgroundImage:[UIImage imageNamed:@"home-m.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *homeButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    self.navigationItem.leftBarButtonItem = homeButton;
}

- (IBAction)onBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeIconSelected:(id)sender
{
	UIButton *homeButton = (UIButton *)sender;
	NSString *title = homeButton.titleLabel.text;
	int itemValue = [title intValue];
	[self homepageIconSelected:itemValue];
}

-(void)getCurrentLocationCoordinates:(NSNotification*)notification
{
	LocationService *locationService = [LocationService sharedLocationService];
	currentRetrievedCoords = [locationService getCurrentLocation];
}

- (int)getDistancePlacesInt:(double)distance
{
	int mantissa = (int)distance;
	return mantissa;
}

- (NSString *)getDistanceLabel:(double)distance
{
	NSMutableString *distanceLabel = nil;
	int dist = [self getDistancePlacesInt:distance];
	if(dist > 0)
	{
		distanceLabel = [[NSMutableString new]autorelease];
		int kmValue = dist/1000;
		if(kmValue > 0)
			[distanceLabel appendFormat:KM_STR, kmValue];
		int mValue = dist%1000;
		if(mValue > 0)
			[distanceLabel appendFormat:MTR_STR, mValue];
		else
			[distanceLabel replaceCharactersInRange:NSMakeRange([distanceLabel length]-1, 1) withString:@""];
	}
	else
	{
		dist = 0;
		distanceLabel = [[NSMutableString new]autorelease];
		[distanceLabel appendFormat:MTR_STR, dist];
	}
	return distanceLabel;
}

- (ObjectType)getSelectedObjectType:(HomePageIconIndex)index
{
	switch (index)
	{
		case POIBANK_INDEX:
			return POIBANK;
		case POIEDUCATION_INDEX:
			return POIEDUCATION;
		case POIHEALTH_INDEX:
			return POIHEALTH;
		case POIHOTEL_INDEX:
			return POIHOTEL;
		default:
			return NONE;
	}
}

- (id)getObject:(NSString*)objectD objectType:(ObjectType)type
{
	NSMutableArray* objectList = nil;
	switch (type)
	{
		case POIBANK:
			objectList = self.poiBankList;
			break;
		case POIHOTEL:
			objectList = self.poiHotelList;
			break;
		case POIEDUCATION:
			objectList = self.poiEducationList;
			break;
		case POIHEALTH:
			objectList = self.poiHealthList;
			break;
        case NONE:
        case POI:
            objectList = nil;
            break;
	}
	
	if(objectList != nil)
	{
		NSEnumerator *enumerator = [objectList objectEnumerator];
		Poi*  object = nil;
		while ((object = [enumerator nextObject]) != nil)
		{
			if([objectD isEqualToString:object.iD])
			{
				//this object  is available in the list
				return object;
			}
		}
	}
	return nil;
	
}

- (NSMutableArray *)getObjectList
{
	NSMutableArray *objectList = nil;
	switch (self.selectedType)
	{
		case POIBANK:
			if(self.poiBankList == nil)
				self.poiBankList = [AppObjectConvertor getObjectListForObjectType:self.selectedType];
			objectList = self.poiBankList;
			break;
		case POIHOTEL:
			if(self.poiHotelList == nil)
				self.poiHotelList = [AppObjectConvertor getObjectListForObjectType:self.selectedType];
			objectList = self.poiHotelList;
			break;
		case POIEDUCATION:
			if(self.poiEducationList == nil)
				self.poiEducationList = [AppObjectConvertor getObjectListForObjectType:self.selectedType];
			objectList = self.poiEducationList;
			break;
		case POIHEALTH:
			if(self.poiHealthList == nil)
				self.poiHealthList = [AppObjectConvertor getObjectListForObjectType:self.selectedType];
			objectList = self.poiHealthList;
			break;
        case POI:
        case NONE:
            objectList = nil;
            break;
	}
	return objectList;
}

- (PoiImage *)getPoiImageForURL:(NSString *)imgURL
{
    PoiImage *img = nil;
    if(self.poiImageList != nil)
    {
        NSEnumerator *enumerator = [poiImageList objectEnumerator];
        while ((img = [enumerator nextObject]) != nil)
        {
            if([img.imgURL isEqualToString:imgURL])
                break;
        }
    }
    return img;
}

- (void)loadPoiImage:(NSArray *)array
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *imgURL = nil;
    PlaceDetailController *detailController = nil;
    NSEnumerator *enumerator = [array objectEnumerator];
    id object = nil;
    while ((object = [enumerator nextObject]) != nil)
    {
        if([object isKindOfClass:[NSString class]])
            imgURL = (NSString *)object;
        else if([object isKindOfClass:[PlaceDetailController class]])
            detailController = (PlaceDetailController *)object;
    }
    
    if(imgURL != nil)
    {
        NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:imgURL]];
        PoiImage *image = [PoiImage new];
        image.imgURL = imgURL;
        image.imgData = data;
        if(self.poiImageList == nil)
        {
            NSMutableArray *mArray = [NSMutableArray new];
            self.poiImageList = mArray;
            [mArray release];
        }
        [self.poiImageList addObject:image];
        [image release];
    }
    if(detailController != nil && [self.rootNavController.topViewController isKindOfClass:[PlaceDetailController class]])
        [detailController performSelectorOnMainThread:@selector(poiImageLoadCompleted) withObject:nil waitUntilDone:YES];
    [pool drain];
}

#pragma mark -
#pragma mark AR Methods
- (void)requestARObjects
{
	if(self.arViewController == nil)
	{
		ARGeoViewController *viewController = [[ARGeoViewController alloc] init];
		viewController.debugMode = NO;
		viewController.delegate = self;
		viewController.scaleViewsBasedOnDistance = NO;
		viewController.minimumScaleFactor = .5;
		viewController.rotateViewsBasedOnPerspective = YES;
        [viewController setTarget:self action:@selector(moveToMainPage)];
		self.arViewController = viewController;
		[viewController release];
	}
	[Helper showAlert:NEARBY_ALERT_TITLE message:NEARBY_ALERT_MSG okButton:NO withDelegate:self];
	[self processCurrentLocation:NEARBY_AR_NOTIFICATION];
}

- (void)pushARScreen
{
	if(self.arViewController != nil)
	{
		[self.rootNavController popViewControllerAnimated:YES];
		[self.arViewController.view removeFromSuperview];
        
		[self.arViewController presentARView];
        [self.view addSubview:self.arViewController.view];
	}
}

- (void)handleLockEventForAR
{
	if(self.arViewController != nil)
		[self.arViewController handleLockEvent];
}

- (void)handleUnlockEventForAR
{
	if(self.arViewController != nil)
		[self.arViewController handleUnlockEvent];
}

- (void)arAnnotationSelected:(NSString *)objectID
{
	Poi *poi = [self getObject:objectID objectType:self.selectedType];
	
	PlaceDetailController *placeController = [[PlaceDetailController alloc] initWithNibName:@"PlaceDetailController" bundle:nil];
	placeController.selectedPoi    = poi;
    placeController.delegate = self;
	[self.rootNavController setNavigationBarHidden:NO animated:NO];
	[placeController setTarget:self action:@selector(pushARScreen)];
	[self.rootNavController pushViewController:placeController animated:YES];
	[self.arViewController dismissARView];
	[self.arViewController.view removeFromSuperview];
    [self.view addSubview:[placeController view]];
}

- (void)arRequestCompleted
{
	[Helper dismissAlert];
	[self.arViewController startListening];
	[self.rootNavController.view removeFromSuperview];
    [self.view addSubview:self.arViewController.view];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)processARRequest
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self getCurrentLocationCoordinates:nil];
	NSMutableArray *objectList = [self getObjectList];
	NSMutableArray *tempLocationArray = [[NSMutableArray alloc] init];
	if(objectList != nil)
	{
		CLLocation *tempLocation;
		ARGeoCoordinate *tempCoordinate;
		NSEnumerator *iterator = [objectList objectEnumerator];
		Poi *poi = nil;
		while ((poi = [iterator nextObject]) != nil)
		{
			CLLocationDegrees lat = poi.latitude;
			CLLocationDegrees lon = poi.longitude;
			tempLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
			tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
			tempCoordinate.title = poi.name;
			tempCoordinate.subtitle = poi.address;
            LocationService *locationService = [LocationService sharedLocationService];
            [self getCurrentLocationCoordinates:nil];
            double dist = [locationService getDistanceBetweenTwoPoints:self.currentRetrievedCoords second:CLLocationCoordinate2DMake(poi.latitude, poi.longitude)];
			tempCoordinate.disttitle = [NSString stringWithFormat:@"Distance: %@",[self getDistanceLabel:dist]];
			tempCoordinate.objectID = poi.iD;
			
			[tempLocationArray addObject:tempCoordinate];
			[tempLocation release];
		}
	}
	[self.arViewController removeAllCoordinates];
	[self.arViewController addCoordinates:tempLocationArray];
	[tempLocationArray release];
	
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:self.currentRetrievedCoords.latitude longitude:self.currentRetrievedCoords.longitude];
	self.arViewController.centerLocation = newCenter;
	[newCenter release];
	
	[self performSelectorOnMainThread:@selector(arRequestCompleted) withObject:nil waitUntilDone:YES];
	[pool drain];
}

- (void)showARScreen:(NSNotification*)theNotification
{
	[NSThread detachNewThreadSelector:@selector(processARRequest) toTarget:self withObject:nil];
}

- (void)moveToMainPage
{
	[self.arViewController dismissARView];
	[self.arViewController removeHomeButtonForOverlayView];
	[self.arViewController.view removeFromSuperview];
	[self.arViewController removeAllCoordinates];
	self.arViewController = nil;
    [self.navigationController setNavigationBarHidden:NO];
    
    //hack for removing the UITransitionview which was coming above the ARHomeView.
    for (UIView *aView in [self.view subviews]) {
        if (!([aView isKindOfClass:[UILabel class]] || [aView isKindOfClass:[UIButton class]])) {
            [aView removeFromSuperview];
        }
    }

}

#pragma mark -
#pragma mark ARViewDelegate Methods
//This method returns the annotation view to ARViewController.
- (UIView *)viewForCoordinate:(ARDisCoordinate *)coordinate {
	
	CGRect theFrame = CGRectMake(0, 0, AR_VIEW_WIDTH, AR_VIEW_HEIGHT);
	ARAnnotationView *annView = [[ARAnnotationView alloc] initWithFrame:theFrame];
	annView.title = coordinate.title;
	annView.subTitle = coordinate.subtitle;
	annView.distTitle = coordinate.disttitle;
	annView.objectID = coordinate.objectID;
	[annView setTarget:self action:@selector(arAnnotationSelected:)];
	return annView;
}

//This method returns home button image to ARViewController.
- (UIImage *)homeButtonImageForARView
{
    UIImage *image = [UIImage imageNamed:IMG_HOME_BUTTON];
    return image;
}

//This mehtod returns compass view to ARViewController.
- (UIView *)compassView:(NSArray *)positionArray
{
	CGRect theFrame = CGRectMake(0.0, 0.0, 120.0, 120.0);
	ARCompassView *compassView = [[ARCompassView alloc] initWithFrame:theFrame];
    ARDisCoordinate *centerCoordinate = [positionArray objectAtIndex:[positionArray count]-1];
    ARDisCoordinate *coordinate = nil;
    
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    
    ;
    double centerAzimuth = centerCoordinate.azimuth;
	CGFloat xCenter = (theFrame.origin.x+theFrame.size.width)/2;
    CGFloat yCenter = (theFrame.origin.y+theFrame.size.height)/2;
	for (int i = 0; i< [positionArray count]-1; i++)
    {
        coordinate = [positionArray objectAtIndex:i];
        double angle = 3*M_PI_2+(centerAzimuth-coordinate.azimuth);
        CGFloat radius = theFrame.size.width/2*coordinate.radialDistance/5000.0;
        CGFloat x = xCenter + (radius*cosf(angle));
        CGFloat y = yCenter + (radius*sinf(angle));
        CGPoint point = CGPointMake(x, y);
        NSValue *value = [NSValue valueWithCGPoint:point];
        [pointArray addObject:value];
    }
    [compassView setPointArray:pointArray];
	
    [pointArray release];
    
	return compassView;
}

-(void)homepageIconSelected:(int)iconIndex
{
	self.selectedType = [self getSelectedObjectType:iconIndex];
    [self requestARObjects];
}

- (void)processCurrentLocation:(NSString *)notificationName
{
	LocationService *locationService = [LocationService sharedLocationService];
	[locationService processCurrentLocation:notificationName];
}

-(void)appWillTerminate
{
	LocationService *locationSer = [LocationService sharedLocationService];
	[locationSer  appWillTerminate];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[rootNavController release];
	[arViewController release];
	
	[poiHotelList release];
	[poiBankList release];
	[poiHealthList release];
	[poiEducationList release];
    [poiImageList release];
	
	[super dealloc];
}

@end
