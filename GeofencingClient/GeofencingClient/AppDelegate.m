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
//  AppDelegate.m
//  iOSGeofencingClient
//
//  Created by Rajesh Dongre on 08/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "SplashViewController.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navigationController;
@synthesize apnsToken;
@synthesize splashScreenTimer;
@synthesize serverIPURL = serverIPURL_;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.serverIPURL = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedServerIPKey];
    if ([self.serverIPURL length] == 0) {
        self.serverIPURL = @"http://172.17.10.25:1208";
    }    
    NSLog(@"Using Server IP: %@", self.serverIPURL);
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound)];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
                   autorelease];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    _viewController.title = @"Geofencing";    
    
    /// intialize Splash ScreenController
    self.splashViewController = [[[SplashViewController alloc]
                                  initWithNibName:@"SplashViewController" bundle:nil] autorelease];   
    
    navigationController = [[UINavigationController alloc]
                            initWithRootViewController:self.viewController];
   
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    // Present teh SplashVC modally, this screen is dismissed via a timer.
    [self.viewController presentViewController:self.splashViewController
                                      animated:NO
                                    completion:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [self.viewController.locManager stopUpdatingLocation];
    [self.viewController.locManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    if (self.viewController && self.viewController.locManager)
    {
        [self.viewController.locManager stopMonitoringSignificantLocationChanges];
        [self.viewController.locManager startUpdatingLocation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //reset the badge
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@", newDeviceToken];
    NSLog(@"device token = %@", deviceTokenString);
    NSInteger tokenStringLength = [deviceTokenString length];
    NSRange tokenRange;
    tokenRange.location = 1;
    tokenRange.length = tokenStringLength - 2;
    NSLog(@"deviceTokenString %@",deviceTokenString);
    self.apnsToken = [deviceTokenString substringWithRange:tokenRange];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (userInfo)
    {
        NSLog(@"%@",userInfo);
        
        if ([[userInfo allKeys] containsObject:@"aps"])
        {
            if([[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"alert"])
            {
                NSString *message =[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
                UIAlertView *msgAlert = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [msgAlert show];
                [msgAlert release];

            }
                
        }
    }
}

@end
