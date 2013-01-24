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
//  MySlavesViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 30/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySlavesViewController.h"
#import "SBJsonParser.h"
#import "RouteHistoryViewController.h"
#import "Constants.h"

@interface MySlavesViewController ()

@end

@implementation MySlavesViewController
@synthesize slavesTableView, allSlaves, masterID, receivedData, dateToShowRoute, delegate, currentLocation;

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
    slavesTableView.dataSource = self;
    slavesTableView.delegate = self;
    
    self.receivedData = [[NSMutableData alloc] init];
    
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setDateFormat:@"yyyyMMdd"];
    self.dateToShowRoute = [fmtr stringFromDate:[NSDate date]];
    [fmtr release];    
    
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/getslaves?master=%@",self.masterID]]];
    }else{
        
        NSString *stringURL = [NSString
                               stringWithFormat:@"%@/getslaves?master=%@", kAppDelegate.serverIPURL,
                               self.masterID];;
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        NSLog(@"Request getslaves URL: %@", stringURL);
    }    
    /* // Previous Implementation
     NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/getslaves?master=%@",self.masterID]]];*/
    
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"master added");
    }
    else {
        NSLog(@"connection failed");
    }
    
//    [theConnection release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [receivedData release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)routesButtonTapped:(id)sender
{    
    UIDatePicker *aDatepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 300.0f, 320.0f, 180.0f)];
    aDatepicker.datePickerMode = UIDatePickerModeDate;
    [aDatepicker setDate:[NSDate date]];
    [aDatepicker setMaximumDate:[NSDate date]];
    [aDatepicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:aDatepicker];
    [aDatepicker release];
}

-(void)dateChanged:(id)sender
{
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
    [fmtr setDateFormat:@"yyyyMMdd"];
    self.dateToShowRoute = [fmtr stringFromDate:[sender date]];
    [fmtr release];
}

-(IBAction)doneButtonTapped:(id)sender
{
//    [[self delegate] updateDateForSlaveMonitoring:self.dateToShowRoute];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableView Protocol 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allSlaves count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[[self.allSlaves objectAtIndex:indexPath.row] valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self delegate] updateSlaveInfoForMonitoring:[[self.allSlaves objectAtIndex:indexPath.row] valueForKey:@"UDID"]];
    UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Monitoring started for %@.",[[[self.allSlaves objectAtIndex:indexPath.row] valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [anAlert show];
    [anAlert release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RouteHistoryViewController *aController = [[RouteHistoryViewController alloc] initWithNibName:@"RouteHistoryViewController" bundle:[NSBundle mainBundle]];
    aController.slaveId = [[self.allSlaves objectAtIndex:indexPath.row] valueForKey:@"UDID"];
    aController.currentLocation = self.currentLocation;
    [aController addBarButtons];
    [self presentModalViewController:aController animated:NO];
    [aController release];
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
    
     NSLog(@"%d",[receivedData length]);
     SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
     NSString *json_string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
     NSDictionary *dataReceivedDictionary = [jsonParser objectWithString:json_string error:nil];
    [jsonParser release];
    [json_string release];
     self.allSlaves = [dataReceivedDictionary valueForKey:@"slaves"];
    [self.slavesTableView reloadData];
}


@end