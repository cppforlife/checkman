#import <Foundation/Foundation.h>

@class TCPConnection, HTTPConnection, HTTPRequest;

@protocol HTTPConnectionDelegate <NSObject>
- (void)HTTPConnection:(HTTPConnection *)connection
     didReceiveHTTPRequest:(HTTPRequest *)request;
@end

@interface HTTPConnection : NSObject
@property (nonatomic, assign) id<HTTPConnectionDelegate> delegate;

- (id)initWithTCPConnection:(TCPConnection *)connection;
- (TCPConnection *)tcpConnection;

// Indicates whether there are any pending HTTP responses.
// (Pending here means:
//   - not all requests were answered by a response
//   - not all responses were written to tcp conn.)
- (BOOL)isFlushed;
@end
