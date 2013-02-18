#import "TCPServer.h"
#import "TCPConnection.h"
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

NSString * const TCPServerErrorDomain = @"TCPServerErrorDomain";

@interface TCPServer () <TCPConnectionDelegate>
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) CFSocketRef ipv4socket;
@property (nonatomic, retain) NSMutableArray *connections;
@end

@implementation TCPServer
@synthesize
    delegate = _delegate,
    port = _port,
    ipv4socket = _ipv4socket,
    connections = _connections;

- (id)initWithPort:(uint16_t)port {
    if (self = [super init]) {
        self.port = port;
        self.connections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // clone connections??
    [self stop];
    self.delegate = nil;
}

- (BOOL)start:(NSError **)error {
    NSLog(@"TCPServer - starting on port: %d", (int)self.port);
    return self._createSocket
        && self._configureSocketAddress
        && self._createRunLoopSource;
}

- (BOOL)stop {
    if (self.ipv4socket) {
        CFSocketInvalidate(self.ipv4socket);
        self.ipv4socket = nil;
    }
    return YES;
}

#pragma mark - Connection management

- (void)_handleNewConnectionFromAddress:(NSData *)address
    socketHandle:(CFSocketNativeHandle)socketHandle
    inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream {

    TCPConnection *connection =
        [[TCPConnection alloc]
            initWithAddress:address
            socketHandle:socketHandle
            inputStream:inputStream
            outputStream:outputStream];

    [self.connections addObject:connection];
    connection.ownerDelegate = self;

    [self.delegate TCPServer:self TCPConnectionDidStart:connection];
}

- (void)TCPConnectionDidClose:(TCPConnection *)connection {
    connection.ownerDelegate = self;
    [self.connections removeObjectIdenticalTo:connection];
}

- (void)hijackConnection:(TCPConnection *)connection {
    connection.ownerDelegate = nil;
    [self.connections removeObjectIdenticalTo:connection];
}

static void _TCPServerAcceptCallBack(
        CFSocketRef socket, CFSocketCallBackType type,
        CFDataRef address, const void *data, void *info) {
    TCPServer *server = (__bridge TCPServer *)info;

    if (type == kCFSocketAcceptCallBack) {
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;

        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);

        if (readStream && writeStream) {
            CFReadStreamSetProperty(readStream,
                kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [server _handleNewConnectionFromAddress:nil
                socketHandle:nativeSocketHandle
                inputStream:(__bridge NSInputStream *)readStream
                outputStream:(__bridge NSOutputStream *)writeStream];
        } else {
            close(nativeSocketHandle);
        }

        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

#pragma mark -

- (BOOL)_createSocket {
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};

    self.ipv4socket = CFSocketCreate(kCFAllocatorDefault,
        PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack,
        (CFSocketCallBack)&_TCPServerAcceptCallBack, &socketCtxt);

    if (self.ipv4socket == NULL) {
        [self _cleanUpWithError:kTCPServerNoSocketsAvailable];
        return NO;
    }

    int yes = 1;
    setsockopt(CFSocketGetNative(self.ipv4socket),
        SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

    return YES;
}

- (BOOL)_configureSocketAddress {
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(self.port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];

    if (CFSocketSetAddress(self.ipv4socket, (__bridge CFDataRef)address4) != kCFSocketSuccess) {
        [self _cleanUpWithError:kTCPServerCouldNotBindToIPv4Address];
        return NO;
    }

    // If port is 0 it will be automatically assigned
    // so let's get it from the address.
    if (self.port == 0) {
        NSData *addr = CFBridgingRelease(CFSocketCopyAddress(self.ipv4socket));
        memcpy(&addr4, addr.bytes, addr.length);
        self.port = ntohs(addr4.sin_port);
    }
    return YES;
}

- (BOOL)_createRunLoopSource {
    // set up the run loop sources for the socket
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 =
        CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.ipv4socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);

    [NSThread currentThread].name = \
        [NSString stringWithFormat:@"TCPServer - port: %d", (int)self.port];

    @autoreleasepool {
        CFRunLoopRun();
    }
    return YES;
}

- (void)_cleanUpWithError:(NSInteger)code {
    // *error = [[NSError alloc] initWithDomain:TCPServerErrorDomain code:code userInfo:nil];
    self.ipv4socket = nil;
}

#pragma mark -

- (void)_debugActiveConnections {
    NSLog(@"TCPServer - %ld active connections:", self.connections.count);
    for (TCPConnection *connection in self.connections) {
        NSLog(@"TCPServer - connection %p: ostream='%@' istream='%@'",
              connection, connection.istream, connection.ostream);
    }
}
@end

