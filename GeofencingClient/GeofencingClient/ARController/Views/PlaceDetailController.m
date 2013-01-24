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
//  PlaceDetailController.m
//  POISearch
//
//  Created by Rajesh Dongre on 02/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceDetailController.h"
#import "AppObjects.h"
#import "LocationService.h"
#import "ARHomeViewController.h"

@implementation PlaceDetailController

@synthesize imageView, category, address, phone, distance, selectedPoi, spinner, delegate, topNavItem, heading;
@synthesize cancelBarButton;

#pragma mark -
#pragma mark Custom Methods

- (void)setBackButton
{	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];	
	[backButton setFrame:CGRectMake(0.0, 0.0, 67.0, 28.0)];
	if(arAction != nil && arTarget != nil)
		[backButton addTarget:arTarget action:arAction forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];	
	[self.navigationItem setLeftBarButtonItem:backButtonItem];
}

- (void)setPoiDetail
{
	ARHomeViewController *controller = [[ARHomeViewController alloc] init];
	if(self.selectedPoi.imageURL != nil)
	{
        PoiImage *image = [controller getPoiImageForURL:self.selectedPoi.imageURL];
        if(image != nil && image.imgData != nil)
        {            
            [self.imageView setImage:[UIImage imageWithData:image.imgData]];
        }
        else
        {
            [self loadImageForPoi];
        }
	}
	if(self.selectedPoi.address != nil)
		[self.address setText:self.selectedPoi.address];
	else
		[self.address setText:@"No address available."];
	
	if(self.selectedPoi.phone != nil)
		[self.phone setText:self.selectedPoi.phone];
	else
		[self.phone setText:@"-"];
	
    LocationService *locationService = [LocationService sharedLocationService];
    [controller getCurrentLocationCoordinates:nil];
    double dist = [locationService getDistanceBetweenTwoPoints:controller.currentRetrievedCoords second:CLLocationCoordinate2DMake(self.selectedPoi.latitude, self.selectedPoi.longitude)]; 
	[self.distance setText:[controller getDistanceLabel:dist]];
	
	static NSString *catName = nil;
	switch (self.selectedPoi.type)
	{
		case POIBANK:
			catName = @"Bank";
			break;
		case POIHOTEL:
			catName = @"Hotel";
			break;
		case POIHEALTH:
			catName = @"Health";
			break;
		case POIEDUCATION:
			catName = @"Education";
			break;
        case POI:
        case NONE:
            catName = @"None";
			break;
	}
	[self.category setText:catName];
     
}

- (void)setTarget:(id)target action:(SEL)action
{
	arTarget = target;
	arAction = action;
}

- (void)poiImageLoadCompleted
{
    ARHomeViewController *controller = [[ARHomeViewController alloc] init];
    PoiImage *image = [controller getPoiImageForURL:self.selectedPoi.imageURL];
    if(image != nil && image.imgData != nil)
        [self.imageView setImage:[UIImage imageWithData:image.imgData]];
    [self.spinner stopAnimating];
     
}

- (void)loadImageForPoi
{
    ARHomeViewController *controller = [[ARHomeViewController alloc] init];
    [self.spinner startAnimating];
    [NSThread detachNewThreadSelector:@selector(loadPoiImage:) toTarget:controller withObject:[NSArray arrayWithObjects:self.selectedPoi.imageURL, self, nil]];
}

#pragma mark - Intializer 

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//topNavItem.title = self.selectedPoi.name;
    
    [self.topNavItem setTitle:self.selectedPoi.name];
	[self setBackButton];
	[self setPoiDetail];
    [self.cancelBarButton setAction:@selector(cancelButtonTapped:)];
    
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageView release];
	[category release];
	[address release];
	[phone release];
	[distance release];
	[selectedPoi release];
    [spinner release];
    [heading release];
    [super dealloc];
}

#pragma mark - Button Action

- (IBAction)cancelButtonTapped:(id)sender
{
    [[self delegate] pushARScreen];
}

@end
