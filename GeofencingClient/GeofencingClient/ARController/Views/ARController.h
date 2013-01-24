//
//  ARController.h
//  GLGeofencing
//
//  Created by Pravin Potphode on 31/10/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARViewController.h"
#import "Defines.h"

@class AppDelegate;
@class ARGeoViewController;
@class PoiImage;
@class ARHomeViewController;

@interface ARController : UIViewController <ARViewDelegate, UIAlertViewDelegate>
{
	AppDelegate      *appDelegate;
	ARGeoViewController	      *arViewController;
	CLLocationCoordinate2D	  currentRetrievedCoords;
	UINavigationController    *rootNavController;
	ObjectType                selectedType;
    ARHomeViewController *arHome;
	
	//Keep all the lists here.
	NSMutableArray           *poiHotelList;
	NSMutableArray           *poiBankList;
	NSMutableArray           *poiHealthList;
	NSMutableArray           *poiEducationList;
    NSMutableArray           *poiImageList;
}

@property (nonatomic, retain) AppDelegate               *appDelegate;
@property (nonatomic, retain) ARGeoViewController       *arViewController;
@property (nonatomic, retain) ARHomeViewController      *arHome;
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

@end
