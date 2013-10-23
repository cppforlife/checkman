#import "WebUI.h"
#import "CheckCollection.h"
#import "Check.h"
#import "HTTPServer.h"
#import "HTTPRequest.h"
#import "WebUIStaticFileHandler.h"
#import "WebUIWebSocketHandler.h"
#import "WebUIMessages.h"
#import "NSCustomTicker.h"

@interface WebUI ()
    <CheckCollectionDelegate, HTTPServerDelegate,
    WebUIWebSocketHandlerDelegate, NSCustomTickerDelegate>
@property (nonatomic, strong) CheckCollection *checks;

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, strong) NSMutableArray *checkUpdatesHandlers;

@property (nonatomic, strong) WebUIMessages *messages;
@property (nonatomic, strong) NSCustomTicker *heartBeatTicker;
@property (nonatomic, strong) NSCustomTicker *safetyTicker;
@end

@implementation WebUI
@synthesize
    checks = _checks,
    httpServer = _httpServer,
    checkUpdatesHandlers = _checkUpdatesHandlers,
    messages = _messages,
    heartBeatTicker = _heartBeatTicker,
    safetyTicker = _safetyTicker;

- (id)initWithPort:(uint16_t)port {
    if (self = [super init]) {
        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;

        self.httpServer = [HTTPServer onPort:port];
        self.httpServer.requestDelegate = self;

        self.checkUpdatesHandlers = [[NSMutableArray alloc] init];
        self.messages = [[WebUIMessages alloc] init];

        // WebUIHeartBeat (js) expect to receive at least one beat every 10 secs.
        self.heartBeatTicker = [[NSCustomTicker alloc] initWithInterval:5];
        self.heartBeatTicker.delegate = self;

        // It's extremely important that WebUI (js) does not get out of sync
        // from actual check results; so we'll use this timer to dump
        // all state to all connections once in a while.
        self.safetyTicker = [[NSCustomTicker alloc] initWithInterval:120];
        self.safetyTicker.delegate = self;
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
    [self _showCheck:check];
}

- (void)checkCollection:(CheckCollection *)collection
        checkDidChangeChanging:(Check *)check {
    [self _showCheck:check];
}

#pragma mark -

- (void)_showAllChecksWithHandler:(WebUIWebSocketHandler *)handler {
    for (Check *check in self.checks) {
        [handler sendMessage:[self.messages showCheckJSONMessage:check]];
    }
}

- (void)_showCheck:(Check *)check {
    [self.checkUpdatesHandlers
        makeObjectsPerformSelector:@selector(sendMessage:)
        withObject:[self.messages showCheckJSONMessage:check]];
}

- (void)_hideCheck:(Check *)check {
    [self.checkUpdatesHandlers
        makeObjectsPerformSelector:@selector(sendMessage:)
        withObject:[self.messages hideCheckJSONMessage:check]];
}

#pragma mark - HTTPServerDelegate

- (void)HTTPServer:(HTTPServer *)server
    HTTPConnection:(HTTPConnection *)connection
    didReceiveHTTPRequest:(HTTPRequest *)request {

    @autoreleasepool {
        if ([request.requestURL.path isEqual:@"/check_updates"]) {
            WebUIWebSocketHandler *handler =
                [[WebUIWebSocketHandler alloc]
                    initWithHTTPServer:server
                    HTTPConnection:connection
                    HTTPRequest:request];
            [self.checkUpdatesHandlers addObject:handler];
            handler.delegate = self;
            [handler handle];
        } else {
            WebUIStaticFileHandler *handler =
                [[WebUIStaticFileHandler alloc]
                    initWithHTTPServer:server
                    HTTPConnection:connection
                    HTTPRequest:request];
            [handler handle];
        }
    }
}

#pragma mark - WebUIWebkSocketHandlerDelegate

- (void)WebUIWebSocketHandler:(WebUIWebSocketHandler *)handler
        WebSocketConnectionDidStart:(WebSocketConnection *)connnection {
    // Connection is added to checkUpdatesHandlers
    // when initial HTTP connection is established.
    [self _showAllChecksWithHandler:handler];
}

- (void)WebUIWebSocketHandler:(WebUIWebSocketHandler *)handler
        WebSocketConnectionDidEnd:(WebSocketConnection *)connnection{
    [self.checkUpdatesHandlers removeObjectIdenticalTo:handler];
}

#pragma mark - NSCustomTimerDelegate

- (void)customTickerDidTick:(NSCustomTicker *)ticker {
    if (ticker == self.safetyTicker) {
        for (WebUIWebSocketHandler *handler in self.checkUpdatesHandlers) {
            [self _showAllChecksWithHandler:handler];
        }
    } else {
        [self.checkUpdatesHandlers
            makeObjectsPerformSelector:@selector(sendMessage:)
            withObject:[self.messages heartBeatJSONMessage:self.checks]];
    }
}
@end
