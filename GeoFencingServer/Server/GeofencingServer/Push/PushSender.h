//
//  ApplicationDelegate.h
//  PushMeBaby
//
//  Created by Stefan Hafeneger on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ioSock.h"

@interface PushSender : NSObject {
	NSString *_deviceToken, *_payload, *_certificate;
	otSocket socket;
	SSLContextRef context;
	SecKeychainRef keychain;
	SecCertificateRef certificate;
	SecIdentityRef identity;
    NSMutableArray *messageArray;
}

@property(nonatomic, strong) NSMutableArray *messageArray;

@property(nonatomic, strong) NSString *deviceToken;
@property(nonatomic, strong) NSString *payload;
@property(nonatomic, strong) NSString *certificate;

#pragma mark public
- (void)push;
- (void)disconnect;
- (void)connect;
@end
