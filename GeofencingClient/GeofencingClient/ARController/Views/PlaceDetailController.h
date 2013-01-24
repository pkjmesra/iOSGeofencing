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
//  PlaceDetailController.h
//  POISearch
//
//  Created by Rajesh Dongre on 02/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceDetailProtocol <NSObject>

- (void)pushARScreen;

@end
@class Poi;

@interface PlaceDetailController : UIViewController {
	UIImageView *imageView;
	UILabel     *category;
	UILabel     *address;
	UILabel     *phone;
	UILabel     *distance;
	Poi         *selectedPoi;
	SEL         arAction;
	NSObject    *arTarget;
    UIActivityIndicatorView *spinner;
    id <PlaceDetailProtocol> delegate;
    UINavigationItem *topNavItem;
    UILabel     *heading;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel     *category;
@property (nonatomic, retain) IBOutlet UILabel     *address;
@property (nonatomic, retain) IBOutlet UILabel     *phone;
@property (nonatomic, retain) IBOutlet UILabel     *distance;
@property (nonatomic, retain) Poi                  *selectedPoi;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (assign) id delegate;
@property (nonatomic, retain) IBOutlet UINavigationItem *topNavItem;
@property (nonatomic, retain) IBOutlet UILabel     *heading;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelBarButton;


- (void)setTarget:(id)target action:(SEL)action;
- (void)poiImageLoadCompleted;
- (void)loadImageForPoi;
- (IBAction)cancelButtonTapped:(id)sender;

@end
