#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "TCPServer.h"
#import "TCPConnection.h"

@interface HTTPServer ()
    <TCPServerDelegate, HTTPConnectionDelegate, HTTPConnectionDataDelegate>
@property (nonatomic, retain) TCPServer *tcpServer;
@property (nonatomic, retain) NSMutableArray *connections;
@end

@implementation HTTPServer
@synthesize
    requestDelegate = _requestDelegate,
    tcpServer = _tcpServer,
    connections = _connections;

+ (HTTPServer *)onPort:(uint16_t)port {
    TCPServer *tcpServer = [[TCPServer alloc] initWithPort:port];
    HTTPServer *httpServer = [[HTTPServer alloc] initWithTCPServer:tcpServer];
    return httpServer;
}

- (id)initWithTCPServer:(TCPServer *)tcpServer {
    if (self = [super init]) {
        self.tcpServer = tcpServer;
        self.tcpServer.delegate = self;
        self.connections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.requestDelegate = nil;
}

- (BOOL)start:(NSError **)error {
    return [self.tcpServer start:error];
}

- (BOOL)stop {
    // clonse connections??
    return [self.tcpServer stop];
}

#pragma mark - Connection management

- (void)TCPServer:(TCPServer *)server
    TCPConnectionDidStart:(TCPConnection *)connection {

    HTTPConnection *httpConnection =
        [[HTTPConnection alloc] initWithTCPConnection:connection];

    [self.connections addObject:httpConnection];
    httpConnection.ownerDelegate = self;
    httpConnection.dataDelegate = self;
}

- (void)HTTPConnectionDidClose:(HTTPConnection *)connection {
    connection.ownerDelegate = nil;
    connection.dataDelegate = nil;
    [self.connections removeObjectIdenticalTo:connection];
}

- (void)hijackConnection:(HTTPConnection *)connection {
    connection.ownerDelegate = nil;
    connection.dataDelegate = nil;
    [self.connections removeObjectIdenticalTo:connection];
    [self.tcpServer hijackConnection:connection.tcpConnection];
}

#pragma mark - HTTPConnectionDataDelegate

- (void)HTTPConnection:(HTTPConnection *)connection
        didReceiveHTTPRequest:(HTTPRequest *)request {
    [self.requestDelegate
        HTTPServer:self
        HTTPConnection:connection
        didReceiveHTTPRequest:request];
}
@end
