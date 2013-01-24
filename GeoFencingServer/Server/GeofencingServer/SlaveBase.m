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
//  SlaveBase.m
//  GeofencingServer
//
//  Created by Praveen Jha on 20/11/12.
//
//

#import "SlaveBase.h"
#import "GeoLocation.h"

@implementation SlaveBase
@synthesize scheduler=_scheduler;
@synthesize region=_region;
@synthesize pushSender=_pushSender;
@synthesize routes =_routes;
@synthesize intiateTheroutes;

+ (BOOL) AMCEnabled
{
    return YES;
}

-(id)init
{
    if (self =[super init])
    {
        // Init the routes dictionary
        self.routes = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.intiateTheroutes = NO;
    }
    return self;
}

-(void) addLocationToRoute:(CLLocationCoordinate2D) location
{
    // Get today's date. Format it as yyyyMMdd. add it as key
    // Add location as value
    // TODO: Set this date as GMT date instead of local date
    @try {

        NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
        [fmtr setDateFormat:@"yyyyMMdd"];
        NSDate * date = [NSDate date];
        NSString *today = [fmtr stringFromDate:date];
        
        if(!self.intiateTheroutes)
        {
            [self.routes removeAllObjects];
            self.intiateTheroutes = YES;
            NSLog(@"intiateTheroutes is set to YES now");
        }
        NSMutableArray *locations = (NSMutableArray *)[self.routes objectForKey:today];
        GeoLocation *gLocation = [[GeoLocation alloc] initWithCoordinateLocation:location];
        if (locations && [locations count]>0)
        {
            [locations addObject:gLocation];
        }
        else
        {
            NSMutableArray *intiateLocation = [[NSMutableArray alloc] initWithCapacity:0];
            [intiateLocation addObject:gLocation];
            [self.routes setObject:intiateLocation forKey:today];
        }
        NSLog(@"locations %@",locations);
    }
    @catch (NSException *exception) {

    }
    @finally {
    }
}

-(NSString *)description
{
    NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
    [finalDict addEntriesFromDictionary:[self dictionaryRepresentation]];
    
    [finalDict removeObjectForKey:@"pushSender"];
    [finalDict removeObjectForKey:@"region"];
    [finalDict removeObjectForKey:@"scheduler"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString =@"";
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;

}

@end
