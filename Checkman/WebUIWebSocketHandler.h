#import "WebUIHandler.h"

@class WebUIWebSocketHandler, WebSocketConnection;

@protocol WebUIWebSocketHandlerDelegate <NSObject>
- (void)WebUIWebSocketHandler:(WebUIWebSocketHandler *)handler
    WebSocketConnectionDidStart:(WebSocketConnection *)connection;
- (void)WebUIWebSocketHandler:(WebUIWebSocketHandler *)handler
    WebSocketConnectionDidEnd:(WebSocketConnection *)connection;
@end

@interface WebUIWebSocketHandler : WebUIHandler
@property (nonatomic, assign) id<WebUIWebSocketHandlerDelegate> delegate;
- (void)sendMessage:(NSString *)string;
@end
