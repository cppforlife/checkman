#import "HTTPConnection.h"
#import "TCPConnection.h"
#import "TCPBufferedStreams.h"
#import "HTTPRequest.h"

@interface HTTPConnection ()
    <TCPConnectionDelegate, TCPConnectionDataDelegate, HTTPRequestDelegate>
@property (nonatomic, retain) TCPConnection *tcpConnection;
@property (nonatomic, retain) NSMutableArray *requests;
@end

@implementation HTTPConnection
@synthesize
    ownerDelegate = _ownerDelegate,
    connectionDelegate = _connectionDelegate,
    dataDelegate = _dataDelegate,
    tcpConnection = _tcpConnection,
    requests = _requests;

- (id)initWithTCPConnection:(TCPConnection *)tcpConnection {
    if (self = [super init]) {
        self.tcpConnection = tcpConnection;
        self.tcpConnection.connectionDelegate = self;
        self.tcpConnection.dataDelegate = self;
        self.requests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.ownerDelegate = nil;
    self.connectionDelegate = nil;
    self.dataDelegate = nil;
}

#pragma mark - Closing connection

- (void)close {
    [self.tcpConnection close];
}

- (void)TCPConnectionDidClose:(TCPConnection *)connection {
    [self.connectionDelegate HTTPConnectionDidClose:self];
    [self.ownerDelegate HTTPConnectionDidClose:self];
}

#pragma mark - Flushing responses

- (void)_flushResponse {
    HTTPRequest *request = self.requests.lastObject;
    if (request.hasResponded) {
        if (!request.isResponseConnectionUpgrade) {
            self.tcpConnection.canClose = YES;
        }
        [self.tcpConnection.ostream writeData:request.responseAsData];
        [self.requests removeLastObject];
    }
}

- (BOOL)isFlushed {
    return self.requests.count == 0;
}

#pragma mark - TCPConnectionDataDelegate

- (void)TCPConnectionProcessIncomingBytes:(TCPConnection *)connection {
    TCPBufferedInputStream *istream = self.tcpConnection.istream;

    while (istream.bufferLength > 0) {
        CFHTTPMessageRef incomingMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        if (!incomingMessage) NSAssert(NO, @"HTTPConnection - failed to create empty http message");

        Boolean success = CFHTTPMessageAppendBytes(
            incomingMessage, istream.bufferBytes, (CFIndex)istream.bufferLength);
        if (!success) NSAssert(NO, @"HTTPConnection - failed to append bytes");

        NSLog(@"HTTPConnection - incoming: %d bytes (buffered)", (int)istream.bufferLength);

        if (CFHTTPMessageIsHeaderComplete(incomingMessage)) {
            NSString *expectedLengthValue =
                CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(
                    incomingMessage, (CFStringRef)@"Content-Length"));

            NSData *receivedBody = CFBridgingRelease(CFHTTPMessageCopyBody(incomingMessage));

            unsigned long expectedLength =
                expectedLengthValue ? (unsigned long)expectedLengthValue.intValue : 0;
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
        [self.dataDelegate HTTPConnection:self didReceiveHTTPRequest:request];
    }
}

- (void)TCPConnectionProcessOutgoingBytes:(TCPConnection *)connection {
    [self _flushResponse];
}

- (void)HTTPRequestDidRespond:(HTTPRequest *)request {
    NSLog(@"HTTPConnection - request did respond");
    [self _flushResponse];
}
@end
