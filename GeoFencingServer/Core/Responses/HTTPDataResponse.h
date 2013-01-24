#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface HTTPDataResponse : NSObject <HTTPResponse>
{
	NSUInteger offset;
	NSData *data;
    NSInteger status;
}

- (id)initWithData:(NSData *)data;

@end
