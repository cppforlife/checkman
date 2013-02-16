#import <Foundation/Foundation.h>

@class HTTPRequest;

@protocol HTTPRequestDelegate <NSObject>
- (void)HTTPRequestDidRespond:(HTTPRequest *)request;
@end

@interface HTTPRequest : NSObject

@property (nonatomic, assign) id<HTTPRequestDelegate> delegate;
@property (nonatomic, assign) CFHTTPMessageRef request;
@property (nonatomic, assign) CFHTTPMessageRef response;

- (id)initWithRequest:(CFHTTPMessageRef)request;

#pragma mark - Request

- (NSString *)requestMethod;

- (NSString *)requestVersion;
- (BOOL)isHTTP11;

- (NSURL *)requestURL;
- (NSString *)requestNamedHeaderValue:(NSString *)name;

#pragma mark - Response

// Also sets HTTP 1.1 and Content-Length: 0
- (void)setResponseStatus:(CFIndex)status;

- (void)setResponseHeader:(NSString *)name value:(NSString *)value;
- (NSString *)responseNamedHeaderValue:(NSString *)name;
- (BOOL)isResponseConnectionUpgrade;

// Automatically sets Content-Length: to data's length
- (void)setResponseBody:(NSData *)data;

- (void)respond;
- (BOOL)hasResponded;
- (NSData *)responseAsData;
@end
