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
//  Helper.m
//  POISearch
//
//  Created by Rajesh Dongre on 23/05/11.
//  Copyright 2011 Praveen K Jha Nagpur. All rights reserved.
//

#import "Helper.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static UIAlertView  *alertView = nil;
@implementation Helper
+(NSString*) getCurrentDate
{
	NSDate* today = [NSDate date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd"];	
	NSString* formatedDateString = [formatter stringFromDate:today];
	
	[formatter release];
	
	return formatedDateString;
	
}

+(void)showAlert:(NSString *)title message:(NSString *)message okButton:(BOOL)value withDelegate:(id)delegate
{
	if(alertView != nil)
	{
		[alertView release];
		alertView = nil;		
	}	
	if(value)
		alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];	
	else
		alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:nil];	
	[alertView show];			
}

+ (void)showAlert:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle withDelegate:(id)delegate
{
	if(alertView != nil)
	{
		[alertView release];
		alertView = nil;		
	}	
	if(otherTitle != nil)
		alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];	
	else
		alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil];	
	[alertView show];			
}

+(void)dismissAlert
{
	if(alertView != nil/* && alertView.isVisible*/)
	{		
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
		NSLog(@"Alert dismissed.");
//		[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(dismissAlertHelper:) userInfo:nil repeats:NO];
	}
}

+(UIInterfaceOrientation)currentOrientation
{
	return [[UIApplication sharedApplication] statusBarOrientation];
}

+(NSString *)getStringByEscapingLineCharacter:(NSString *)string
{
	NSMutableString *escapedString = [[string mutableCopy] autorelease];	
	[escapedString replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [escapedString length])];		
	return escapedString;
}

+(NSString *)getStringByEscapingBreak:(NSString *)string
{
	NSMutableString *escapedString = [[string mutableCopy] autorelease];	
	[escapedString replaceOccurrencesOfString:@"<br> <br>" withString:@"\n" options:0 range:NSMakeRange(0, [escapedString length])];
	[escapedString replaceOccurrencesOfString:@":<br>" withString:@":" options:0 range:NSMakeRange(0, [escapedString length])];		[escapedString replaceOccurrencesOfString:@": <br>" withString:@":" options:0 range:NSMakeRange(0, [escapedString length])];
	[escapedString replaceOccurrencesOfString:@":<br> " withString:@":" options:0 range:NSMakeRange(0, [escapedString length])];	
	[escapedString replaceOccurrencesOfString:@"pm<br> " withString:@"pm | " options:0 range:NSMakeRange(0, [escapedString length])];
	[escapedString replaceOccurrencesOfString:@"am<br> " withString:@"am | " options:0 range:NSMakeRange(0, [escapedString length])];
	//Check for Number after " | " character or add "\n" character in place of " | ".
	NSRange range = [escapedString rangeOfString:@" | "];
	while (range.length >= 1 && (range.length + range.location) <= escapedString.length)
	{
		NSString *string = [escapedString substringWithRange:NSMakeRange(range.location + range.length, 1)];
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
		NSNumber *number = [formatter numberFromString:string];
		if(number == nil)
			[escapedString replaceOccurrencesOfString:@" | " withString:@"\n" options:0 range:range];
		[formatter release];
		range = NSMakeRange(range.location+range.length, escapedString.length-(range.location+range.length));
		range = [escapedString rangeOfString:@" | " options:0 range:range];
	}	
	[escapedString replaceOccurrencesOfString:@"<br>" withString:@"\n" options:0 range:NSMakeRange(0, [escapedString length])];	
	return escapedString;
}

+ (NSString *)getNIBName:(NIBFileNameType)type
{
	switch (type) {				
		case ROOT_VIEW:
			return ROOTVIEW_NIB;
		case PLACE_DETAIL_VIEW:
			return PLACE_DETAIL_VIEW_NIB;
	}
	return nil;
}

+ (UIImage *)thumbWithSideOfLength:(float)length withImageData:(NSData *)imageData
{
	float sideFull= 0.0f;
	UIImage *thumbnail = nil;
	
	UIImage *mainImage = [UIImage imageWithData:imageData];		
	
	UIImageView *mainImageView = [[UIImageView alloc] initWithImage:mainImage];
	
	BOOL widthGreaterThanHeight = (mainImage.size.width > mainImage.size.height);
	
	if(widthGreaterThanHeight)
	{
		sideFull = mainImage.size.width;
	}
	else
	{
		sideFull = mainImage.size.height;
	}	
	
	CGRect clippedRect = CGRectMake(0, 0, sideFull, sideFull);
	if(sideFull < length)
		clippedRect = CGRectMake(0, 0, length, length);
	
	//creating a square context the size of the final image which we will then
	// manipulate and transform before drawing in the original image
	UIGraphicsBeginImageContext(CGSizeMake(length, length));
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextClipToRect( currentContext, clippedRect);
	
	//CGFloat scaleFactor = length/sideFull;
	
	CGFloat widthScaleFactor = length/mainImage.size.width;
	CGFloat heightScaleFactor = length/mainImage.size.height;
	
	if (widthGreaterThanHeight)
	{
		//a landscape image – make context shift the original image to the left when drawn into the context
		CGContextTranslateCTM (currentContext, 0, 0);		
	}
	else
	{
		//a portfolio image – make context shift the original image upwards when drawn into the context
		CGContextTranslateCTM(currentContext, 0, 0);		
	}
	//this will automatically scale any CGImage down/up to the required thumbnail side (length) when the CGImage gets drawn into the context on the next line of code
	CGContextScaleCTM(currentContext, widthScaleFactor, heightScaleFactor);
	
	[mainImageView.layer renderInContext:currentContext];
	
	thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	NSData *imgData = UIImagePNGRepresentation(thumbnail);	
	
	thumbnail = [UIImage imageWithData:imgData];
	NSLog(@"thumbnail %f, %f",thumbnail.size.width, thumbnail.size.height);
	[mainImageView release];
	
	return thumbnail;
}

+ (UIImage *)thumbWithWidth:(float)width withHeight:(float)height withImageData:(NSData *)imageData
{	
	UIImage *thumbnail = nil;
	
	UIImage *mainImage = [UIImage imageWithData:imageData];		
	
	UIImageView *mainImageView = [[UIImageView alloc] initWithImage:mainImage];
	
	BOOL widthGreaterThanHeight = (mainImage.size.width > mainImage.size.height);	
	
	CGRect clippedRect = CGRectMake(0, 0, width, height);
	
	//creating a square context the size of the final image which we will then
	// manipulate and transform before drawing in the original image
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextClipToRect( currentContext, clippedRect);	
	CGFloat widthScaleFactor = width/mainImage.size.width;
	CGFloat heightScaleFactor = height/mainImage.size.height;
	
	if (widthGreaterThanHeight)
	{
		//a landscape image – make context shift the original image to the left when drawn into the context
		CGContextTranslateCTM (currentContext, 0, 0);		
	}
	else
	{
		//a portfolio image – make context shift the original image upwards when drawn into the context
		CGContextTranslateCTM(currentContext, 0, 0);		
	}
	//this will automatically scale any CGImage down/up to the required thumbnail side (length) when the CGImage gets drawn into the context on the next line of code
	CGContextScaleCTM(currentContext, widthScaleFactor, heightScaleFactor);
	
	[mainImageView.layer renderInContext:currentContext];
	
	thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	NSData *imgData = UIImagePNGRepresentation(thumbnail);	
	
	thumbnail = [UIImage imageWithData:imgData];
	NSLog(@"thumbnail %f, %f",thumbnail.size.width, thumbnail.size.height);
	[mainImageView release];
	
	return thumbnail;
}

+ (BOOL)is3GSAndAboveDevice
{
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding: NSUTF8StringEncoding];
	free(machine);
	
	if([platform isEqualToString:@"iPhone1,1"]) return NO;
	else if([platform isEqualToString:@"iPhone1,2"]) return NO;
	else if([platform isEqualToString:@"iPod1,1"]) return NO;
	else if([platform isEqualToString:@"iPod2,1"]) return NO;
	else if([platform isEqualToString:@"iPad1,1"]) return NO;
	else return YES;

}

+ (NSString *)getTrimmedString:(NSString *)string
{
	NSArray *charArray = [NSArray arrayWithObjects:@" ", @"(", @")", @"%", @"  ", nil];
	NSMutableString* newStr = [NSMutableString stringWithString:string];
	for(NSString *str in charArray)
	{
		NSRange fullRange = NSMakeRange(0, [newStr length]);
		[newStr replaceOccurrencesOfString:str withString:@"" options:0 range:fullRange];
	}
	return newStr;
}

+(NSString *)getPlainTextFromRichText:(NSString *)richText
{
	
	NSMutableString *richtxt = [NSMutableString stringWithString:richText];
	int len = [richtxt length];
	int currIndex = 0;
	NSRange tagsPresent = [richtxt rangeOfString:@"<"];
	NSRange tagStart = [richtxt rangeOfString:@"<"];
	NSRange tagEnd = [richtxt rangeOfString:@">"];

	while(tagStart.length>=1 && tagEnd.length>=1 )
	{		
		NSRange tagLength;
		tagLength.length = tagEnd.location - tagStart.location +1;
		tagLength.location = tagStart.location;
		NSLog(@"%@",richtxt);
		[richtxt replaceCharactersInRange:tagLength withString:@" "];
		len = [richtxt length];
		NSLog(@"%@",richtxt);
		currIndex = tagEnd.location;
		tagsPresent = [richtxt rangeOfString:@"<"];
		tagStart = [richtxt rangeOfString:@"<"];
		tagEnd = [richtxt rangeOfString:@">"];		
	}
		
	return [richtxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
