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
//  ARMenuView.h
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 23/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ARNavigationProtocol <NSObject>

-(void)navigateToARScreen;
-(void)navigateToRoutesScreen;
-(void)navigateToSpeedScreen;
-(void)navigateToTrackingScreen;

@end

@interface ARMenuView : UIView
{
    UIButton *arBtn;
    UILabel *currSpeed;
    float devSpeed;
    
    // Added for teh background image
    UIImageView *backgroundImageView_;
    
    UIButton *routesButton;
    id <ARNavigationProtocol> delegate;
}

@property (assign) float devSpeed;
@property (assign) id <ARNavigationProtocol> delegate;
@property (strong, nonatomic) UIButton *routesButton;

@property (nonatomic, retain) UIButton *poiButton;
@property (nonatomic, retain) UIButton *speedButton;
@property (nonatomic, retain) UIButton *routeButton;
@property (nonatomic, retain) UIButton *trackerButton;
@property (nonatomic, retain) UIImageView *backgroundImageView;

- (void)arIconSelected:(id)sender;

@end
