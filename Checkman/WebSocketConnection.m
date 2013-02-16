#import "WebSocketConnection.h"
#import "TCPConnection.h"
#import "TCPBufferedStreams.h"
#import "WebSocketFrame.h"

@interface WebSocketConnection ()
    <TCPConnectionDelegate, TCPConnectionDataDelegate>
@property (nonatomic, retain) TCPConnection *tcpConnection;
@end

@implementation WebSocketConnection
@synthesize
    ownerDelegate = _ownerDelegate,
    connectionDelegate = _connectionDelegate,
    dataDelegate = _dataDelegate,
    tcpConnection = _tcpConnection;

- (id)initWithTCPConnection:(TCPConnection *)tcpConnection {
    if (self = [super init]) {
        self.tcpConnection = tcpConnection;
        self.tcpConnection.dataDelegate = self;
    }
    return self;
}

- (void)dealloc {
    self.ownerDelegate = nil;
    self.connectionDelegate = nil;
    self.dataDelegate = nil;
}

#pragma mark - Closing connection

- (void)close {
    [self.tcpConnection close];
}

- (void)TCPConnectionDidClose:(TCPConnection *)connection {
    [self.connectionDelegate WebSocketConnectionDidClose:self];
    [self.ownerDelegate WebSocketConnectionDidClose:self];
}

#pragma mark -

- (void)sendMessage:(NSString *)message {
    WebSocketFrame *frame = [[WebSocketFrame alloc] init];
    frame.data = message;
    [self.tcpConnection.ostream writeData:frame.asWireData];
}

#pragma mark - TCPConnectionDataDelegate

- (void)TCPConnectionProcessIncomingBytes:(TCPConnection *)connection {
    // Not implemented
}

- (void)TCPConnectionProcessOutgoingBytes:(TCPConnection *)connection {}
@end
