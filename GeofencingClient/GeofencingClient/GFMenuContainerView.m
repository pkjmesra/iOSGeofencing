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
//  GFMenuContainerView.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GFMenuContainerView.h"
#import "GFMenuActionView.h"
#import "ARMenuView.h"

@implementation GFMenuContainerView
@synthesize actionView, delegate, arMenuView;

#define kGFMenuActionViewWidth  90.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        actionView = [[GFMenuActionView alloc] initWithFrame:CGRectMake(self.frame.size.width - kGFMenuActionViewWidth - 10,
                                                                        0.0f,
                                                                        kGFMenuActionViewWidth,
                                                                        480.0f)];
        actionView.delegate = self;
        [self addSubview:actionView];
        
        arMenuView = [[ARMenuView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  self.frame.size.width - kGFMenuActionViewWidth/2,
                                                                  480.0f)];
        arMenuView.delegate = self;
        [self addSubview:arMenuView];        
    }
    return self;
}

- (void)menuShowHideAction
{
    if (!actionView.isMenuOpen)
    {
        /*[actionView.menuTabButton setImage:[UIImage imageNamed:@"arrow-left.png"]
                                  forState:UIControlStateNormal];*/       
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.frame = CGRectMake(0.0f,
                                                     0.0f,
                                                     self.frame.size.width,
                                                     self.frame.size.height);
                             actionView.isMenuOpen = YES;
                             [actionView.menuTabButton setImage:[UIImage imageNamed:@"arrow-left.png"]
                                                       forState:UIControlStateNormal];
                         }
                         completion:^(BOOL finished){
                         }];
    } 
    else {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x - (self.frame.size.width - kGFMenuActionViewWidth/2),
                                                     0.0f,
                                                     self.frame.size.width,
                                                     self.frame.size.height);
                             actionView.isMenuOpen = NO;
                             
                             [actionView.menuTabButton setImage:[UIImage imageNamed:@"arrow-right.png"]
                                                       forState:UIControlStateNormal];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
    [[self delegate] menuShowAction];
}

-(void)navigateToARScreen
{
    NSLog(@"navigate to screen called");
    if ([[self delegate] respondsToSelector:@selector(navigateToARScreenAction)]) {
        [[self delegate] navigateToARScreenAction];
    }

}

-(void)navigateToRoutesScreen
{
    if ([[self delegate] respondsToSelector:@selector(navigateToRoutesScreenAction)]) {
        [[self delegate] navigateToRoutesScreenAction];
    }
}

-(void)navigateToSpeedScreen{
    
    if ([[self delegate] respondsToSelector:@selector(navigateToSpeedScreenAction)]) {
        [[self delegate] navigateToSpeedScreenAction];
    }
}

-(void)navigateToTrackingScreen{
    
    if ([[self delegate] respondsToSelector:@selector(navigateToTrackingScreenAction)]) {
        [[self delegate] navigateToTrackingScreenAction];
    }
}

@end