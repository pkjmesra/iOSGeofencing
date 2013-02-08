//
//  SendMessageViewController.m
//  iOSGeofencingClient
//
//  Created by Udit Kakkad on 07/12/12.
//
//

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


#import "SendMessageViewController.h"
#import "Constants.h"

@interface SendMessageViewController ()

@end

@implementation SendMessageViewController
@synthesize messageTextView, navItem, slaveId, slaveName;

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
    self.messageTextView.delegate = self;
    self.messageTextView.layer.cornerRadius = 5.0;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.title = self.slaveName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendMessage:(id)sender
{
    NSLog(@"send message");
    NSLog(@"message is : %@", self.messageTextView.text);
    
    NSURLRequest *theRequest = nil;
    if (kUseStaticServerIP) {
        
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:[NSString
                                                     stringWithFormat:@"http://172.17.10.25:1208/sendmessage?master=%@&slave=%@&m=%@",
                                                     [[UIDevice currentDevice] uniqueIdentifier], self.slaveId, [self.messageTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }else{
        
         NSString *urlString = [NSString
                                stringWithFormat:@"%@/sendmessage?master=%@&slave=%@&m=%@",
                                kAppDelegate.serverIPURL,
                                [[UIDevice currentDevice] uniqueIdentifier],
                                self.slaveId,
                                [self.messageTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                ];
        NSLog(@"Request sendmessage URL: %@", urlString);
        theRequest = [NSURLRequest
                      requestWithURL:[NSURL
                                      URLWithString:urlString
                                      ]
                      ];
    }
    
    /* // Previous Implementation
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://172.17.10.25:1208/sendmessage?master=%@&slave=%@&m=%@", [[UIDevice currentDevice] uniqueIdentifier], self.slaveId, [self.messageTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];*/
    
    NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"message sent");
    }
    else {
        NSLog(@"connection failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
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
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:[NSString stringWithFormat:@"Message to %@ sent successfully", self.slaveName] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [successAlert show];
    [successAlert release];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];
}

-(void)doneButtonTapped
{
    [self.messageTextView resignFirstResponder];
    self.navigationController.navigationItem.rightBarButtonItem = nil;
}

@end
