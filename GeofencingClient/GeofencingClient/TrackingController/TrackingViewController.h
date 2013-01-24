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
//  TrackingViewController.h
//  iOSGeofencingClient
//
//  Created by Pravin Potphode on 15/11/12.
//
//

typedef enum {
    QueryTypeGetMasters,
    QueryTypeAddMaster,
    QueryTypeAddSlave,
    QueryTypeAddCircularRegion,
    QueryTypeUpdateSlaveLocation,
    QueryTypeUpdateSlaveSpeed,
    QueryTypeGetRoutePoints,
    QueryTypeGetSlaves
} QueryType;

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "MySlavesViewController.h"
#import "MastersViewController.h"

@protocol UpdateSlaveInfoDelegate <NSObject>
@required

-(void) updateSlaveForMonitoring:(NSString*)slaveId;
-(void) updateDateForMonitoring:(NSString*)dateString;
-(void) updateMasterForMonitoring:(NSString*)masterId;

@end

@interface TrackingViewController : UIViewController <UpdateSlaveDelegate, UpdateMasterDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    UIButton *masterRegButton;
    UIButton *slaveRegButton;
    UIButton *slaveInfoButton;
    UIButton *masterInfoButton;
    NSMutableData *receivedData;
    QueryType queryType;
    CLLocation *currentLocation;
    AppDelegate *appDelegate;
    id <UpdateSlaveInfoDelegate> delegate;
    NSString    *currentlyMonitoredSlave;
   	UIActivityIndicatorView *activityIndicator;
    UIToolbar *radiusToolbar;
    UIPickerView *radiusPickerView;
    NSArray *radiusRangeArray;
    NSInteger selectedRadius;
}

@property(nonatomic, retain) IBOutlet UIButton *masterRegButton;
@property(nonatomic, retain) IBOutlet UIButton *slaveRegButton;
@property(nonatomic, retain) IBOutlet UIButton *slaveInfoButton;
@property(nonatomic, retain) IBOutlet UIButton *masterInfoButton;
@property(nonatomic, retain) NSString    *currentlyMonitoredSlave;
@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) CLLocation *currentLocation;
@property(nonatomic, retain) NSArray *radiusRangeArray;
@property(nonatomic) NSInteger selectedRadius;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) IBOutlet UIToolbar *radiusToolbar;
@property(nonatomic, retain) IBOutlet UIPickerView *radiusPickerView;
@property(strong) id <UpdateSlaveInfoDelegate> delegate;
-(IBAction)onCancelBtn:(id)sender;
-(IBAction)registerAsMaster:(id)sender;
-(IBAction)registerAsSlave:(id)sender;
-(IBAction)onSlaveInfo:(id)sender;
-(IBAction)onMasterInfo:(id)sender;

@end
