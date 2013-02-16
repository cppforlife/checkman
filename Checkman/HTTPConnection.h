#import <Foundation/Foundation.h>

@class TCPConnection, HTTPConnection, HTTPRequest;

@protocol HTTPConnectionDelegate <NSObject>
- (void)HTTPConnectionDidClose:(HTTPConnection *)connection;
@end

@protocol HTTPConnectionDataDelegate <NSObject>
- (void)HTTPConnection:(HTTPConnection *)connection
    didReceiveHTTPRequest:(HTTPRequest *)request;
@end

@interface HTTPConnection : NSObject
@property (nonatomic, assign) id<HTTPConnectionDelegate> ownerDelegate;
@property (nonatomic, assign) id<HTTPConnectionDelegate> connectionDelegate;
@property (nonatomic, assign) id<HTTPConnectionDataDelegate> dataDelegate;

- (id)initWithTCPConnection:(TCPConnection *)connection;
- (TCPConnection *)tcpConnection;

- (void)close;

// Indicates whether there are any pending HTTP responses.
// (Pending here means:
//   - not all requests were answered by a response
//   - not all responses were written to tcp conn.)
- (BOOL)isFlushed;
@end
