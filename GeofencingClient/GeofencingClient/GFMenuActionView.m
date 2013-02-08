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
//  GFMenuActionView.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GFMenuActionView.h"

@implementation GFMenuActionView

@synthesize delegate, isMenuOpen;
@synthesize menuTabButton = menuTabButton_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {        // 210, 162, (self.frame.size.height / 2) - 60/2
        UIView *menuButtonView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                          162,
                                                                          90,
                                                                          90)];
        menuButtonView.backgroundColor = [UIColor colorWithRed:59/255.0
                                                          green:60/255.0
                                                           blue:60/255.0
                                                          alpha:1.0];
        menuButtonView.layer.cornerRadius = 45;
        [self addSubview:menuButtonView];
        
        menuTabButton_  = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuTabButton_ setImage:[UIImage imageNamed:@"arrow-right.png"]
                        forState:UIControlStateNormal];
        [menuTabButton_ setFrame:CGRectMake(57, 22, 27, 48)];
        [menuTabButton_ setUserInteractionEnabled:NO];
        [menuButtonView addSubview:menuTabButton_];

        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
        [menuButtonView addGestureRecognizer:singleTap];
        [singleTap release];
        [menuButtonView release];
        
        UISwipeGestureRecognizer *swipeRecognizer;
        swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
        [swipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];
        [menuButtonView addGestureRecognizer:swipeRecognizer];
        [swipeRecognizer release];
    }
    return self;
}

- (void)showMenu
{
    [[self delegate] menuShowHideAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
