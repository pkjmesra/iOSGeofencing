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
//  SendMessageWindowController.h
//  GeofencingServer
//
//  Created by NAG1-LMAC-26589 on 27/11/12.
//
//

#import <Cocoa/Cocoa.h>
#import "PushSender.h"
#import "AppDelegate.h"

@interface SendMessageWindowController : NSWindowController <NSTextViewDelegate>
{
    NSString *message;
    NSInteger needToSendMeesageToAllClient;
    NSInteger needToSendRelatedClientOnly;
    AppDelegate *delegate;
    NSString *slaveUDID;
}
@property (nonatomic, strong)   NSString *message;
@property (nonatomic,strong)    NSString *slaveUDID;

@property (weak) IBOutlet NSTextField *messageText;
@property (weak) IBOutlet NSTextField *charectorCount;

@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSButton *sendButton;
@property (weak) IBOutlet NSButton *sendToAllClient;
@property (weak) IBOutlet NSButton *sendToRelatedClientOnly;

@property (nonatomic, strong) PushSender *pushSender;

- (IBAction)sendToRelatedClientAction:(id)sender;
- (IBAction)cancleButtonAction:(id)sender;
- (IBAction)sendButtonAction:(id)sender;
- (IBAction)sendToAllClientAction:(id)sender;
@end
