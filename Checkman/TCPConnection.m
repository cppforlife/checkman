#import "TCPConnection.h"
#import "TCPBufferedStreams.h"

@interface TCPConnection () <NSStreamDelegate>
@property (nonatomic, retain) NSString *uniqueId;
@property (nonatomic, retain) TCPBufferedInputStream *istream;
@property (nonatomic, retain) TCPBufferedOutputStream *ostream;
@end

@implementation TCPConnection
@synthesize
    delegate = _delegate,
    dataDelegate = _dataDelegate,
    uniqueId = _uniqueId,
    istream = _istream,
    ostream = _ostream;

- (id)initWithAddress:(NSData *)address
    inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream {

    self.uniqueId = self.class._uniqueId;

    self.istream = [[TCPBufferedInputStream alloc] initWithStream:inputStream];
    self.istream.delegate = self;
    [self.istream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:(id)kCFRunLoopCommonModes];
    [self.istream open];

    self.ostream = [[TCPBufferedOutputStream alloc] initWithStream:outputStream];
    self.ostream.delegate = self;
    [self.ostream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:(id)kCFRunLoopCommonModes];
    [self.ostream open];

    return self;
}

- (void)dealloc {
    [self invalidate];
    self.delegate = nil;
    self.dataDelegate = nil;
}

- (void)invalidate {
    [self.istream close];
    [self.ostream close];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:
            // input stream received some data
            [self _handleStreamHasBytesAvailable]; break;
        case NSStreamEventHasSpaceAvailable:
            // output stream is available for writing
            [self _handleStreamHasSpaceAvailable]; break;
        case NSStreamEventEndEncountered:
            [self _handleStreamEndEncountered:stream]; break;
        case NSStreamEventErrorOccurred:
            NSLog(@"TCPConnection - stream error: %@", stream.streamError); break;
        default: break;
    }
}

- (void)_handleStreamHasBytesAvailable {
    if ([self.istream read] > 0) {
        [self.dataDelegate TCPConnectionProcessIncomingBytes:self];
    }
}

- (void)_handleStreamHasSpaceAvailable {
    [self.dataDelegate TCPConnectionProcessOutgoingBytes:self];
    [self.ostream flush];
}

- (void)_handleStreamEndEncountered:(NSStream *)stream {
    if (stream == self.ostream.stream) {
        [self invalidate];
        [self.delegate TCPConnectionDidClose:self];
    }
}

+ (NSString *)_uniqueId {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return CFBridgingRelease(uuidString);
}
@end
