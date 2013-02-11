#import "WebSocketSec.h"

@implementation WebSocketSec

+ (NSString *)secAcceptWithSecKey:(NSString *)secKey {
    static NSString *magic = @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
    NSString *secKeyMagic = [NSString stringWithFormat:@"%@%@", secKey, magic];
    return [self _sha1ThenBase64EncodeString:secKeyMagic];
}

#pragma mark -

+ (NSString *)_sha1ThenBase64EncodeString:(NSString *)string {
    NSString *cmd = [NSString stringWithFormat:
        @"echo -n '%@' | openssl dgst -binary -sha1 | openssl enc -base64", string];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = [NSArray arrayWithObjects:@"-c", cmd, nil];

    task.standardOutput = [NSPipe pipe];
    task.standardError = [NSPipe pipe];
    [task launch];
    [task waitUntilExit];

    NSData *output =
        [[task.standardOutput fileHandleForReading] readDataToEndOfFile];
    NSString *outputString =
        [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];

    return [outputString stringByTrimmingCharactersInSet:
            NSCharacterSet.whitespaceAndNewlineCharacterSet];
}
@end
