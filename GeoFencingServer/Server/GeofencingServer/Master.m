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
//  Master.m
//  GeofencingServer
//
//  Created by Praveen Jha on 19/11/12.
//
//

#import "Master.h"

@implementation Master

@synthesize slaves =_slaves;

+ (BOOL) AMCEnabled
{
    return YES;
}

-(id)init
{
    if (self = [super init])
    {
        self.slaves = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.UDID  = [dict valueForKey:@"UDID"];
        NSDictionary* loc = (NSDictionary*)[dict valueForKey:@"location"];
        NSString *xl = [[loc valueForKey:@"x"] stringByTrimmingCharactersInSet:
                             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *yl = [[loc valueForKey:@"y"] stringByTrimmingCharactersInSet:
                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        self.location   = CGPointMake([xl floatValue], [yl floatValue]);
        
        NSString *spd = [[dict valueForKey:@"speed"] stringByTrimmingCharactersInSet:
                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        self.speed   = [spd floatValue];
        self.master   = [dict valueForKey:@"master"];
    }
    
    return self;
}

-(NSString *)description
{
    NSString *me = [NSString stringWithFormat:@"{\"Master\":{\"UDID\":\"%@\",\"master\":\"%@\",\"location\":{\"x\":\"%f\",\"y\":\"%f\"}, \"speed\":\"%f\"", self.UDID, self.master, self.location.x, self.location.y, self.speed];

    for (Slave *sl in self.slaves) {
        me = [NSString stringWithFormat:@"%@,\"Slave\":%@",me,[sl description]];
        
    }
    me = [NSString stringWithFormat:@"%@}}",me];
    
    NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
    [finalDict addEntriesFromDictionary:[self dictionaryRepresentation]];
    NSArray *slvs =[finalDict objectForKey:@"slaves"];
    if ([slvs count]>0)
    {
        for (NSMutableDictionary *slv in slvs) {
            [slv removeObjectForKey:@"pushSender"];
            [slv removeObjectForKey:@"region"];
            [slv removeObjectForKey:@"scheduler"];
            [slv removeObjectForKey:@"routes"];
        }
    }
    NSLog(@"Master:%@", finalDict);
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

-(BOOL) isMaster
{
    return YES;
}

@end
