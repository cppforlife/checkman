#import <Foundation/Foundation.h>

@interface WebSocketSec : NSObject
// Use to populate Sec-WebSocket-Accept header value
// (secKey is Sec-WebSocket-Key header value).
+ (NSString *)secAcceptWithSecKey:(NSString *)secKey;
@end
