#import "TCPBufferedStreams.h"

@interface TCPBufferedStream ()
@property (nonatomic, retain) NSStream *stream;
@property (nonatomic, retain) NSMutableData *buffer;
@end

@implementation TCPBufferedStream
@synthesize stream = _stream, buffer = _buffer;

- (void)setDelegate:(id<NSStreamDelegate>)delegate {
    [self.stream setDelegate:delegate];
}

- (id<NSStreamDelegate>)delegate {
    return [self.stream delegate];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    [self.stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)open {
    @synchronized(self) {
        [self.stream open];
    }
}

- (void)close {
    @synchronized(self) {
        [self.stream close];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<TCPBufferedStream: %p> status=%ld error=%@",
            self, self.stream.streamStatus, self.stream.streamError];
}
@end


@implementation TCPBufferedInputStream

- (id)initWithStream:(NSInputStream *)stream {
    if (self = [super init]) {
        self.stream = stream;
        self.buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (const void *)bufferBytes {
    @synchronized(self) {
        return self.buffer.bytes;
    }
}

- (NSUInteger)bufferLength {
    @synchronized(self) {
        return self.buffer.length;
    }
}

- (void)takeUntilLengthLeft:(NSUInteger)length {
    @synchronized(self) {
        void *dest = self.buffer.mutableBytes;
        void *src = self.buffer.mutableBytes + self.buffer.length - length;
        memmove(dest, src, length);
        self.buffer.length = length;
    }
}

- (NSUInteger)read {
    @synchronized(self) {
        NSInputStream *inputStream = (NSInputStream *)self.stream;

        uint8_t *buffer = NULL;
        NSUInteger bufferLength = 0;

        // obtain buffer to available bytes
        if (![inputStream getBuffer:&buffer length:&bufferLength]) {
            uint8_t copyBuffer[16 * 1024];
            NSInteger bytesRead = [inputStream read:copyBuffer maxLength:sizeof(copyBuffer)];
            if (bytesRead > 0) {
                bufferLength = (NSUInteger)bytesRead;
                buffer = copyBuffer;
            } else /* 0 or -1 when error */ return 0;
        }
        if (bufferLength > 0) {
            [self.buffer appendBytes:buffer length:bufferLength];
            return bufferLength;
        }
        return 0;
    }
}
@end


@implementation TCPBufferedOutputStream

- (id)initWithStream:(NSOutputStream *)stream {
    if (self = [super init]) {
        self.stream = stream;
        self.buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (NSInteger)writeData:(NSData *)data {
    @synchronized(self) {
        return [self write:data.bytes maxLength:data.length];
    }
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len {
    [self.buffer appendBytes:buffer length:len];
    [self flush];
    return 0;
}

- (NSInteger)flush {
    @synchronized(self) {
        NSOutputStream *outputStream = (NSOutputStream *)self.stream;

        unsigned long bufferLength = self.buffer.length;
        if (bufferLength == 0) return 0;

        // Looks like unless space available
        // subsequent write blocks
        if (!outputStream.hasSpaceAvailable) return 0;
        NSInteger writtenLength =
            [outputStream write:self.buffer.bytes maxLength:bufferLength];

        // Ignore capacity exceeded (0) or other errors (-1)
        if (writtenLength <= 0) return 0;

        if (bufferLength == writtenLength) {
            self.buffer.length = 0;
        }
        else if (bufferLength > writtenLength) {
            void *dest = self.buffer.mutableBytes;
            void *src = self.buffer.mutableBytes + writtenLength;
            memmove(dest, src, bufferLength - (unsigned long)writtenLength);
            self.buffer.length = bufferLength - (unsigned long)writtenLength;
        }
        else NSAssert(NO, @"HTTPBufferedOutputStream - wrote more than asked for");

        return 0;
    }
}

- (BOOL)isFlushed {
    @synchronized(self) {
        return self.buffer.length == 0;
    }
}
@end
