#import <Foundation/Foundation.h>

@class TCPConnection, WebSocketConnection, WebSocketMessage;

@interface WebSocketConnection : NSObject

- (id)initWithTCPConnection:(TCPConnection *)connection;
- (TCPConnection *)tcpConnection;

- (void)sendMessage:(NSString *)message;
@end
