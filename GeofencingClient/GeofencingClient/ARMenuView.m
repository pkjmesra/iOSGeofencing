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
//  ARMenuView.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 23/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ARMenuView.h"

#define MENU_BUTTON_LEFT_OFFSET     10
#define MENU_BUTTON_TOP_OFFSET      30
#define MENU_BUTTON_VERTICAL_GAP    30
#define MENU_BUTTON_HEIGHT          58
#define MENU_BUTTON_WIDTH           123

@implementation ARMenuView
@synthesize devSpeed, delegate;
@synthesize routesButton;
@synthesize backgroundImageView = backgroundImageView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_checks_light.png"]]];
        /*[self setBackgroundColor:[UIColor colorWithRed:82/255.0 green:84/255.0 blue:84/255.0
                                                 alpha:1]];*/
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{  
    // Intialize background imageView.   
    [[UIImage imageNamed:@"bg_image.png"] drawInRect:self.frame];
    
    CGFloat yPlacement = MENU_BUTTON_TOP_OFFSET;
    
    // Drawing code
    arBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    arBtn.frame = CGRectMake(MENU_BUTTON_LEFT_OFFSET,
                             yPlacement,
                             MENU_BUTTON_WIDTH,
                             MENU_BUTTON_HEIGHT);
    [arBtn setTag:3];
    [arBtn setBackgroundImage:[UIImage imageNamed:@"po.png"] forState:UIControlStateNormal];
    //[arBtn setTitle:@"Point Of Interest" forState:UIControlStateNormal];
    [arBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    arBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0f];
    arBtn.titleLabel. numberOfLines = 0; // Dynamic number of lines
    arBtn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [arBtn addTarget:self action:@selector(arIconSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:arBtn];
    
    yPlacement = yPlacement + MENU_BUTTON_HEIGHT + MENU_BUTTON_VERTICAL_GAP;
    
    // Drawing code
    self.routeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.routeButton.frame = CGRectMake(MENU_BUTTON_LEFT_OFFSET,
                             yPlacement,
                             MENU_BUTTON_WIDTH,
                             MENU_BUTTON_HEIGHT);
    [self.routeButton setTag:3];
    [self.routeButton setBackgroundImage:[UIImage imageNamed:@"routes.png"] forState:UIControlStateNormal];
    //[self.routeButton setTitle:@"Routes" forState:UIControlStateNormal];
    [self.routeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.routeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0f];
    self.routeButton.titleLabel. numberOfLines = 0; // Dynamic number of lines
    self.routeButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self.routeButton addTarget:self action:@selector(routesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.routeButton];
    
    yPlacement = yPlacement + MENU_BUTTON_HEIGHT + MENU_BUTTON_VERTICAL_GAP;
    
    // Drawing code
    self.trackerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trackerButton.frame = CGRectMake(MENU_BUTTON_LEFT_OFFSET,
                                        yPlacement,
                                        MENU_BUTTON_WIDTH,
                                        MENU_BUTTON_HEIGHT);
    [self.trackerButton setTag:3];
    [self.trackerButton setBackgroundImage:[UIImage imageNamed:@"tracker-image.png"]
                                  forState:UIControlStateNormal];
    //[self.trackerButton setTitle:@"Tracker" forState:UIControlStateNormal];
    [self.trackerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.trackerButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0f];
    self.trackerButton.titleLabel. numberOfLines = 0; // Dynamic number of lines
    self.trackerButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self.trackerButton addTarget:self action:@selector(trackingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.trackerButton];
    
    yPlacement = yPlacement + MENU_BUTTON_HEIGHT + MENU_BUTTON_VERTICAL_GAP;
    
    // Drawing code    
    self.speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.speedButton.frame = CGRectMake(MENU_BUTTON_LEFT_OFFSET,
                                          yPlacement,
                                          MENU_BUTTON_WIDTH,
                                          MENU_BUTTON_HEIGHT);
    [self.speedButton setTag:3];
    [self.speedButton setBackgroundImage:[UIImage imageNamed:@"speed.png"] forState:UIControlStateNormal];
    //[self.speedButton setTitle:@"Speed" forState:UIControlStateNormal];
    [self.speedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0f];
    self.speedButton.titleLabel. numberOfLines = 0; // Dynamic number of lines
    self.speedButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self.speedButton addTarget:self action:@selector(speedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.speedButton];
    
}

- (void)arIconSelected:(id)sender
{
    [[self delegate] navigateToARScreen];
}

- (void)routesButtonTapped:(id)sender
{
    [[self delegate] navigateToRoutesScreen];
}
- (void)trackingButtonTapped:(id)sender
{
    [[self delegate] navigateToTrackingScreen];
}

- (void)speedButtonTapped:(id)sender
{
    [[self delegate] navigateToSpeedScreen];
}

@end
