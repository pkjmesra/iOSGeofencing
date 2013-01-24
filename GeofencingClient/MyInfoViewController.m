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
//  MyInfoViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 06/12/12.
//
//

#import "MyInfoViewController.h"

@interface MyInfoViewController ()

@end

@implementation MyInfoViewController
@synthesize lattitude, longitude, navItem, currentLocation, regionRadius, radiusLabel;

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
    self.navItem.title = [[UIDevice currentDevice] name];
    NSLog(@"current lattitude and longitude : %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);

    self.lattitude.text = [NSString stringWithFormat:@"%.2f", self.currentLocation.coordinate.latitude];
    self.longitude.text = [NSString stringWithFormat:@"%.2f", self.currentLocation.coordinate.longitude];
    
    switch (self.regionRadius) {
        case 50:
            self.radiusLabel.text = @"50 meters";
            break;
        case 500:
            self.radiusLabel.text = @"500 meters";
            break;
        case 1000:
            self.radiusLabel.text = @"1 KM";
            break;
        case 5000:
            self.radiusLabel.text = @"5 KM";
            break;
        case 10000:
            self.radiusLabel.text = @"10 KM";
            break;
        case 25000:
            self.radiusLabel.text = @"25 KM";
            break;
        case 50000:
            self.radiusLabel.text = @"50 KM";
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneButtonTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
