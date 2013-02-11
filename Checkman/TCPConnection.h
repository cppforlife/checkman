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
@property (nonatomic, assign) id<TCPConnectionDelegate> delegate;
@property (nonatomic, assign) id<TCPConnectionDataDelegate> dataDelegate;

- (id)initWithAddress:(NSData *)address
    inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream;

- (NSString *)uniqueId;

- (TCPBufferedInputStream *)istream;
- (TCPBufferedOutputStream *)ostream;
@end
