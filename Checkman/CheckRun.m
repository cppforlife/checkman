#import "CheckRun.h"
#import "NSTask+Command.h"

@interface CheckRun ()
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSData *stdErrData;
@property (nonatomic, strong) NSData *stdOutData;

@property (nonatomic, assign, getter = isComplete) BOOL complete;
@property (nonatomic, assign, getter = isValid) BOOL valid;

@property (nonatomic, assign, getter = isSuccessful) BOOL successful;
@property (nonatomic, assign, getter = isChanging) BOOL changing;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *info;
@end

@implementation CheckRun

@synthesize
    delegate = _delegate,
    command = _command,
    directoryPath = _directoryPath,
    task = _task,
    stdErrData = _stdErrData,
    stdOutData = _stdOutData,
    complete = _complete,
    valid = _valid,
    successful = _successful,
    changing = _changing,
    url = _url,
    info = _info;

- (id)initWithCommand:(NSString *)command directoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.command = command;
        self.directoryPath = directoryPath;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (NSString *)description {
    return F(@"<CheckRun: %p> command='%@' directoryPath=%@",
             self, self.command, self.directoryPath);
}

#pragma mark -

- (NSTask *)task {
    if (!_task) {
        _task = [[NSTask alloc] init];
        _task.launchPath = @"/bin/bash";
        _task.currentDirectoryPath = self.directoryPath;

        // 'stty: stdin isn't a terminal' is a result of using -l
        _task.arguments = [NSArray arrayWithObjects:@"-lc", self._commandWithScriptsIncludedInPath, nil];
    }
    return _task;
}

- (NSString *)_commandWithScriptsIncludedInPath {
    // Exposing bundleScripsPath in PATH env var allows
    // included checks to be used without specifying full path.
    return F(@"PATH=$PATH:%@ %@", self._bundleScriptsPath, self.command);
}

- (NSString *)_bundleScriptsPath {
    return [[NSBundle mainBundle] resourcePath];
}

#pragma mark -

- (void)start {
    [self performSelectorInBackground:@selector(_runTask) withObject:nil];
}

- (void)_runTask {
    NSLog(@"CheckRun - started: (%p) '%@'", self, self.command);
    self.task.standardOutput = [NSPipe pipe];
    self.task.standardError = [NSPipe pipe];

#ifdef DEBUG
    // NSTask breaks Xcode's console when bash is executed (http://cocoadev.com/wiki/NSTask)
    self.task.standardInput = NSPipe.pipe;
#endif

    [self _readToEndOfFileInBackground:
            [self.task.standardOutput fileHandleForReading]
        selector:@selector(_receiveStdOutData:)];

    [self _readToEndOfFileInBackground:
            [self.task.standardError fileHandleForReading]
        selector:@selector(_receiveStdErrData:)];

    [self _waitForTaskTermination];

    [self.task launch];

    // - start thread's run loop to receive stdout/stderr end-of-file notifications
    // - use CFRunLoopRun() since NSRunLoop-run cannot be stopped (http://cocoadev.com/wiki/RunLoop)
    // - run inside own autorelease pool to stop leaking
    @autoreleasepool {
        CFRunLoopRun();
    }
}

- (void)_readToEndOfFileInBackground:(NSFileHandle *)fileHandle selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:selector
        name:NSFileHandleReadToEndOfFileCompletionNotification
        object:fileHandle];

    [fileHandle readToEndOfFileInBackgroundAndNotify];
}

- (void)_waitForTaskTermination {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(_tryCompletingTask)
        name:NSTaskDidTerminateNotification
        object:self.task];
}

- (void)_receiveStdOutData:(NSNotification *)notification {
    self.stdOutData = [notification.userInfo objectForKey:NSFileHandleNotificationDataItem];
    [self _tryCompletingTask];
}

- (void)_receiveStdErrData:(NSNotification *)notification {
    self.stdErrData = [notification.userInfo objectForKey:NSFileHandleNotificationDataItem];
    [self _tryCompletingTask];
}

- (void)_tryCompletingTask {
    if (!self.isComplete && !self.task.isRunning) {
        if (self.stdOutData && self.stdErrData) {
            [self _completeTask];
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
    }
}

- (void)_completeTask {
    self.complete = YES;

    NSDictionary *result = [self _parseJSONData:self.stdOutData];
    self.valid = (result != nil);

    self.resultValue = [result objectForKey:@"result"];
    self.changingValue = [result objectForKey:@"changing"];
    self.urlValue = [result objectForKey:@"url"];
    self.infoValue = [result objectForKey:@"info"];

    [(NSObject *)self.delegate
        performSelectorOnMainThread:@selector(checkRunDidFinish:)
        withObject:self
        waitUntilDone:NO];
}

- (NSDictionary *)_parseJSONData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

#ifdef DEBUG
    if (error) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"CheckRun - invalid json: (%p) '%@'\nError: %@\n%@", self, self.command, error, string);
    } else {
        NSLog(@"CheckRun - finished: (%p) '%@'", self, self.command);
    }
#endif
    return result;
}

#pragma mark - JSON setters

- (void)setResultValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        self.successful = [value boolValue];
    } else {
        self.successful = NO;
    }
}

- (void)setChangingValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        self.changing = [value boolValue];
    } else {
        self.changing = NO;
    }
}

- (void)setUrlValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        self.url = [NSURL URLWithString:value];
    } else {
        self.url = nil;
    }
}

- (void)setInfoValue:(id)value {
    self.info = [value isKindOfClass:[NSArray class]] ? value : nil;
}
@end


@implementation CheckRun (Debugging)

- (NSString *)executedCommand {
    return self.task.executedCommand;
}

- (NSString *)stdOut {
    return [[NSString alloc] initWithData:self.stdOutData encoding:NSUTF8StringEncoding];
}

- (NSString *)stdErr {
    return [[NSString alloc] initWithData:self.stdErrData encoding:NSUTF8StringEncoding];
}
@end
