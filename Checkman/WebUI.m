#import "WebUI.h"
#import "HTTPServer.h"
#import "HTTPRequest.h"
#import "WebUIStaticFileHandler.h"
#import "WebUIWebSocketHandler.h"
#import "CheckCollection.h"
#import "Check.h"

@interface WebUI ()
    <CheckCollectionDelegate, HTTPServerDelegate, WebUIWebSocketHandlerDelegate>
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, strong) NSMutableArray *checkUpdatesHandlers;
@end

@implementation WebUI
@synthesize
    checks = _checks,
    httpServer = _httpServer,
    checkUpdatesHandlers = _checkUpdatesHandlers;

- (id)init {
    if (self = [super init]) {
        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;
 
        self.httpServer = [HTTPServer onPort:1234];
        self.httpServer.requestDelegate = self;
        self.checkUpdatesHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)start {
    [self performSelectorInBackground:@selector(_startServer) withObject:nil];
}

- (void)_startServer {
    [self.httpServer start:nil];
}

#pragma mark -

- (void)addCheck:(Check *)check {
    [self.checks addCheck:check];
    [self _showCheck:check];
}

- (void)removeCheck:(Check *)check {
    [self.checks removeCheck:check];
    [self _hideCheck:check];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollection:(CheckCollection *)collection
    didUpdateStatusFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
        didUpdateChangingFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
        checkDidChangeStatus:(Check *)check {
    [self _updateCheck:check];
}

- (void)checkCollection:(CheckCollection *)collection
        checkDidChangeChanging:(Check *)check {
    [self _updateCheck:check];
}

#pragma mark -

- (void)_showCheck:(Check *)check {
    [self.checkUpdatesHandlers
        makeObjectsPerformSelector:@selector(sendMessage:)
        withObject:[self _showCheckJSONMessage:check]];
}

- (void)_hideCheck:(Check *)check {
    [self.checkUpdatesHandlers
        makeObjectsPerformSelector:@selector(sendMessage:)
        withObject:[self _hideCheckJSONMessage:check]];
}

- (void)_updateCheck:(Check *)check {
    [self.checkUpdatesHandlers
        makeObjectsPerformSelector:@selector(sendMessage:)
        withObject:[self _updateCheckJSONMessage:check]];
}

#pragma mark - Messages

- (NSString *)_showCheckJSONMessage:(Check *)check {
    return [self _checkJSONMessage:check type:@"check.show"];
}

- (NSString *)_hideCheckJSONMessage:(Check *)check {
    return [self _checkJSONMessage:check type:@"check.hide"];
}

- (NSString *)_updateCheckJSONMessage:(Check *)check {
    return [self _checkJSONMessage:check type:@"check.update"];
}

static inline id _WUObjOrNull(id value) {
    return value ? value : [NSNull null];
}

- (NSString *)_checkJSONMessage:(Check *)check type:(NSString *)type {
    NSDictionary *jsonCheckObject =
        [NSDictionary dictionaryWithObjectsAndKeys:
            check.tagAsNumber, @"id",
            _WUObjOrNull(check.name), @"name",
            _WUObjOrNull(check.primaryContextName), @"primary_context_name",
            _WUObjOrNull(check.secondaryContextName), @"secondary_context_name",
            _WUObjOrNull(check.statusNotificationStatus), @"status",
            [NSNumber numberWithBool:check.isChanging], @"changing",
            [NSNumber numberWithBool:check.isDisabled], @"disabled", nil];
    NSDictionary *jsonObject =
        [NSDictionary dictionaryWithObjectsAndKeys:
            type, @"type",
            jsonCheckObject, @"check", nil];
    NSData *data =
        [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - HTTPServerDelegate

- (void)HTTPServer:(HTTPServer *)server
    HTTPConnection:(HTTPConnection *)connection
    didReceiveHTTPRequest:(HTTPRequest *)request {

    if ([request.requestURL.path isEqual:@"/check_updates"]) {
        WebUIWebSocketHandler *handler =
            [[WebUIWebSocketHandler alloc]
                initWithHTTPServer:server
                HTTPConnection:connection
                HTTPRequest:request];
        [self.checkUpdatesHandlers addObject:handler];
        handler.delegate = self;
        [handler handle];
    }
    else {
        WebUIStaticFileHandler *handler =
            [[WebUIStaticFileHandler alloc]
                initWithHTTPServer:server
                HTTPConnection:connection
                HTTPRequest:request];
        [handler handle];
    }
}

#pragma mark - WebUIWebkSocketHandlerDelegate

- (void)WebUIWebSocketHandlerDidAcceptNewConnection:(WebUIWebSocketHandler *)handler {
    for (Check *check in self.checks) {
        [handler sendMessage:[self _showCheckJSONMessage:check]];
    }
}
@end
