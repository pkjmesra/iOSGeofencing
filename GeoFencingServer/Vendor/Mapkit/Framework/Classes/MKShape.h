//
//  MKShape.h
//  MapKit
//
//  Created by Rick Fillion on 7/12/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MKAnnotation.h>

@interface MKShape : NSObject <MKAnnotation> {
    @package
    NSString *title;
    NSString *subtitle;
    NSString *UDID;
}

@property (copy) NSString *title;
@property (copy) NSString *subtitle;
@property (copy) NSString *UDID;
@end
