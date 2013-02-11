#import "WebUIHandler.h"

@class WebUIWebSocketHandler;

@protocol WebUIWebSocketHandlerDelegate <NSObject>
- (void)WebUIWebSocketHandlerDidAcceptNewConnection:(WebUIWebSocketHandler *)handler;
@end

@interface WebUIWebSocketHandler : WebUIHandler
@property (nonatomic, assign) id<WebUIWebSocketHandlerDelegate> delegate;
- (void)sendMessage:(NSString *)string;
@end
