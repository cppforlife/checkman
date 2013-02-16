#import <Foundation/Foundation.h>

@class TCPConnection, WebSocketConnection, WebSocketFrame;

@protocol WebSocketConnectionDelegate <NSObject>
- (void)WebSocketConnectionDidClose:(WebSocketConnection *)connection;
@end

@protocol WebSocketConnectionDataDelegate <NSObject>
- (void)WebSocketConnection:(WebSocketConnection *)connection
    didReceiveFrame:(WebSocketFrame *)frame;
@end

@interface WebSocketConnection : NSObject
@property (nonatomic, assign) id<WebSocketConnectionDelegate> ownerDelegate;
@property (nonatomic, assign) id<WebSocketConnectionDelegate> connectionDelegate;
@property (nonatomic, assign) id<WebSocketConnectionDataDelegate> dataDelegate;

- (id)initWithTCPConnection:(TCPConnection *)connection;
- (TCPConnection *)tcpConnection;

- (void)close;

- (void)sendMessage:(NSString *)message;
@end
