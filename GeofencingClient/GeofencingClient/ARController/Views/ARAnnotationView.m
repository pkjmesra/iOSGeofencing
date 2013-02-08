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
//  ARAnnotationView.m
//  POISearch
//
//  Created by Rajesh Dongre on 23/05/11.
//  Copyright 2011 Praveen K Jha Nagpur. All rights reserved.
//

#import "ARAnnotationView.h"
#import "Defines.h"

@implementation ARAnnotationView
@synthesize title, subTitle, distTitle, objectID;

static UIImage *viewImage = nil;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.title = nil;
		self.subTitle = nil;
		self.distTitle = nil;
		self.objectID = nil;
		if(viewImage == nil)
		{
			NSString *fileBundlePath = [[NSBundle mainBundle] pathForResource:CALL_OUT_IMAGE_NAME ofType:@"png"];
			viewImage = [[UIImage alloc] initWithContentsOfFile:fileBundlePath];
		}		
    }
    return self;
}

- (void)setTarget:(id)target action:(SEL)action
{
	viewTarget = target;
	viewAction = action;
}

- (void)drawRect:(CGRect)rect
{
	CGRect rrect = self.bounds;
	
	if(viewImage != nil)
		[viewImage drawInRect:rrect];
	CGRect textRect = CGRectZero;
	if(self.title != nil)
	{
		textRect = CGRectMake(rrect.origin.x + AR_TEXT_XOFFSET - 2.0f, rrect.origin.y, rrect.size.width - AR_TEXT_XOFFSET, AR_TITLE_TEXT_HEIGHT);
		[self.title drawInRect:textRect withFont:AR_TITLE_FONT lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	}
	
	if(self.subTitle != nil)
	{		
		textRect = CGRectMake(textRect.origin.x, (textRect.origin.y + textRect.size.height + AR_TEXT_YOFFSET), textRect.size.width, AR_SUBTITLE_TEXT_HEIGHT);
		[self.subTitle drawInRect:textRect withFont:AR_SUBTITLE_FONT lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	}
	if(self.distTitle != nil)
	{
		textRect = CGRectMake(textRect.origin.x, (textRect.origin.y + textRect.size.height + AR_TEXT_YOFFSET), textRect.size.width, AR_SUBTITLE_TEXT_HEIGHT);
		[self.distTitle drawInRect:textRect withFont:AR_SUBTITLE_FONT lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(viewTarget != nil && viewAction != nil)
		[viewTarget performSelector:viewAction withObject:self.objectID];
	//NSLog(@"View selected");	
}

-(void) dealloc
{	
	[title release];
	[subTitle release];
	[distTitle release];
	[objectID release];
	[super dealloc];
}

@end
