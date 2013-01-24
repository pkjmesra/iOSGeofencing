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
//  SettingsViewController.m
//  iOSGeofencingClient
//
//  Created by Research2Development on 07/12/12.
//
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

#import "Constants.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize ip1TextField;
@synthesize ip2TextField;
@synthesize ip3TextField;
@synthesize ip4TextField;
@synthesize portTextField;

@synthesize doneBarButton, cancelBarButton;

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
    [self.doneBarButton setAction:@selector(doneAction)];
    [self.cancelBarButton setAction:@selector(cancelAction)];
    
    [self.ip1TextField becomeFirstResponder];
    [self loadExistingIPPort];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadExistingIPPort
{
    if ([kAppDelegate.serverIPURL length] >0)
    {
        NSString *ip = [[kAppDelegate.serverIPURL lowercaseString] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        NSArray * ipPort = [ip componentsSeparatedByString:@":"];
        if ([ipPort count]>=2)
        {
            NSArray *ips =[[ipPort objectAtIndex:0] componentsSeparatedByString:@"."];
            if ([ips count]>=4)
            {
                self.ip1TextField.text =[ips objectAtIndex:0];
                self.ip2TextField.text=[ips objectAtIndex:1];
                self.ip3TextField.text=[ips objectAtIndex:2];
                self.ip4TextField.text=[ips objectAtIndex:3];
            }
            self.portTextField.text=[ipPort objectAtIndex:1];
        }
    }
}

#pragma mark - UITextfield Delegate

-(BOOL) textField:(UITextField *)textField
 shouldChangeCharactersInRange:(NSRange)range
 replacementString:(NSString *)string
{
    
    if(textField.tag != 10 &&
       textField.text.length >= 3 && range.length == 0) {
        
        return NO;
    }else if(textField.tag == 10 &&
             textField.text.length >= 4 && range.length == 0){   
        
        return NO;
    }
    return YES;
}

- (void)doneAction{

    if ( (self.ip1TextField.text.length > 0  && self.ip1TextField.text.length <= 3) &&
         (self.ip2TextField.text.length > 0  && self.ip2TextField.text.length <= 3) &&
         (self.ip3TextField.text.length > 0  && self.ip3TextField.text.length <= 3) &&
         (self.ip1TextField.text.length > 0  && self.ip1TextField.text.length <= 3) &&
          self.portTextField.text.length > 0 && self.portTextField.text.length <= 4){
        
        kAppDelegate.serverIPURL = nil;
        
        kAppDelegate.serverIPURL = [NSString
                                    stringWithFormat:@"http://%@.%@.%@.%@:%@",
                                    self.ip1TextField.text,
                                    self.ip2TextField.text,
                                    self.ip3TextField.text,
                                    self.ip4TextField.text,
                                    self.portTextField.text];
        NSLog(@"New Server URL: %@", kAppDelegate.serverIPURL);
        
        // Save to user defaults, so allow it to persist for next app launch.
        [[NSUserDefaults standardUserDefaults] setObject:kAppDelegate.serverIPURL forKey:kSavedServerIPKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self dismissModalViewControllerAnimated:YES];
    }else{
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Fields"
                                                        message:@"Please enter proper values in all textfields. 'Valid IPs 0-3 digits.' and 'Valid Post: 0-4' "
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


- (void)cancelAction{

    [self dismissModalViewControllerAnimated:YES];
}
@end
