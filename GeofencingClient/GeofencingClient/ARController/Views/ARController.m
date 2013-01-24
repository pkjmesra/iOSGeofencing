//
//  ARController.m
//  GLGeofencing
//
//  Created by Pravin Potphode on 31/10/12.
//
//

#import "ARController.h"
#import "AppDelegate.h"
#import "ARGeoViewController.h"
#import "GLCoreLocationController.h"
#import "ARAnnotationView.h"
#import "Defines.h"
#import "Helper.h"
#import "AppObjects.h"
#import "PlaceDetailController.h"
#import "ARCompassView.h"
#import "ARHomeViewController.h"

@interface ARController ()

@end

@implementation ARController
@synthesize arViewController, currentRetrievedCoords, rootNavController, selectedType, appDelegate;
@synthesize poiHotelList, poiBankList, poiHealthList, poiEducationList, poiImageList;
@synthesize arHome;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        
        currentRetrievedCoords.latitude = 0.0;
        currentRetrievedCoords.longitude = 0.0;
        //CLLocationCoordinate2DMake(0.0,0.0);
        
        [[NSNotificationCenter defaultCenter]	addObserver:self selector:@selector(showARScreen:) name:NEARBY_AR_NOTIFICATION object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getCurrentLocationCoordinates:(NSNotification*)notification
{
	GLCoreLocationController *locationService = [GLCoreLocationController sharedLocationService];
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
		UIWindow *mainWindow = appDelegate.window;
		[self.rootNavController popViewControllerAnimated:YES];
		[self.arViewController.view removeFromSuperview];
		[self.arViewController presentARView];
        //[self.view addSubview:self.arViewController.view];
		[mainWindow addSubview:self.arViewController.view];
		[mainWindow makeKeyAndVisible];
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
	UIWindow *mainWindow = appDelegate.window;
	Poi *poi = [self getObject:objectID objectType:self.selectedType];
	
	PlaceDetailController *placeController = [[PlaceDetailController alloc] initWithNibName:@"PlaceDetailController" bundle:nil];
	placeController.selectedPoi    = poi;
	
	[self.rootNavController setNavigationBarHidden:NO animated:NO];
	[placeController setTarget:self action:@selector(pushARScreen)];
	[self.rootNavController pushViewController:placeController animated:YES];
	[self.arViewController dismissARView];
	[self.arViewController.view removeFromSuperview];
    //[self.view addSubview:[self.rootNavController view]];
	[mainWindow addSubview:[placeController view]];
	
	[mainWindow makeKeyAndVisible];
	[placeController release];
}

- (void)arRequestCompleted
{
	UIWindow *mainWindow = appDelegate.window;
	[Helper dismissAlert];
	[self.arViewController startListening];
	[self.rootNavController.view removeFromSuperview];
    //[self.view addSubview:self.arViewController.view];
	[mainWindow addSubview:self.arViewController.view];
	
	// Override point for customization after application launch
	[mainWindow makeKeyAndVisible];
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
            GLCoreLocationController *locationService = [GLCoreLocationController sharedLocationService];
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
	UIWindow *mainWindow = appDelegate.window;
	[self.arViewController dismissARView];
	[self.arViewController removeHomeButtonForOverlayView];
	[self.arViewController.view removeFromSuperview];
	[self.arViewController removeAllCoordinates];
	//[self.arViewController release];
	self.arViewController = nil;
//    [mainWindow removeFromSuperview];
    ARHomeViewController *ar = [[ARHomeViewController alloc] initWithNibName:@"ARHomeViewController" bundle:[NSBundle mainBundle]];
    self.arHome = ar;
//    [self.navigationController pushViewController:self.arHome animated:YES];
    [ar release];
    
    //[self.view addSubview:[self.rootNavController view]];
	//[mainWindow addSubview:[self.rootNavController view]];
    [mainWindow addSubview:[self.arHome view]];
	[mainWindow makeKeyAndVisible];
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
	GLCoreLocationController *locationService = [GLCoreLocationController sharedLocationService];
	[locationService processCurrentLocation:notificationName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}



-(void)appWillTerminate
{
	GLCoreLocationController *locationSer = [GLCoreLocationController sharedLocationService];
	[locationSer  appWillTerminate];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[rootNavController release];
	[appDelegate release];
	[arViewController release];
	
	[poiHotelList release];
	[poiBankList release];
	[poiHealthList release];
	[poiEducationList release];
    [poiImageList release];
    [arHome release];
	
	[super dealloc];
}

@end
