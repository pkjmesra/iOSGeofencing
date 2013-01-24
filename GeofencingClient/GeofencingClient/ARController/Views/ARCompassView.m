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
//  ARCompassView.m
//  POISearch
//
//  Created by Rajesh Dongre on 08/06/11.
//  Copyright 2011 Research2Development, Nagpur. All rights reserved.
//

#import "ARCompassView.h"
#import "Defines.h"

@implementation ARCompassView

#pragma -
#pragma Instance methods.
- (void)setPointArray:(NSArray *)array
{
    if(pointArray != nil)
    {
        [pointArray release];
        pointArray = nil;
    }
    pointArray = [[NSArray alloc] initWithArray:array];    
}

#pragma -
#pragma Private methods.
- (void)drawPoints:(CGContextRef)context
{
    if(pointArray != nil)
    {
        NSEnumerator *enumerator = [pointArray objectEnumerator];
        NSValue *value = nil;
        while ((value = [enumerator nextObject]) != nil)
        {
            CGPoint point = [value CGPointValue];
            CGRect rect = CGRectMake(point.x, point.y, 2.0, 2.0);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);            
            CGContextFillEllipseInRect(context, rect);
        }
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect outerRect = CGRectMake(rect.origin.x+1.0, rect.origin.y+1.0, rect.size.width-2.0, rect.size.height-2.0);
	CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	CGContextFillEllipseInRect(context, outerRect);	
	CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	CGRect innerRect = CGRectMake(rect.origin.x+(rect.size.width/6), rect.origin.y+(rect.size.height/6), rect.size.width*2/3, rect.size.height*2/3);
	CGContextFillEllipseInRect(context, innerRect);	
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextStrokeEllipseInRect(context, outerRect); 	
	
   	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGPoint center = CGPointMake(CGRectGetMidX(outerRect), CGRectGetMidY(outerRect));
	CGFloat radius = outerRect.size.height/2-1.0;
	//CGFloat angle = 0.5f;
//    CGFloat x = center.x + (radius*cosf(degreesToRadians(3*M_PI_2-0.25)));
//    CGFloat y = center.y + (radius*sinf(degreesToRadians(3*M_PI_2-0.25)));
//    CGPoint startPoint = CGPointMake(x, y);
//    
//    x = center.x + (radius*cosf(degreesToRadians(3*M_PI_2+0.25)));
//    y = center.y + (radius*sinf(degreesToRadians(3*M_PI_2+0.25)));
//    CGPoint endPoint = CGPointMake(x, y);
//	
//    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
//    CGContextAddLineToPoint(context, center.x, center.y);
//    CGContextMoveToPoint(context, center.x, center.y);
//    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
//    CGContextMoveToPoint(context, endPoint.x, endPoint.y);
//    CGContextAddArc(context, center.x, center.y, radius, 3*M_PI_2-0.25, 3*M_PI_2-0.25, true);	
//    
//	CGContextFillPath(context);
    
    
//    CGContextBeginPath(context);
//    CGContextSetLineWidth(context, 1.0f);
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, 3*M_PI_2-0.25, 3*M_PI_2+0.25, false);
    CGContextDrawPath(context, kCGPathFill);
    
    [self drawPoints:context];

}

- (void)dealloc {
    if(pointArray != nil)
        [pointArray release];
    [super dealloc];
}


@end
