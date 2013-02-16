#import <Foundation/Foundation.h>

@interface TCPBufferedStream : NSObject
@property (nonatomic, assign) id<NSStreamDelegate> delegate;
- (NSStream *)stream;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)open;
- (void)close;
@end


@interface TCPBufferedInputStream : TCPBufferedStream
- (id)initWithStream:(NSInputStream *)stream;

- (const void *)bufferBytes;
- (NSUInteger)bufferLength;

- (NSUInteger)read;
- (void)takeUntilLengthLeft:(NSUInteger)length;
@end


@interface TCPBufferedOutputStream : TCPBufferedStream
- (id)initWithStream:(NSOutputStream *)stream;

- (NSInteger)writeData:(NSData *)data;

- (NSInteger)flush;
- (BOOL)isFlushed;
@end
