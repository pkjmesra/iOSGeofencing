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
//  SplashViewController.m
//  iOSGeofencingClient
//
//  Created by Research2Development on 03/12/12.
//
//

#import "SplashViewController.h"
#import "AppDelegate.h"

#define APP_DELEGATE  ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define NAVIGATION_TIME_FROM_SPLASH_SCREEN 1.5

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (APP_DELEGATE.splashScreenTimer != nil) {
        [self invalidateTimer];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - timer methods

-(void)startTimer
{    
    NSLog(@"Timer reseted...");
    
    APP_DELEGATE.splashScreenTimer = [NSTimer
                                      scheduledTimerWithTimeInterval:NAVIGATION_TIME_FROM_SPLASH_SCREEN
                                      target:self
                                      selector:@selector(navigateToMainScreen)
                                      userInfo:nil
                                      repeats:NO];
}

-(void)invalidateTimer
{
    NSLog(@"[Method] invalidateTimer");
    
    if (APP_DELEGATE.splashScreenTimer!=nil) {
        
        NSLog(@"Invalidating timer...");
        [APP_DELEGATE.splashScreenTimer invalidate];
        APP_DELEGATE.splashScreenTimer = nil;
    }
}


-(void)navigateToMainScreen
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self dismissModalViewControllerAnimated:YES];    
}

@end
