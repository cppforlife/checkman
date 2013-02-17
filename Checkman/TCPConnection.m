#import "TCPConnection.h"
#import "TCPBufferedStreams.h"

@interface TCPConnection () <NSStreamDelegate>
@property (nonatomic, assign) CFSocketNativeHandle socketHandle;
@property (nonatomic, retain) TCPBufferedInputStream *istream;
@property (nonatomic, retain) TCPBufferedOutputStream *ostream;
@end

@implementation TCPConnection
@synthesize
    ownerDelegate = _ownerDelegate,
    connectionDelegate = _connectionDelegate,
    dataDelegate = _dataDelegate,
    canClose = _canClose,
    socketHandle = _socketHandle,
    istream = _istream,
    ostream = _ostream;

- (id)initWithAddress:(NSData *)address
    socketHandle:(CFSocketNativeHandle)socketHandle
    inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream {

    if (self = [super init]) {
        self.socketHandle = socketHandle;

        self.istream = [[TCPBufferedInputStream alloc] initWithStream:inputStream];
        self.istream.delegate = self;
        [self.istream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:(id)kCFRunLoopCommonModes];
        [self.istream open];

        self.ostream = [[TCPBufferedOutputStream alloc] initWithStream:outputStream];
        self.ostream.delegate = self;
        [self.ostream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:(id)kCFRunLoopCommonModes];
        [self.ostream open];
    }
    return self;
}

- (void)dealloc {
    [self close];
    self.ownerDelegate = nil;
    self.connectionDelegate = nil;
    self.dataDelegate = nil;
}

#pragma mark - Closing connection

- (void)close {
    if (self.istream) {
        [self.istream close];
        self.istream = nil;
    }
    if (self.ostream) {
        [self.ostream close];
        self.ostream = nil;
    }
    if (self.socketHandle != -1) {
        close(self.socketHandle);
        self.socketHandle = -1;

        [self.connectionDelegate TCPConnectionDidClose:self];
        [self.ownerDelegate TCPConnectionDidClose:self];
    }
}

#pragma mark - Connection events

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
            [self _handleStreamErrorEncountered:stream]; break;
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
    [self _closeIfCanClose];
}

- (void)_closeIfCanClose {
    if (self.canClose && self.ostream.isFlushed) {
        [self close];
    }
}

- (void)_handleStreamEndEncountered:(NSStream *)stream {
    if (stream == self.ostream.stream) {
        [self close];
    }
}

- (void)_handleStreamErrorEncountered:(NSStream *)stream {
    NSLog(@"TCPConnection - stream error: %@", stream.streamError);
    [self close];
}
@end
