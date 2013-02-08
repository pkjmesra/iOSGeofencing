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

/*
 INFO:
 
 The GeofencingServer examples demonstrates creating a HTTPS server.
 
 In order to do this, all connections must be secured using SSL/TLS.
 And in order to do that, you need to have a X509 certificate.
 Normally you PAY MONEY for these.
 For example, you purchase them via Verisign.
 However, for our example we're going to create a self-signed certificate.
 
 This means that when you browse the server in Safari, it may present a warning saying the certificate is untrusted. (Which makes sense since you didn't pay money to a trusted 3rd party certificate agency.) To make things easier for testing, when Safari presents this warning, click the "show certificate" button.  And then click the "always trust this certificate" button.
 
 Also, the first time you run the server, it will automatically create a self-signed certificate and add it to your keychain (under the name GeofencingServer). Now the GeofencingServer is authorized to access this keychain item - unless of course the binary changes. So if you make changes, or simply switch between debug/release builds, you'll keep getting prompted by the Keychain utility. To solve this problem, open the Keychain Access application. Find the "GeofencingServer" private key, and change it's Access Control to "Allow all applications to access this item".
 
 INSTRUCTIONS:
 
 Open the Xcode project, and build and go.
 
 On the Xcode console you'll see a message saying:
 "Started HTTP server on port 12345"
 
 Now open your browser and type in the URL:
 https://localhost:12345
 
 Notice that you're using "https" and not "http".
 
 (Replace 12345 with whatever port the server is actually running on.)
 
 Enjoy.
 */
#import <Cocoa/Cocoa.h>

#import <MapKit/MapKit.h>

@class MKMapView;
@class HTTPServer;
@class ShowRouteWindowViewController;
@class SendMessageWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate, MKGeocoderDelegate> {
    IBOutlet NSWindow *window;
    IBOutlet MKMapView *mapView;
    IBOutlet NSTextField *addressTextField;
    NSNumber *circleRadius;
    NSString *pinTitle;
    NSArray *pinNames;
    
    NSMutableArray *coreLocationPins;
	HTTPServer *httpServer;
    ShowRouteWindowViewController *showRouteWindow;
    SendMessageWindowController *sendMessageWC;
    MKAnnotationView * _currentAnnotationView;
    WebScriptObject * _currentScriptObject;
}
//@property (weak) IBOutlet NSTextField *deviceNameText;

@property (nonatomic, strong) NSMutableArray* masters;
//@property (assign) IBOutlet NSWindow *window;
@property (strong) NSString *pinTitle;

- (IBAction)setMapType:(id)sender;
- (IBAction)addCircle:(id)sender;
- (IBAction)addPin:(id)sender;
- (IBAction)searchAddress:(id)sender;
- (IBAction)demo:(id)sender;
- (IBAction)addAdditionalCSS:(id)sender;
- (IBAction)searchDeviceAction:(id)sender;

-(void)saveContentData;

-(NSMutableArray *)getCoreLocationPinsArray;
-(MKMapView *)currentMapView;
@end
