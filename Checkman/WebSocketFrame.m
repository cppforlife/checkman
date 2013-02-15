#import "WebSocketFrame.h"

#define kWebSocketFrame_MaxHeaderLength 32
#define WebSocketFrame_MaxFrameLength(dataLength) \
    (kWebSocketFrame_MaxHeaderLength + dataLength)

#define kWebSocketFrame_OpCodeDataText 0x1
#define kWebSocketFrame_OpCodeDataBinary 0x2

#define kWebSocketFrame_MaskFin 0x80
#define kWebSocketFrame_MaskMask 0x80

@interface WebSocketFrame ()
@end

@implementation WebSocketFrame
@synthesize data = _data;

- (void)setData:(id)data {
    BOOL isString = [data isKindOfClass:NSString.class];
    BOOL isData = [data isKindOfClass:NSData.class];
    NSAssert(isString || isData, @"Must be string or data (was %@)", [data class]);
    _data = data;
}

- (NSData *)asWireData {
    uint8_t opcode = 0;
    uint8_t *dataBytes = NULL;
    size_t dataLength = 0;

    NSAssert(self.data, @"Data must not be nil");

    if ([self.data isKindOfClass:NSString.class]) {
        opcode = kWebSocketFrame_OpCodeDataText;
        dataBytes = (uint8_t *)[self.data UTF8String];
        dataLength = [self.data lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    } else {
        opcode = kWebSocketFrame_OpCodeDataBinary;
        dataBytes = (uint8_t *)[self.data bytes];
        dataLength = [self.data length];
    }

    NSMutableData *frame =
        [[NSMutableData alloc]
            initWithLength:WebSocketFrame_MaxFrameLength(dataLength)];
    NSAssert(frame, @"Message is too big (Needs to be fragmented)");

    uint8_t *frameBytes = (uint8_t *)frame.mutableBytes;
    size_t frameLength = 0;

    frameBytes[0] |= kWebSocketFrame_MaskFin;
    frameBytes[0] |= opcode;
    frameLength += 1;

    // No need to mark as masked since this is used on the server
    // frameBytes[1] |= kWebSocketFrame_MaskMask;
    frameLength += 1;

    if (dataLength < 126) {
        frameBytes[1] |= dataLength;
    } else if (dataLength <= UINT16_MAX) {
        frameBytes[1] |= 126;
        *((uint16_t *)(frameBytes + frameLength)) = EndianU16_BtoN((uint16_t)dataLength);
        frameLength += sizeof(uint16_t);
    } else {
        frameBytes[1] |= 127;
        *((uint64_t *)(frameBytes + frameLength)) = EndianU64_BtoN((uint64_t)dataLength);
        frameLength += sizeof(uint64_t);
    }

    // No need to mask data since this is used on the server
    for (size_t i=0; i<dataLength;) {
        frameBytes[frameLength++] = dataBytes[i++];
    }

    frame.length = frameLength;
    // [self _printBits:frame];
    return frame;
}

#pragma mark - Debug

- (void)_printBits:(NSData *)data {
    unsigned char mask = 0x01;
    char *bytes = (char *)data.bytes;
    int ptr = 0, bit = 0;
    for (;ptr < data.length; ptr++) {
        printf("0x%02X ", (unsigned char)*(bytes+ptr));
        for (bit=7; bit>=0; bit--) {
            if ((mask << bit) & (unsigned char)*(bytes+ptr)) {
                printf("1");
            } else printf("0");
        }
        printf(ptr % 4 == 3 ? "\n" : " ");
    }
}
@end
