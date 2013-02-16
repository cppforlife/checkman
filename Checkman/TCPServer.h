#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

NSString * const TCPServerErrorDomain;

typedef enum {
    kTCPServerCouldNotBindToIPv4Address = 1,
    kTCPServerCouldNotBindToIPv6Address = 2,
    kTCPServerNoSocketsAvailable = 3,
} TCPServerErrorCode;

@class TCPServer, TCPConnection;

@protocol TCPServerDelegate <NSObject>
- (void)TCPServer:(TCPServer *)server
    TCPConnectionDidStart:(TCPConnection *)connection;
@end

@interface TCPServer : NSObject
@property (nonatomic, assign) id<TCPServerDelegate> delegate;

- (id)initWithPort:(uint16_t)port;
- (uint16_t)port;

- (BOOL)start:(NSError **)error;
- (BOOL)stop;

- (void)hijackConnection:(TCPConnection *)connection;
@end
