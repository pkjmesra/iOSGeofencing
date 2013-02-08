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

#import "MyHTTPConnection.h"
#import "HTTPLogging.h"
#import "DDKeychain.h"
#import "Master.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;

@interface MyHTTPConnection (Private)

-(NSMutableDictionary *)getDataOfQueryString:(NSString *)url;

@end

@implementation MyHTTPConnection

/**
 * Overrides HTTPConnection's method
**/
- (BOOL)isSecureServer
{
	HTTPLogTrace();
	
	// Create an HTTPS server (all connections will be secured via SSL/TLS)
	return NO;
}

/**
 * Overrides HTTPConnection's method
 * 
 * This method is expected to returns an array appropriate for use in kCFStreamSSLCertificates SSL Settings.
 * It should be an array of SecCertificateRefs except for the first element in the array, which is a SecIdentityRef.
**/
- (NSArray *)sslIdentityAndCertificates
{
	HTTPLogTrace();
	
	NSArray *result = [DDKeychain SSLIdentityAndCertificates];
	if([result count] == 0)
	{
		[DDKeychain createNewIdentity];
		return [DDKeychain SSLIdentityAndCertificates];
	}
	return result;
}

-(NSMutableDictionary *)getDataOfQueryString:(NSString *)url{
    
    NSArray *strURLParse = [url componentsSeparatedByString:@"?"];
    NSMutableDictionary *dicQueryStringElement = [[NSMutableDictionary alloc]init];
    NSMutableArray *arrQueryStringData = [[NSMutableArray alloc] init];
    if ([strURLParse count] < 2) {
        return dicQueryStringElement;
    }
    NSArray *arrQueryString = [[strURLParse objectAtIndex:1] componentsSeparatedByString:@"&"];
    for (int i=0; i < [arrQueryString count]; i++) {
        NSArray *arrElement = [[arrQueryString objectAtIndex:i] componentsSeparatedByString:@"="];
        if ([arrElement count] == 2) {
            [dicQueryStringElement setObject:[arrElement objectAtIndex:1] forKey:[arrElement objectAtIndex:0]];
        }
        [arrQueryStringData addObject:dicQueryStringElement];
    }
    
    return dicQueryStringElement; 
}

- (NSObject<HTTPResponse> *)addMaster:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *name = [dict objectForKey:@"name"];
    NSString *apnsdevicetoken = [dict objectForKey:@"apnsdevicetoken"];
    NSLog(@"path for request:%@, master=%@, name=%@,apnsdevicetoken:%@",path,master, name,apnsdevicetoken);
    if ([master length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        apnsdevicetoken =[[apnsdevicetoken stringByReplacingOccurrencesOfString:@"<" withString:@""] lowercaseString];
        apnsdevicetoken =[apnsdevicetoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        apnsdevicetoken =[apnsdevicetoken stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        } 
        if (!masterExists)
        {
            Master *ms = [[Master alloc] init];
            ms.UDID = master;
            ms.name=name;
            ms.deviceToken = apnsdevicetoken;
            [[delegate masters] addObject:ms];
            
            Slave *sl = [[Slave alloc] init];
            sl.UDID = master;
            sl.master = master;
            sl.masterName = ms.name;
            sl.name = name;
            sl.deviceToken = ms.deviceToken;
            [ms.slaves addObject:sl];

        }
        else
        {
            foundMaster.name=name;
            foundMaster.deviceToken = apnsdevicetoken;
        }
        [delegate saveContentData];
        NSData * data = [[NSString stringWithFormat:@"Master:%@ added.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:200];
        return myResponse;
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@ could not be added.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)getRoutes:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSLog(@"path for request:%@, master=%@, slave=%@, date:%@",path,master, slave, date);
    if ([master length]>0 && [slave length]>0 && [date length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL slaveExists =NO;
        BOOL masterExists =NO;
        Master *foundMaster;
        Slave *foundSlave;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            for (Slave *sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave = sl;
                    break;
                }
            }
            if (slaveExists)
            {
                NSLog(@"foundSlave.routes:%@",foundSlave.routes);
                NSError *error;
                
                NSMutableDictionary * finalDict =[NSMutableDictionary dictionaryWithCapacity:0];
                [finalDict addEntriesFromDictionary:[foundSlave dictionaryRepresentation]];
                
                [finalDict removeObjectForKey:@"pushSender"];
                [finalDict removeObjectForKey:@"region"];
                [finalDict removeObjectForKey:@"scheduler"];
                NSDictionary * routesDict =[finalDict objectForKey:@"routes"];
                NSArray *routesForDate =(NSArray *)[routesDict objectForKey:date];
                if (routesForDate &&[routesForDate count]>0)
                {
                    
                }
                else
                {
                    routesForDate = [NSMutableArray array];
                }
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:routesForDate
                                                                   options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                     error:&error];
                NSString *jsonString =@"";
                if (! jsonData) {
                    NSLog(@"Got an error: %@", error);
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }

                NSData * data = [[NSString stringWithFormat:@"%@",jsonString] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n was found. But, Slave:%@ was not found.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n was not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:500];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n did not have specified Slave:%@ or incorrect data format.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)addRegion:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *originx = [dict objectForKey:@"x"];
    NSString *originy = [dict objectForKey:@"y"];
    NSString *radius = [dict objectForKey:@"r"];
    NSString *updatefrequency=[dict objectForKey:@"updatefrequency"];
    
    NSLog(@"path for request:%@, master=%@, slave=%@, origin:{%@, %@}, radius:%@, updatefrequency:%@",path,master, slave, originx, originy, radius,updatefrequency);
    if ([master length]>0 && [slave length]>0 && [originx length]>0 && [originy length]>0 && [radius length]>0 && [updatefrequency length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL slaveExists =NO;
        BOOL masterExists =NO;
        Master *foundMaster;
        Slave *foundSlave;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            for (Slave *sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave = sl;
                    break;
                }
            }
            if (slaveExists)
            {
                [foundSlave setRegionX:originx Y:originy Radius:radius Frequency:updatefrequency];
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n added the Slave:%@ for monitoring with given frequency (seconds).", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n was found. But, Slave:%@ was not found. Hence, not added for region monitoring.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n was not found. Hence, Slave:%@ was not added for region monitoring.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:500];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n did not have specified Slave:%@ or incorrect data format.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)sendMessage:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *message = [dict objectForKey:@"m"];
    
    NSLog(@"path for request:%@, master=%@, slave=%@, message:%@",path,master, slave, message);
    if ([master length]>0 && [slave length]>0 && [message length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL slaveExists =NO;
        BOOL masterExists =NO;
        Master *foundMaster;
        Slave *foundSlave;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            for (Slave *sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave = sl;
                    break;
                }
            }
            if (slaveExists)
            {
                [foundSlave sendMessage:message];
                NSData * data = [[NSString stringWithFormat:@"Sent message to the Slave:%@.", slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n was found. But, Slave:%@ was not found. Hence, message not sent.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n was not found. Hence, Slave:%@ was not sent any message.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:500];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n did not have specified Slave:%@ or incorrect data format.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)removeMaster:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSLog(@"path for request:%@, master=%@",path,master);
    if ([master length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                foundMaster = ms;
                masterExists =YES;
                break;
            }
        }
        if (masterExists)
        {
            [[delegate masters] removeObject:foundMaster];
            NSData * data = [[NSString stringWithFormat:@"Master:%@ removed.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:200];
            return myResponse;
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ could not be found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@ could not be removed.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)removeSlave:(NSDictionary *)dict
                                path:(NSString *)path
                            delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSLog(@"path for request:%@, master=%@, slave=%@",path,master, slave);
    if ([master length]>0 && [slave length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL slaveExists =NO;
        BOOL masterExists =NO;
        Master *foundMaster;
        Slave *foundSlave;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            for (Slave *sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave = sl;
                    break;
                }
            }
            if (slaveExists)
            {
                [foundMaster.slaves removeObject:foundSlave];
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n removed the Slave:%@", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Master:%@\n could not remove the Slave:%@ since it does not exist.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n was not found. Hence, Slave:%@ was not removed.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:500];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n did not add specified Slave:%@", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)addSlave:(NSDictionary *)dict
                                path:(NSString *)path
                            delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *name = [dict objectForKey:@"name"];
    NSString *apnsdevicetoken = [dict objectForKey:@"apnsdevicetoken"];
    NSLog(@"path for request:%@, master=%@, slave=%@, name=%@ apnsToken = %@",path,master, slave, name,apnsdevicetoken);
    if ([master length]>0 && [slave length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        
        apnsdevicetoken =[[apnsdevicetoken stringByReplacingOccurrencesOfString:@"<" withString:@""] lowercaseString];
        apnsdevicetoken =[apnsdevicetoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        apnsdevicetoken =[apnsdevicetoken stringByReplacingOccurrencesOfString:@"%20" withString:@" "];

        NSArray * masters= [delegate masters];
        BOOL slaveExists =NO;
        BOOL masterExists =NO;
        Master *foundMaster;
        Slave *foundSlave;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            for (Slave *sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave =sl;
                    break;
                }
            }
            if (!slaveExists)
            {
                Slave *sl = [[Slave alloc] init];
                sl.UDID = slave;
                sl.master = master;
                sl.masterName = foundMaster.name;
                sl.name = name;
                sl.deviceToken = apnsdevicetoken;
                [foundMaster.slaves addObject:sl];
            }
            else
            {
                foundSlave.name=name;
                foundSlave.deviceToken = apnsdevicetoken;
            }
            [delegate saveContentData];
            NSLog(@"slave %@",slave);
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n added a new Slave:%@", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:200];
            return myResponse;
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@\n was not found. Hence, Slave:%@ was not added.", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:500];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n did not add specified Slave:%@", master, slave] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)getSlaves:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSLog(@"path for request:%@, master=%@",path,master);
    if ([master length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            NSData * data = [[NSString stringWithFormat:@"%@\n", [foundMaster description]] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:200];
            return myResponse;
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n could not be added.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)getSlaveForMaster:(NSDictionary *)dict
                                         path:(NSString *)path
                                     delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSLog(@"path for request:%@, master=%@, slave=%@",path,master, slave);
    if ([master length]>0 && [slave length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            BOOL slaveExists =NO;
            Slave *foundSlave;
            for (Slave * sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave =sl;
                    break;
                }
            }
            if (slaveExists)
            {
                NSData * data = [[NSString stringWithFormat:@"%@\n", [foundSlave description]] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Slave:%@ for master :%@ not found.",slave, master] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n could not be found.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)getMaster:(NSDictionary *)dict
                                 path:(NSString *)path
                             delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSLog(@"path for request:%@, master=%@",path,master);
    if ([master length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            NSData * data = [[NSString stringWithFormat:@"%@\n", [foundMaster description]] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:200];
            return myResponse;
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n could not be found or data incorrect.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)getMasters:(NSString *)path
                              delegate:(AppDelegate *)delegate
{
    NSLog(@"path for request:%@",path);
    NSData * data = [[NSString stringWithFormat:@"%@\n", [delegate description]] dataUsingEncoding:NSUTF8StringEncoding];
    HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
    [myResponse setStatus:200];
    return myResponse;
}

- (NSObject<HTTPResponse> *)updateSlaveLocation:(NSDictionary *)dict
                                           path:(NSString *)path
                                       delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *xs = [dict objectForKey:@"x"];
    NSString *ys = [dict objectForKey:@"y"];
    NSLog(@"path for request:%@, master=%@, slave=%@, x=%@, y=%@",path,master, slave, xs, ys);
    if ([master length]>0 && [slave length]>0 && [xs length]>0 && [ys length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            BOOL slaveExists =NO;
            Slave *foundSlave;
            for (Slave * sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave =sl;
                    break;
                }
            }
            if (slaveExists)
            {
                NSString *xdigits = [xs stringByTrimmingCharactersInSet:
                                     [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                NSString *ydigits = [ys stringByTrimmingCharactersInSet:
                                     [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                [foundSlave setLocationForLatitude:xdigits longitude:ydigits];
                [foundSlave addLocationToRoute:CLLocationCoordinate2DMake([xdigits doubleValue],[ydigits doubleValue])];
                if ([master isEqualToString:slave])
                {
                    // Master is it's own slave
                    [foundMaster setLocationForLatitude:xdigits longitude:ydigits];
                }
                NSData * data = [[NSString stringWithFormat:@"Location set to:{%f,%f} for slave:%@ belonging to master:%@\n",
                                  [foundSlave location].x,
                                  [foundSlave location].y, [foundMaster UDID], [foundMaster UDID]] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Slave:%@ for master :%@ not found.",slave, master] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n  could not be found or data is incorrect.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)updateSlaveSpeed:(NSDictionary *)dict
                                        path:(NSString *)path
                                    delegate:(AppDelegate *)delegate
{
    NSString *master = [dict objectForKey:@"master"];
    NSString *slave = [dict objectForKey:@"slave"];
    NSString *speed = [dict objectForKey:@"speed"];
    NSLog(@"path for request:%@, master=%@, slave=%@, speed=%@",path,master, slave, speed);
    if ([master length]>0 && [slave length]>0 && [speed length]>0)
    {
        master =[[master stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        slave =[[slave stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSArray * masters= [delegate masters];
        BOOL masterExists =NO;
        Master *foundMaster;
        for (Master * ms in masters) {
            if ([[ms UDID] isEqualToString:master])
            {
                masterExists =YES;
                foundMaster =ms;
                break;
            }
        }
        if (masterExists)
        {
            BOOL slaveExists =NO;
            Slave *foundSlave;
            for (Slave * sl in foundMaster.slaves) {
                if ([[sl UDID] isEqualToString:slave])
                {
                    slaveExists =YES;
                    foundSlave =sl;
                    break;
                }
            }
            if (slaveExists)
            {
                NSString *digits = [speed stringByTrimmingCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                foundSlave.speed = [digits floatValue];
                if ([master isEqualToString:slave])
                {
                    // Master is it's own slave
                    foundMaster.speed=[digits floatValue];
                }
                NSData * data = [[NSString stringWithFormat:@"Speed set to:%f for slave:%@ belonging to master:%@\n",foundSlave.speed ,[foundSlave UDID], [foundMaster UDID]] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:200];
                return myResponse;
            }
            else
            {
                NSData * data = [[NSString stringWithFormat:@"Slave:%@ for master :%@ not found.",slave, master] dataUsingEncoding:NSUTF8StringEncoding];
                HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
                [myResponse setStatus:404];
                return myResponse;
            }
        }
        else
        {
            NSData * data = [[NSString stringWithFormat:@"Master:%@ not found.", master] dataUsingEncoding:NSUTF8StringEncoding];
            HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
            [myResponse setStatus:404];
            return myResponse;
        }
    }
    else
    {
        NSData * data = [[NSString stringWithFormat:@"Master:%@\n not found or data incorrect.", master] dataUsingEncoding:NSUTF8StringEncoding];
        HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
        [myResponse setStatus:500];
        return myResponse;
    }
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method
                                              URI:(NSString *)path
{
    AppDelegate * delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSDictionary * dict = [self getDataOfQueryString:path];
    
    // Add a new master with it's UDID
    if ([path rangeOfString:@"addmaster"].location != NSNotFound &&
        [path rangeOfString:@"master="].location != NSNotFound &&
        [path rangeOfString:@"name="].location != NSNotFound &&
        [path rangeOfString:@"apnsdevicetoken="].location != NSNotFound)
    {
        return [self addMaster:dict path:path delegate:delegate];
    }
    // Add a new master with it's UDID
    else if ([path rangeOfString:@"updatemaster"].location != NSNotFound &&
        [path rangeOfString:@"master="].location != NSNotFound &&
        [path rangeOfString:@"name="].location != NSNotFound &&
        [path rangeOfString:@"apnsdevicetoken="].location != NSNotFound)
    {
        return [self addMaster:dict path:path delegate:delegate];
    }
    // Add a new master with it's UDID
    else if ([path rangeOfString:@"sendmessage"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound &&
             [path rangeOfString:@"slave="].location != NSNotFound &&
             [path rangeOfString:@"m="].location != NSNotFound)
    {
        return [self sendMessage:dict path:path delegate:delegate];
    }
    // Add a new region (origin, radius) for a slave with it's UDID
    else if ([path rangeOfString:@"getroutes"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound &&
             [path rangeOfString:@"slave="].location != NSNotFound &&
             [path rangeOfString:@"date="].location != NSNotFound)
    {
        return [self getRoutes:dict path:path delegate:delegate];
    }    
    // Add a new region (origin, radius) for a slave with it's UDID
    else if ([path rangeOfString:@"addcircularregionforslave"].location != NSNotFound &&
        [path rangeOfString:@"master="].location != NSNotFound &&
        [path rangeOfString:@"slave="].location != NSNotFound &&
        [path rangeOfString:@"x="].location != NSNotFound &&
        [path rangeOfString:@"y="].location != NSNotFound &&
        [path rangeOfString:@"r="].location != NSNotFound &&
        [path rangeOfString:@"updatefrequency="].location != NSNotFound)
    {
        return [self addRegion:dict path:path delegate:delegate];
    }
    // Add a new slave to a master with their UDIDs
    else if ([path rangeOfString:@"addslave"].location != NSNotFound &&
             ([path rangeOfString:@"master="].location != NSNotFound &&
              [path rangeOfString:@"slave="].location != NSNotFound) &&
             [path rangeOfString:@"name="].location != NSNotFound &&
             [path rangeOfString:@"apnsdevicetoken="].location != NSNotFound)
	{
        return [self addSlave:dict path:path delegate:delegate];
    }
    // remove a master
    else if ([path rangeOfString:@"removemaster"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound)
	{
        return [self removeMaster:dict path:path delegate:delegate];
	}
    // remove a slave
    else if ([path rangeOfString:@"removeslave"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound &&
             [path rangeOfString:@"slave="].location != NSNotFound)
	{
        return [self removeSlave:dict path:path delegate:delegate];
	}
    // Get all slaves for a given master with master's UDID
    else if ([path rangeOfString:@"getslaves"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound)
    {
        return [self getSlaves:dict path:path delegate:delegate];
    }
    // Get a specific slave for a given master with master's UDID
    else if ([path rangeOfString:@"getslave"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound &&
             [path rangeOfString:@"slave="].location != NSNotFound)
    {
        return [self getSlaveForMaster:dict path:path delegate:delegate];
    }
    // Get a master with it's UDID
    else if ([path rangeOfString:@"getmaster"].location != NSNotFound &&
             [path rangeOfString:@"master="].location != NSNotFound)
    {
        return [self getMaster:dict path:path delegate:delegate];
    }
    // Get all masters
    else if ([path rangeOfString:@"getmasters"].location != NSNotFound)
	{
        return [self getMasters:path delegate:delegate];
	}
    // Update a slave's current location to a master with their UDIDs
    else if ([path rangeOfString:@"updateslavelocation"].location != NSNotFound &&
             ([path rangeOfString:@"master="].location != NSNotFound &&
              [path rangeOfString:@"slave="].location != NSNotFound) &&
             [path rangeOfString:@"x="].location != NSNotFound &&
             [path rangeOfString:@"y="].location != NSNotFound)
	{
        return [self updateSlaveLocation:dict path:path delegate:delegate];
    }
    // Update a slave's current speed to a master with their UDIDs
    else if ([path rangeOfString:@"updateslavespeed"].location != NSNotFound &&
             ([path rangeOfString:@"master="].location != NSNotFound &&
              [path rangeOfString:@"slave="].location != NSNotFound &&
              [path rangeOfString:@"speed="].location != NSNotFound))
	{
        return [self updateSlaveSpeed:dict path:path delegate:delegate];
    }
    
    NSString * supportedAPIs = [NSString stringWithFormat:@"Following APIs are supported:\n\n%@\n\n%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\n%@\n\n\n",
                                @"To add yourself as a new master:\naddmaster?master=<master UDID>&name=<master's name>&apnsdevicetoken=<APNS device token (including spaces) so you can receive notifications for your slaves>",
                                @"To remove yourself as a master:\nremovemaster?master=<master UDID>",
                                @"To add yourself as a new slave to an existing master:\naddslave?master=<master UDID>&slave=<slave UDID>&name=<slave's name>&apnsdevicetoken=<APNS device token (including spaces) so you can receive notifications>",
                                @"To remove yourself as a slave from an existing master:\nremoveslave?master=<master UDID>&slave=<slave UDID>",
                                @"To get all slaves' data for a given master:\ngetslaves?master=<master UDID>",
                                @"To get a slave's data for a given master:\ngetslave?master=<master UDID>&slave=<slave UDID>",
                                @"To get a master's data:\ngetmaster?master=<master UDID>",
                                @"To get all masters' data:\ngetmasters",
                                @"To update speed of an existing slave of an existing master:\nupdateslavespeed?master=<master UDID>&slave=<slave UDID>&speed=<some speed e.g. 45.67456>",
                                @"To update location of an existing slave of an existing master:\nupdateslavelocation?master=<master UDID>&slave=<slave UDID>&x=<location x e.g. 68.34>&y=<some location y e.g. 87.434>",
                                @"To add a circular region for monitoring a slave: addcircularregionforslave?master=<master's UDID>&slave=<Slave's UDID>&x=<Circle's origin's X coordinate>&y=<Circle's origin's Y coordinate>&r=<Circle's radius>&updatefrequency=<frequency (seconds) in float at which master wants to monitor the slave>",
                                @"To get route history of a slave for a date:\ngetroutes?master=<master UDID>&slave=<slave UDID>&date=<date for which route history is desired. Date in yyyyMMdd format>",
                                @"To send message to a slave for a master:\nsendmessage?master=<master UDID>&slave=<slave UDID>&m=<message>"];
    NSData * data = [supportedAPIs dataUsingEncoding:NSUTF8StringEncoding];
    HTTPDataResponse * myResponse = [[HTTPDataResponse alloc] initWithData:data];
    [myResponse setStatus:200];
    return myResponse;
    
    return [super httpResponseForMethod:method URI:path];
}

@end
