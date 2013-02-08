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
//  Defines.h
//  POISearch
//
//  Created by Rajesh Dongre on 23/05/11.
//  Copyright 2011 Praveen K Jha Nagpur. All rights reserved.
//

#define degreesToRadians(x) (M_PI * x / 180.0)
#define RAFFELS_MEDICAL_APP 1
#define HW_MEDICAL 1
#ifndef __IPHONE_3_2 // if iPhoneOS is 3.2 or greater then __IPHONE_3_2 will be defined
typedef enum {
	UIUserInterfaceIdiomPhone, // iPhone and iPod touch style UI
	UIUserInterfaceIdiomPad, // iPad style UI
} UIUserInterfaceIdiom;
#define UI_USER_INTERFACE_IDIOM() (([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) ? UIUserInterfaceIdiomPad : UIUserInterfaceIdiomPhone)
#endif // ifndef __IPHONE_3_2 

#define IPAD_OS               NO //(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define NEARBY_ALERT_TITLE        @"Processing"
#define NEARBY_ALERT_MSG          @"Please wait..."
#define KM_STR                    @"%d km "
#define MTR_STR                   @"%d m"
#define KM_STRING                 @"%d KiloMeters "
#define MTR_STRING                @"%d Meters"
#define NEARBY_AR_NOTIFICATION    @"NEARBY_AR_NOTIFICATION"
#define IPHONE3GSABOVE_ALERT_MSG  @"This feature is only abvailable on iPhone 3GS and above."

//////////////////////-APPLICATION SPECIFIC STRING MACROS-//////////////////////

//////////////////////-APPLICATION SPECIFIC NUMBER MACROS-//////////////////////

#define YEAR_TO_SECS_FACTOR             31556952.0f  //ref. http://en.wikipedia.org/wiki/Year
#define AR_VIEW_WIDTH                   200.0f
#define AR_VIEW_HEIGHT                  60.0f
#define AR_TITLE_FONT                   [UIFont fontWithName:@"Helvetica" size:16.0f]
#define AR_SUBTITLE_FONT                [UIFont fontWithName:@"Helvetica" size:13.0f]
#define AR_TEXT_XOFFSET                 20.0f
#define AR_TEXT_YOFFSET                 1.0f
#define AR_TITLE_TEXT_HEIGHT            18.0f
#define AR_SUBTITLE_TEXT_HEIGHT         14.0f
#define HELVETICA_PLAIN_18              [UIFont fontWithName:@"Helvetica" size:18.0f]
#define HELVETICA_BOLD_18               [UIFont fontWithName:@"Helvetica-Bold" size:18.0f]
#define HELVETICA_BOLD_13               [UIFont fontWithName:@"Helvetica-Bold" size:13.0f]
#define HELVETICA_PLAIN_13              [UIFont fontWithName:@"Helvetica" size:13.0f]
#define HELVETICA_PLAIN_11              [UIFont fontWithName:@"Helvetica" size:11.0f]
#define ARIAL_PLAIN_15                  [UIFont fontWithName:@"Arial" size:15.0f]

#define AR_DEFAULT_DIST                 2000.0f
//////////////////////-APPLICATION SPECIFIC NUMBER MACROS-//////////////////////

//////////////////////-APPLICATION SPECIFIC IMAGE MACROS-//////////////////////
#define IMG_HOME_BUTTON                 @"homebutton.png"       
#define CALL_OUT_IMAGE_NAME             @"CallOut"
//////////////////////-APPLICATION SPECIFIC IMAGE MACROS-//////////////////////

#define ROOTVIEW_NIB                      (IPAD_OS ?@"RootViewController-iPad"                 : @"RootViewController")
#define PLACE_DETAIL_VIEW_NIB             @"PlaceDetailController"
//////////////////////-APPLICATION NIB FILE NAMES-//////////////////////

//Enum values for NIB files to be selected.
typedef enum {	
	ROOT_VIEW,	
	PLACE_DETAIL_VIEW,
}NIBFileNameType;



//Enum values for Home Page icons.
typedef enum 
{
	POIBANK_INDEX = 1,
	POIEDUCATION_INDEX,
	POIHEALTH_INDEX,	
	POIHOTEL_INDEX,	
}HomePageIconIndex;

//Enum values for Object types.
typedef enum
{
	POI,
	POIBANK,
	POIHOTEL,
	POIHEALTH,
	POIEDUCATION,
	NONE,
}ObjectType;
