#import "WebUIWebSocketHandler.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "HTTPRequest.h"
#import "WebSocketConnection.h"
#import "WebSocketSec.h"
#import "TCPConnection.h"

@interface WebUIWebSocketHandler () <WebSocketConnectionDelegate>
@property (nonatomic, retain) WebSocketConnection *webSocketConnection;
@end

@implementation WebUIWebSocketHandler
@synthesize
    delegate = _delegate,
    webSocketConnection = _webSocketConnection;

- (void)dealloc {
    self.delegate = nil;
}

- (void)handle {
    [self _hijackConnection];
    [self _handleFirstRequest];
}

- (void)sendMessage:(NSString *)string {
    NSAssert(self.webSocketConnection, @"WebSocket connection must not be nil");
    [self.webSocketConnection sendMessage:string];
}

#pragma mark -

- (void)_hijackConnection {
    [self.server hijackConnection:self.connection];
}

- (void)_handleFirstRequest {
    [self _handleUnsupportedVersion]
    || [self _handleUnsupportedRequest]
    || [self _handleNonGetRequest]
    || [self _handleNonWebSocket]
    || [self _respondWithUpgrade];
}

#pragma mark - First (connection upgrade) response

- (BOOL)_handleNonWebSocket {
    NSString *connectionHeader = [self.request requestNamedHeaderValue:@"Connection"];
    NSString *upgradeHeader = [self.request requestNamedHeaderValue:@"Upgrade"];
    if (![connectionHeader isEqual:@"Upgrade"] || ![upgradeHeader isEqual:@"websocket"]) {
        return [self _respondWithStatus:400];
    }
    return NO;
}

- (BOOL)_respondWithUpgrade {
    self.request.responseStatus = 101;
    [self.request setResponseHeader:@"Upgrade" value:@"websocket"];
    [self.request setResponseHeader:@"Connection" value:@"Upgrade"];

    NSString *secKey = [self.request requestNamedHeaderValue:@"Sec-WebSocket-Key"];
    NSString *secAccept = [WebSocketSec secAcceptWithSecKey:secKey];
    [self.request setResponseHeader:@"Sec-WebSocket-Accept" value:secAccept];

    [self.request respond];
    [self _switchToWebSocketProtocol];
    return YES;
}

- (void)_switchToWebSocketProtocol {
    NSAssert(self.connection.isFlushed, @"HTTP connection must be flushed");

    self.webSocketConnection =
        [[WebSocketConnection alloc]
            initWithTCPConnection:self.connection.tcpConnection];
    self.webSocketConnection.ownerDelegate = self;

    [self.delegate
        WebUIWebSocketHandler:self
        WebSocketConnectionDidStart:self.webSocketConnection];
}

- (void)WebSocketConnectionDidClose:(WebSocketConnection *)connection {
    [self.delegate
        WebUIWebSocketHandler:self
        WebSocketConnectionDidEnd:self.webSocketConnection];
}
@end
