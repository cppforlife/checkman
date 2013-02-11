#import "HTTPRequest.h"

@interface HTTPRequest ()
@property (nonatomic, assign, getter = hasResponded) BOOL responded;
@end

@implementation HTTPRequest
@synthesize
    delegate = _delegate,
    request = _request,
    response = _response,
    responded = _responded;

- (id)initWithRequest:(CFHTTPMessageRef)request {
    if (self = [super init]) {
        self.request = request;
    }
    return self;
}

- (void)dealloc {
    if (self.request) CFRelease(self.request);
    if (self.response) CFRelease(self.response);
    self.delegate = nil;
}

#pragma mark - Request

- (void)setRequest:(CFHTTPMessageRef)request {
    NSAssert(request, @"Request must not be nil");
    NSAssert(!_request, @"Request already set");
    _request = (CFHTTPMessageRef)CFRetain(request);
}

- (NSString *)requestMethod {
    return CFBridgingRelease(CFHTTPMessageCopyRequestMethod(self.request));
}

- (NSString *)requestVersion {
    return CFBridgingRelease(CFHTTPMessageCopyVersion(self.request));
}

- (BOOL)isHTTP11 {
    NSString *version = self.requestVersion;
    return version && [version isEqual:(id)kCFHTTPVersion1_1];
}

- (NSURL *)requestURL {
    return CFBridgingRelease(CFHTTPMessageCopyRequestURL(self.request));
}

- (NSString *)requestNamedHeaderValue:(NSString *)name {
    return CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(self.request, (__bridge CFStringRef)name));
}

#pragma mark - Response

- (void)setResponseStatus:(CFIndex)status {
    self.response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, status, NULL, kCFHTTPVersion1_1);
    [self setResponseHeader:@"Content-Length" value:@"0"];
}

- (void)setResponse:(CFHTTPMessageRef)response {
    NSAssert(response, @"Response must not be nil");
    NSAssert(!_response, @"Response already set");
    _response = (CFHTTPMessageRef)CFRetain(response);
}

- (void)setResponseHeader:(NSString *)name value:(NSString *)value {
    NSAssert(self.response, @"Response must not be nil");
    CFHTTPMessageSetHeaderFieldValue(self.response,
        (__bridge CFStringRef)name, (__bridge CFStringRef)value);
}

- (void)setResponseBody:(NSData *)data {
    NSAssert(self.response, @"Response must not be nil");
    CFHTTPMessageSetBody(self.response, (__bridge CFDataRef)data);
    [self setResponseHeader:@"Content-Length"
          value:[NSString stringWithFormat:@"%ld", data.length]];
}

- (void)respond {
    NSAssert(self.response, @"Response must not be nil");
    self.responded = YES;
    [self.delegate HTTPRequestDidRespond:self];
}

- (NSData *)responseAsData {
    if (self.response) {
        return CFBridgingRelease(CFHTTPMessageCopySerializedMessage(self.response));
    } else return nil;
}
@end

