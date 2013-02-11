#import <Foundation/Foundation.h>

@interface WebSocketFrame : NSObject
@property (nonatomic, retain) id data;

- (NSData *)asWireData;
@end
