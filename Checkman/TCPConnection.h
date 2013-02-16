#import <Foundation/Foundation.h>

@class TCPConnection, TCPBufferedInputStream, TCPBufferedOutputStream;

@protocol TCPConnectionDelegate <NSObject>
- (void)TCPConnectionDidClose:(TCPConnection *)connection;
@end

@protocol TCPConnectionDataDelegate <NSObject>
- (void)TCPConnectionProcessIncomingBytes:(TCPConnection *)connection;
- (void)TCPConnectionProcessOutgoingBytes:(TCPConnection *)connection;
@end

@interface TCPConnection : NSObject
@property (nonatomic, assign) id<TCPConnectionDelegate> ownerDelegate;
@property (nonatomic, assign) id<TCPConnectionDelegate> connectionDelegate;
@property (nonatomic, assign) id<TCPConnectionDataDelegate> dataDelegate;

// If set to true connection will be closed next time
// something is written to the wire and everything is flushed.
@property (nonatomic, assign) BOOL canClose;

- (id)initWithAddress:(NSData *)address
    socketHandle:(CFSocketNativeHandle)socketHandle
    inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream;

- (TCPBufferedInputStream *)istream;
- (TCPBufferedOutputStream *)ostream;

- (void)close;
@end
