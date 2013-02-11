#import "TCPServer.h"

@class HTTPServer, HTTPConnection, HTTPRequest;

@protocol HTTPServerDelegate <NSObject>
- (void)HTTPServer:(HTTPServer *)server
    HTTPConnection:(HTTPConnection *)connection
    didReceiveHTTPRequest:(HTTPRequest *)request;
@end

@interface HTTPServer : TCPServer
@property (nonatomic, assign) id<HTTPServerDelegate> requestDelegate;

+ (HTTPServer *)onPort:(uint16_t)port;

- (id)initWithTCPServer:(TCPServer *)tcpServer;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (void)hijackConnection:(HTTPConnection *)connection;
@end
