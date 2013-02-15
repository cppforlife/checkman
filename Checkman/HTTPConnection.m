#import "HTTPConnection.h"
#import "TCPConnection.h"
#import "TCPBufferedStreams.h"
#import "HTTPRequest.h"

@interface HTTPConnection () <TCPConnectionDataDelegate, HTTPRequestDelegate>
@property (nonatomic, retain) TCPConnection *tcpConnection;
@property (nonatomic, retain) NSMutableArray *requests;
@end

@implementation HTTPConnection
@synthesize
    delegate = _delegate,
    tcpConnection = _tcpConnection,
    requests = _requests;

- (id)initWithTCPConnection:(TCPConnection *)tcpConnection {
    if (self = [super init]) {
        self.tcpConnection = tcpConnection;
        self.tcpConnection.dataDelegate = self;
        self.requests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark -

- (void)HTTPRequestDidRespond:(HTTPRequest *)request {
    NSLog(@"HTTPConnection - request did respond");
    [self _flushResponse];
}

- (void)_flushResponse {
    HTTPRequest *request = self.requests.lastObject;
    if (request.hasResponded) {
        [self.tcpConnection.ostream writeData:request.responseAsData];
        [self.requests removeLastObject];
    }
}

- (BOOL)isFlushed {
    return self.requests.count == 0;
}

#pragma mark -

- (void)TCPConnectionProcessIncomingBytes:(TCPConnection *)connection {
    TCPBufferedInputStream *istream = self.tcpConnection.istream;

    while (istream.bufferLength > 0) {
        CFHTTPMessageRef incomingMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        CFHTTPMessageAppendBytes(incomingMessage, istream.bufferBytes, (CFIndex)istream.bufferLength);
        NSLog(@"HTTPConnection - incoming: %d bytes (buffered)", (int)istream.bufferLength);

        if (CFHTTPMessageIsHeaderComplete(incomingMessage)) {
            NSString *expectedLengthValue =
                CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(
                    incomingMessage, (CFStringRef)@"Content-Length"));
            unsigned long expectedLength =
                expectedLengthValue ? (unsigned long)expectedLengthValue.intValue : 0;

            NSData *receivedBody = CFBridgingRelease(CFHTTPMessageCopyBody(incomingMessage));
            unsigned long receivedLength = receivedBody.length;

            NSLog(@"HTTPConnection - bytes for a request: expected=%d received=%d",
                  (int)expectedLength, (int)receivedLength);

            if (receivedLength >= expectedLength) {
                // Full request (and some?) was received - save off for next request
                NSData *body = [NSData dataWithBytes:receivedBody.bytes length:expectedLength];
                CFHTTPMessageSetBody(incomingMessage, (__bridge CFDataRef)body);

                // truncate ibuffer
                [istream takeUntilLengthLeft:(receivedLength - expectedLength)];
            }
            else /* Not enough */ {
                CFRelease(incomingMessage);
                return;
            }
        } else {
            NSLog(@"HTTPConnection - header is not complete");
            CFRelease(incomingMessage);
            return;
        }

        HTTPRequest *request =
            [[HTTPRequest alloc] initWithRequest:incomingMessage];
        request.delegate = self;
        CFRelease(incomingMessage);

        [self.requests insertObject:request atIndex:0];
        [self.delegate HTTPConnection:self didReceiveHTTPRequest:request];
    }
}

- (void)TCPConnectionProcessOutgoingBytes:(TCPConnection *)connection {
    [self _flushResponse];
}
@end
