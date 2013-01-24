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
//  AppObjects.m
//  POISearch
//
//  Created by Rajesh Dongre on 27/05/11.
//  Copyright 2011 Research2Development, Nagpur. All rights reserved.
//

#import "AppObjects.h"
#import <libxml/xmlmemory.h>
#import <libxml/parser.h>
#import <libxml/tree.h>


@implementation AppObjectConvertor

+(NSMutableArray*)getObjectListForObjectType:(ObjectType)type
{
	return [Poi getObjectsForType:type];
}

@end

@implementation Poi

@synthesize imageURL, iD, address, latitude, longitude, name, phone, fax, distance, type;

- (id)init
{
	if((self = [super init])) {
		self.imageURL    = nil;
		self.iD          = nil;
		self.address     = nil;		
		self.latitude    = 0.0;
		self.longitude   = 0.0;
		self.name        = nil;		
		self.phone       = nil;
		self.fax         = nil;
		self.distance    = 0.0;
		self.type        = NONE;
	}	
	return self;
}

- (NSComparisonResult)comparePoiNames:(Poi *)poi
{
	return [self.name compare:poi.name options:NSNumericSearch];	
}

- (NSComparisonResult)comparePoiDistances:(Poi *)poi
{
	if(self.distance < poi.distance)
		return NSOrderedAscending;
	else if(self.distance > poi.distance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

+(NSMutableArray *)getObjectsForType:(ObjectType)objType
{
	static NSString *fileName = nil;
	switch (objType)
	{
		case POIBANK:
			fileName = @"bank";
			break;
		case POIHOTEL:
			fileName = @"hotel";
			break;
		case POIHEALTH:
			fileName = @"health";
			break;
		case POIEDUCATION:
			fileName = @"education";
			break;
        case POI:
        case NONE:
            fileName = nil;
			break;
	}
	NSMutableArray *objectList = [NSMutableArray new];
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
	NSData *xmlData = [NSData dataWithContentsOfFile:path];
	
    NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
	
    xmlDocPtr doc = xmlParseMemory([xml UTF8String], [xml lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    xmlNodePtr node = xmlDocGetRootElement(doc);
	
    xmlNodePtr cur_node = node->children;
	
    for(cur_node = node->children; cur_node; cur_node = cur_node->next) {
        if(strcmp((char *)cur_node->name, "result") == 0) {
			Poi *poi = [Poi new];
            xmlNodePtr poi_cur_node;
            
            for(poi_cur_node = cur_node->children; poi_cur_node; poi_cur_node = poi_cur_node->next) {
                if(strcmp("result", (char *)poi_cur_node->name)) 
				{
                    xmlChar *poi_element_value = xmlNodeListGetString(doc, poi_cur_node->children, 1);
					
                    if(!strcmp((char *)poi_cur_node->name, "name")) {                       
                        poi.name = [NSString stringWithUTF8String:(char *)poi_element_value];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "address")) {                       
                        poi.address = [NSString stringWithUTF8String:(char *)poi_element_value];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "icon")) {                       
                        poi.imageURL = [NSString stringWithUTF8String:(char *)poi_element_value];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "lat")) {                       
                        poi.latitude = [[NSString stringWithUTF8String:(char *)poi_element_value] doubleValue];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "lng")) {                       
                        poi.longitude = [[NSString stringWithUTF8String:(char *)poi_element_value] doubleValue];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "distance")) {                       
                        poi.distance = [[NSString stringWithUTF8String:(char *)poi_element_value] doubleValue];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "phone")) {                       
                        poi.phone = [NSString stringWithUTF8String:(char *)poi_element_value];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "id")) {                       
                        poi.iD = [NSString stringWithUTF8String:(char *)poi_element_value];
                    }
					else if(!strcmp((char *)poi_cur_node->name, "type")) {                       
                        poi.type = objType;
                    }
                }
            }
            
            [objectList addObject:poi];
            [poi release];
        } else {
            NSLog(@"Else %s", cur_node->name);
        }
    }
	
    xmlFreeDoc(doc);
    xmlCleanupParser();
	[objectList sortUsingSelector:@selector(comparePoiDistances:)];
	return objectList;
}

- (void)dealloc
{
	[imageURL release];
	[iD release];
	[name release];
	[address release];	
	[phone release];
	[fax release];
	[super dealloc];
}
@end

@implementation PoiImage

@synthesize imgURL, imgData;

- (id)init
{
	if((self = [super init])) {
		self.imgURL    = nil;
		self.imgData   = nil;
	}	
	return self;
}

- (void)dealloc
{
	[imgURL release];
	[imgData release];	
	[super dealloc];
}

@end