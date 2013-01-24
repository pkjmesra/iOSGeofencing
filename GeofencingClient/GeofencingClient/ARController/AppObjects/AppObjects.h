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
//  AppObjects.h
//  POISearch
//
//  Created by Rajesh Dongre on 27/05/11.
//  Copyright 2011 Research2Development, Nagpur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

#pragma mark -
#pragma mark Converter Object

@interface AppObjectConvertor : NSObject
{
	
}

+(NSMutableArray*)getObjectListForObjectType:(ObjectType)type;

@end

@interface Query : NSObject {
	
}
+(NSString *)getObjectQuery:(ObjectType)type;
@end

@interface Poi :NSObject
{		
	NSString   *imageURL;
	NSString   *iD;
	NSString   *address;
	double     latitude;
	double     longitude;		
	NSString   *name;
	NSString   *phone;
	NSString   *fax;
	double     distance;
	ObjectType type;
}
@property (nonatomic, retain) NSString   *imageURL;
@property (nonatomic, retain) NSString   *iD;
@property (nonatomic, retain) NSString   *address;
@property (nonatomic)         double     latitude;
@property (nonatomic)         double     longitude;
@property (nonatomic, retain) NSString   *name;
@property (nonatomic, retain) NSString   *phone;
@property (nonatomic, retain) NSString   *fax;
@property (nonatomic)         double     distance;
@property (nonatomic)         ObjectType type;

- (NSComparisonResult)comparePoiNames:(Poi *)poi;
- (NSComparisonResult)comparePoiDistances:(Poi *)poi;
+ (NSMutableArray *)getObjectsForType:(ObjectType)objType;

@end

@interface PoiImage:NSObject
{
    NSString *imgURL;
    NSData   *imgData;
}

@property (nonatomic, retain) NSString *imgURL;
@property (nonatomic, retain) NSData   *imgData;
@end