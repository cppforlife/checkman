#import <Foundation/Foundation.h>

@class HTTPServer, HTTPConnection, HTTPRequest;

@interface WebUIHandler : NSObject
- (id)initWithHTTPServer:(HTTPServer *)server
          HTTPConnection:(HTTPConnection *)connection
             HTTPRequest:(HTTPRequest *)request;

- (HTTPServer *)server;
- (HTTPConnection *)connection;
- (HTTPRequest *)request;

// Override in subclass
- (void)handle;
@end

@interface WebUIHandler (Helpers)
- (BOOL)_handleUnsupportedVersion;
- (BOOL)_handleUnsupportedRequest;
- (BOOL)_handleNonGetRequest;
- (BOOL)_respondWithStatus:(CFIndex)status;
@end
