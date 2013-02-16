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
    if (_request) CFRelease(_request);
    if (_response) CFRelease(_response);
    self.delegate = nil;
}

#pragma mark - Request

- (void)setRequest:(CFHTTPMessageRef)request {
    NSAssert(request, @"Request must not be nil");
    NSAssert(!_request, @"Request already set");
    _request = (CFHTTPMessageRef)CFRetain(request);
}

- (NSString *)requestMethod {
    NSAssert(self.request, @"Request must not be nil");
    return CFBridgingRelease(CFHTTPMessageCopyRequestMethod(self.request));
}

- (NSString *)requestVersion {
    NSAssert(self.request, @"Request must not be nil");
    return CFBridgingRelease(CFHTTPMessageCopyVersion(self.request));
}

- (BOOL)isHTTP11 {
    NSString *version = self.requestVersion;
    return version && [version isEqual:(id)kCFHTTPVersion1_1];
}

- (NSURL *)requestURL {
    NSAssert(self.request, @"Request must not be nil");
    return CFBridgingRelease(CFHTTPMessageCopyRequestURL(self.request));
}

- (NSString *)requestNamedHeaderValue:(NSString *)name {
    NSAssert(self.request, @"Request must not be nil");
    return CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(self.request, (__bridge CFStringRef)name));
}

#pragma mark - Response

- (void)setResponseStatus:(CFIndex)status {
    CFHTTPMessageRef response =
        CFHTTPMessageCreateResponse(kCFAllocatorDefault, status, NULL, kCFHTTPVersion1_1);
    self.response = response;
    [self setResponseHeader:@"Content-Length" value:@"0"];
    CFRelease(response);
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

- (NSString *)responseNamedHeaderValue:(NSString *)name {
    NSAssert(self.response, @"Response must not be nil");
    return CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(self.response, (__bridge CFStringRef)name));
}

- (BOOL)isResponseConnectionUpgrade {
    return [[self responseNamedHeaderValue:@"Connection"] isEqual:@"Upgrade"];
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

