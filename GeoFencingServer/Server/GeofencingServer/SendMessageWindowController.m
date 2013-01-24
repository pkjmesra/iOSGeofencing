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
//  SendMessageWindowController.m
//  GeofencingServer
//
//  Created by NAG1-LMAC-26589 on 27/11/12.
//
//

#import "SendMessageWindowController.h"
#import "Slave.h"
#import "Master.h"

@interface SendMessageWindowController ()

@end

@implementation SendMessageWindowController
@synthesize message;
@synthesize pushSender;
@synthesize slaveUDID;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)cancleButtonAction:(id)sender {
    //! Need to close the window
    [self resetAllControls];
}
-(void)resetAllControls
{
    [self.messageText setStringValue:@""];
    [self.charectorCount setStringValue:@"0"];
    [self.sendToRelatedClientOnly setEnabled:YES];
    [self.sendToRelatedClientOnly setState:NO];
    [self.sendToAllClient setState:NO];
    needToSendMeesageToAllClient = NO;
    needToSendRelatedClientOnly = NO;

}

- (IBAction)sendButtonAction:(id)sender {
    if([self.message length] <=200)
    {
        [self sendMessage];
    }
    else
    {
        //! need to show the alert message
        NSAlert *alert = [NSAlert alertWithMessageText:@"Can't send message"
                                         defaultButton:@"Ok"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Can send only 200 words in message"];

        
    }
}

- (IBAction)sendToAllClientAction:(id)sender {
    NSButton *button = (NSButton *)(sender);
    needToSendMeesageToAllClient = button.state;
    if(needToSendMeesageToAllClient)
    {
        [self.sendToRelatedClientOnly setState:YES];
        [self.sendToRelatedClientOnly setEnabled:NO];
    }
    else
    {
        [self.sendToRelatedClientOnly setState:YES];
        [self.sendToRelatedClientOnly setEnabled:YES];
    }
}
- (IBAction)sendToRelatedClientAction:(id)sender {
    NSButton *button = (NSButton *)(sender);    
    needToSendRelatedClientOnly = button.state;
}



- (void) controlTextDidChange: (NSNotification *) notification
{
    NSTextField* textField = [notification object];
    self.message = [textField stringValue];
    
    if ([self.message length] > 200) {
        [self.charectorCount setTextColor:[NSColor redColor]];
    } else {
        [self.charectorCount setTextColor:[NSColor blackColor]];
//        [textField setStringValue:[self.message uppercaseString]];
    }
    [self.charectorCount setStringValue:[NSString stringWithFormat:@"%ld",[self.message length]]];
}

-(void) sendMessage
{
    // Send PUSH notification here for the slave went out of boundary
  //  NSLog(@"Slave :%@ is out of the defined region", self.name);
    if (!self.pushSender)
    {
        self.pushSender =[[PushSender alloc] init];
        [self.pushSender connect];
    }
    
    NSArray * allMasters =delegate.masters;
    // Broadcast to all
    if(needToSendMeesageToAllClient)
    {
        for(Master *ms in allMasters)
        {
            for(Slave *sl in ms.slaves)
            {
                self.pushSender.deviceToken = sl.deviceToken;
                self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@ \",\"badge\":1}}",
                                          [self.message stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
                
                [self.pushSender push];
            }
            
        }
    }
    
        BOOL slaveExists;
        BOOL masterExists;
        Slave *foundSlave;
        Master *foundMaster;
    
        for(Master *ms in allMasters)
        {
            for(Slave *sl in ms.slaves)
            {
                if ([[sl UDID] isEqualToString:slaveUDID])
                {
                    masterExists =YES;
                    foundMaster = ms;
                    foundSlave = sl;
                    slaveExists =YES;
                    break;
                }

            }
        }

    // Broadcast message to siblings of this slave
    if(needToSendRelatedClientOnly)
    {
        if(masterExists)
        {
            for(Slave *sl in foundMaster.slaves)
            {
                self.pushSender.deviceToken = sl.deviceToken;
                self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@ \",\"badge\":1}}",
                                          [self.message stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
                
                [self.pushSender push];
                
            }

        }
    }


    // Send only to this client/slave
    if (!needToSendMeesageToAllClient && !needToSendRelatedClientOnly)
    {
        if (slaveExists)
        {
            self.pushSender.deviceToken = foundSlave.deviceToken;
            self.pushSender.payload =[NSString stringWithFormat:@"{\"aps\":{\"alert\":\"%@ \",\"badge\":1}}",
                                      [self.message stringByReplacingOccurrencesOfString:@"%20" withString:@""]];
            
            [self.pushSender push];
        }
    }
    
     [self resetAllControls];
}

@end
