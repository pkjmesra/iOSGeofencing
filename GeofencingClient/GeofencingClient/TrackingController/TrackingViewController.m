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
//  TrackingViewController.m
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 15/11/12.
//
//

#import "TrackingViewController.h"
#import "SBJsonParser.h"
#import "MySlavesViewController.h"
#import "MastersViewController.h"
#import "MyInfoViewController.h"
#import "Constants.h"

@interface TrackingViewController ()

@end

@implementation TrackingViewController
@synthesize masterRegButton;
@synthesize slaveRegButton;
@synthesize masterInfoButton,slaveInfoButton;
@synthesize receivedData;
@synthesize currentLocation;
@synthesize currentlyMonitoredSlave;
@synthesize delegate;
@synthesize radiusRangeArray, selectedRadius;
@synthesize activityIndicator;
@synthesize radiusPickerView, radiusToolbar;

- (void)dealloc
{
    [masterRegButton release];
    [slaveRegButton release];
    [slaveInfoButton release];
    [masterInfoButton release];
    [receivedData release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	receivedData = [[NSMutableData alloc] init];
    
    [self.activityIndicator setHidden:YES];
    [self.radiusPickerView setHidden:YES];
    [self.radiusToolbar setHidden:YES];
    self.selectedRadius = 50;
    
    self.radiusPickerView.delegate = self;
    self.radiusPickerView.dataSource = self;
    
    self.radiusRangeArray = [NSArray arrayWithObjects:@"50 Meters", @"500 Meters", @"1 KM", @"5 KM", @"10 KM", @"25 KM", @"50 KM", nil];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)onCancelBtn:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)registerAsMaster:(id)sender
{
    NSString *deviceID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *deviceName = [[UIDevice currentDevice] name];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    queryType = QueryTypeAddMaster;
    
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/addmaster?master=%@&name=%@&apnsdevicetoken=%@",
                                                     deviceID,[deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }else{
        
        NSString *urlString = [NSString
                               stringWithFormat:@"%@/addmaster?master=%@&name=%@&apnsdevicetoken=%@",
                               kAppDelegate.serverIPURL,
                               deviceID,
                               [deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               ];
        
        NSLog(@"Request addmaster URL: %@", urlString);
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:urlString
                                      ]
                      ];
    }
    
    /* Previous Implementation
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/addmaster?master=%@&name=%@&apnsdevicetoken=%@",deviceID,[deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];*/
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
    }
    else {
        NSLog(@"connection failed");
    }
    
//    [theConnection release];
}

-(IBAction)registerAsSlave:(id)sender
{
    MastersViewController *mastersVC = [[MastersViewController alloc] initWithNibName:@"MastersViewController" bundle:nil];
    mastersVC.currentLocation = self.currentLocation;
    mastersVC.delegate = self;
    [self presentModalViewController:mastersVC animated:YES];
    [mastersVC release];
}

-(IBAction)onSlaveInfo:(id)sender
{
    MySlavesViewController *slavesController = [[MySlavesViewController alloc] initWithNibName:@"MySlavesViewController" bundle:nil];
    slavesController.delegate = self;
    slavesController.currentLocation = self.currentLocation;
    slavesController.masterID = [[UIDevice currentDevice] uniqueIdentifier];
    [self presentModalViewController:slavesController animated:YES];

}

-(IBAction)onMyInfo:(id)sender
{
    MyInfoViewController *myInfo = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:[NSBundle mainBundle]];
    myInfo.currentLocation = self.currentLocation;
    myInfo.regionRadius = self.selectedRadius;
    [self presentModalViewController:myInfo animated:YES];
}

-(void) updateSlaveInfoForMonitoring:(NSString*)slaveId;
{
    NSLog(@"update slave info");
    [[self delegate] updateSlaveForMonitoring:slaveId];
    self.currentlyMonitoredSlave = slaveId;
//    [self createRegionForMonitoring];
}

-(void) updateDateForSlaveMonitoring:(NSString*)dateString
{
    [[self delegate] updateDateForMonitoring:dateString];
    NSLog(@"date updated");
}

-(void) updateMasterInfoForMonitoring:(NSString*)masterId
{
    NSLog(@"updateMasterInfoForMonitoring method");
    [[self delegate] updateMasterForMonitoring:masterId];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    UIAlertView *anErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [anErrorAlert show];
//    [anErrorAlert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    switch (queryType) {
        case QueryTypeAddMaster:
        {
            NSLog(@"master added");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DeviceRegistered"];
            [self updateSlaveLocationForSelectedMaster];
            break;
        }
        case QueryTypeUpdateSlaveLocation:
        {
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Device Registered Successfully"
                                  message: @"This device is successfully registered for monitoring other devices."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
            [alert release];

            break;
        }
        case QueryTypeAddCircularRegion:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Geofence Added Successfully"
                                  message: nil
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
            [alert release];
            break;
        }

        default:
            break;
    }
}

- (void)createRegionForMonitoring;
{
    NSString *deviceId;
    if ([self.currentlyMonitoredSlave length] == 0) {
        deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    }
    else
    {
        deviceId = self.currentlyMonitoredSlave;
    }
    
    queryType = QueryTypeAddCircularRegion;
    
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/addcircularregionforslave?master=%@&slave=%@&x=%f&y=%f&r=%d&updatefrequency=5",
                                                     [[UIDevice currentDevice] uniqueIdentifier], deviceId, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.selectedRadius]]];
    }else{
        
        NSString *urlString = [NSString
                               stringWithFormat:@"%@/addcircularregionforslave?master=%@&slave=%@&x=%f&y=%f&r=%d&updatefrequency=5",
                               kAppDelegate.serverIPURL,
                               [[UIDevice currentDevice] uniqueIdentifier],
                               deviceId,
                               self.currentLocation.coordinate.latitude,
                               self.currentLocation.coordinate.longitude,
                               self.selectedRadius];
        
        NSLog(@"Request addcircularregionforslave URL: %@", urlString);
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:urlString]];
    }
    
    /* Previous Implementation     
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/addcircularregionforslave?master=%@&slave=%@&x=%f&y=%f&r=%d&updatefrequency=5",[[UIDevice currentDevice] uniqueIdentifier], deviceId, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.selectedRadius]]];*/
    
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
    }
    else {
        NSLog(@"connection failed");
    }
    
//    [theConnection release];
}

-(void) updateSlaveLocationForSelectedMaster
{
    NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    
    queryType = QueryTypeUpdateSlaveLocation;
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",
                                                     deviceId, [[UIDevice currentDevice] uniqueIdentifier], self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]]];
    }else{
        
        NSString *urlString = [NSString
                               stringWithFormat:@"%@/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",
                               kAppDelegate.serverIPURL,
                               deviceId,
                               [[UIDevice currentDevice] uniqueIdentifier],
                               self.currentLocation.coordinate.latitude,
                               self.currentLocation.coordinate.longitude];
        
        NSLog(@"Request updateslavelocation URL: %@", urlString);
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:urlString]];
    }
    /* // Previous Implementation
     NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/updateslavelocation?master=%@&slave=%@&x=%f&y=%f",deviceId,[[UIDevice currentDevice] uniqueIdentifier], self.locManager.location.coordinate.latitude, self.locManager.location.coordinate.longitude]]];*/
    
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
    }
    else {
        NSLog(@"connection failed");
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (queryType == QueryTypeAddMaster || queryType==QueryTypeUpdateSlaveLocation) {
        [self showRadiusPicker];
    }
}

-(void)showRadiusPicker
{
    [self.radiusPickerView setHidden:NO];
    [self.radiusToolbar setHidden:NO];
}

-(IBAction)cancelRadiusSelection:(id)sender
{
    [self.radiusPickerView setHidden:YES];
    [self.radiusToolbar setHidden:YES];
}

-(IBAction)doneRadiusSelection:(id)sender
{
    [self.radiusPickerView setHidden:YES];
    [self.radiusToolbar setHidden:YES];
    [self createRegionForMonitoring];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.radiusRangeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            self.selectedRadius = 50;
            break;
        case 1:
            self.selectedRadius = 500;
            break;
        case 2:
            self.selectedRadius = 1000;
            break;
        case 3:
            self.selectedRadius = 5000;
            break;
        case 4:
            self.selectedRadius = 10000;
            break;
        case 5:
            self.selectedRadius = 25000;
            break;
        case 6:
            self.selectedRadius = 50000;
            break;
            
        default:
            break;
    }
}

@end
