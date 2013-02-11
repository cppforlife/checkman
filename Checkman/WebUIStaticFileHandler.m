#import "WebUIStaticFileHandler.h"
#import "HTTPRequest.h"

@implementation WebUIStaticFileHandler

- (void)handle {
    [self _handleUnsupportedVersion]
    || [self _handleUnsupportedRequest]
    || [self _handleNonGetRequest]
    || [self _respondWithData]
    || [self _respondWithStatus:404];
}

#pragma mark - Responding with data

- (NSData *)_fetchDataAtPath:(NSString *)path {
    NSString *filePath =
        [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.resourcePath, path];
    NSLog(@"WebUIStaticFileHandler - returning: %@", filePath);
    return [NSData dataWithContentsOfFile:filePath];
}

- (BOOL)_respondWithData {
    NSData *data = [self _fetchDataAtPath:self.request.requestURL.path];
    if (data) {
        self.request.responseStatus = 200;
        self.request.responseBody = data;
        [self.request
            setResponseHeader:@"Content-Length"
            value:[NSString stringWithFormat:@"%ld", data.length]];
        [self.request respond];
        return YES;
    }
    return NO;
}
@end
