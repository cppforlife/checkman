#import "WebUIHandler.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "HTTPRequest.h"

@interface WebUIHandler ()
@property (nonatomic, retain) HTTPServer *server;
@property (nonatomic, retain) HTTPConnection *connection;
@property (nonatomic, retain) HTTPRequest *request;
@end

@implementation WebUIHandler
@synthesize
    server = _server,
    connection = _connection,
    request = _request;

- (id)initWithHTTPServer:(HTTPServer *)server
          HTTPConnection:(HTTPConnection *)connection
             HTTPRequest:(HTTPRequest *)request {
    if (self = [super init]) {
        self.server = server;
        self.connection = connection;
        self.request = request;
    }
    return self;
}

- (void)handle {
    NSAssert(NO, @"Override in subclass");
}
@end

@implementation WebUIHandler (Helpers)

- (BOOL)_handleUnsupportedVersion {
    if (!self.request.isHTTP11) {
        return [self _respondWithStatus:505];
    }
    return NO;
}

- (BOOL)_handleUnsupportedRequest {
    if (!self.request.requestMethod) {
        return [self _respondWithStatus:400];
    }
    return NO;
}

- (BOOL)_handleNonGetRequest {
    if (![self.request.requestMethod isEqual:@"GET"]) {
        return [self _respondWithStatus:405];
    }
    return NO;
}

- (BOOL)_respondWithStatus:(CFIndex)status {
    self.request.responseStatus = status;
    [self.request respond];
    return YES;
}
@end
