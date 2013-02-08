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
//  MastersViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 21/11/12.
//
//

#import "MastersViewController.h"
#import "SBJsonParser.h"
#import "Constants.h"

@interface MastersViewController ()

@end

@implementation MastersViewController
@synthesize mastersTableView, allmasters, slaveID, masterId, receivedData, delegate;
@synthesize currentLocation=_currentLocation;

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
    mastersTableView.dataSource = self;
    mastersTableView.delegate = self;
    
    self.receivedData = [[NSMutableData alloc] init];
    queryType = QueryTypeGetMasters;
    
    NSURLRequest *theRequest = nil;

    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://172.17.10.25:1208/getmasters"]];        
    }else{       
        
        NSString *stringURL = [NSString stringWithFormat:@"%@/getmasters", kAppDelegate.serverIPURL];
        NSLog(@"Request getMasters URL: %@", stringURL);
        
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    }
    
    // Previous Implementation
    //NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://172.17.10.25:1208/getmasters"]];
    
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"master added");
    }
    else {
        NSLog(@"connection failed");
    }
    
//    [theConnection release];
}

-(void) updateSlaveLocationForSelectedMaster
{
    NSString *deviceId = [self.masterId length] >0 ?self.masterId:[[UIDevice currentDevice] uniqueIdentifier];

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

- (void)dealloc {
    [receivedData release];
    [_currentLocation release];
    
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableView Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allmasters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[[self.allmasters objectAtIndex:indexPath.row] valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *aMaster = [self.allmasters objectAtIndex:indexPath.row];
    NSString *masterID = [aMaster valueForKey:@"UDID"];
    self.masterId = masterID;
    NSString *deviceID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *deviceName = [[UIDevice currentDevice] name];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    queryType = QueryTypeAddSlave;
    
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
     
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/addslave?master=%@&slave=%@&name=%@&apnsdevicetoken=%@",
                                                     masterID,
                                                     deviceID,
                                                     [deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                                     [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                     ]
                                      ]
                      ];
     
    }else{
     
        NSString *stringURL = [NSString stringWithFormat:@"%@/addslave?master=%@&slave=%@&name=%@&apnsdevicetoken=%@",
                               kAppDelegate.serverIPURL,
                               masterID,
                               deviceID,
                               [deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               ];
        NSLog(@"Request addslave URL: %@", stringURL);
         
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];         
    }
    
    /* // Previous Implementation
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/addslave?master=%@&slave=%@&name=%@&apnsdevicetoken=%@",
                                                                                  masterID,
                                                                                  deviceID,
                                                                                  [deviceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                                                                  [appDelegate.apnsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                                  ]]];*/
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"slave added");
    }
    else {
        NSLog(@"connection failed");
    }
    
//    [theConnection release];
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
    NSLog(@"[MastersViewController : connectionDidFinishLoading]");
    
    NSLog(@"connectionDidFinishLoading response:%d",[receivedData length]);
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSString *json_string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *dataReceivedDictionary = [jsonParser objectWithString:json_string error:nil];
    [jsonParser release];
    [json_string release];
    switch (queryType) {
        case QueryTypeGetMasters:
        {
            self.allmasters = [dataReceivedDictionary valueForKey:@"masters"];
            [self.mastersTableView reloadData];
            break;
        }
        case QueryTypeAddSlave:
        {
            [self updateSlaveLocationForSelectedMaster];
            break;
        }
        case QueryTypeUpdateSlaveLocation:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DeviceRegistered"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Device Registered Successfully"
                                  message: @"This device is successfully registered for getting monitored."
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self delegate] updateMasterInfoForMonitoring:self.masterId];
    [self dismissModalViewControllerAnimated:YES];
}

@end
