#import "AsyncTask.h"

@interface AsyncTask ()
@property (nonatomic, strong) NSTask *task;
@property (nonatomic, assign, getter = isComplete) BOOL complete;

@property (nonatomic, strong) NSData *stdErrData;
@property (nonatomic, strong) NSData *stdOutData;
@end

@implementation AsyncTask
@synthesize
    delegate = _delegate,
    task = _task,
    complete = _complete,
    stdErrData = _stdErrData,
    stdOutData = _stdOutData;

- (id)init {
    if (self = [super init]) {
        self.task = [[NSTask alloc] init];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark -

- (void)setLaunchPath:(NSString *)launchPath {
    self.task.launchPath = launchPath;
}

- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath {
    self.task.currentDirectoryPath = currentDirectoryPath;
}

- (void)setArguments:(NSArray *)arguments {
    self.task.arguments = arguments;
}

#pragma mark -

- (void)run {
    [self performSelectorInBackground:@selector(_runTask) withObject:nil];
}

- (void)_runTask {
    [NSThread currentThread].name = @"AsyncTask - _runTask";

    NSPipe *standardOutput = [NSPipe pipe];
    if (standardOutput) {
        self.task.standardOutput = standardOutput;
    } else return [self _failCompletingTask];

    NSPipe *standardError = [NSPipe pipe];
    if (standardError) {
        self.task.standardError = standardError;
    } else return [self _failCompletingTask];

#ifdef DEBUG
    // NSTask breaks Xcode's console when bash is executed
    // (more discussion http://cocoadev.com/wiki/NSTask).
    NSPipe *standardInput = [NSPipe pipe];
    if (standardInput) {
        self.task.standardInput = standardInput;
    } else return [self _failCompletingTask];
#endif

    [self _readToEndOfFileInBackground:standardOutput.fileHandleForReading
        selector:@selector(_receiveStdOutData:)];
    [self _readToEndOfFileInBackground:standardError.fileHandleForReading
        selector:@selector(_receiveStdErrData:)];
    [self _waitForTaskTermination];

    @try {
        [self.task launch];
    } @catch (NSException *exception) {
        // e.g. NSInvalidArgumentException reason: 'working directory doesn't exist.'
        if (exception.name == NSInvalidArgumentException) {
            return [self _failCompletingTask];
        } else @throw;
    }

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
    if (self.isComplete || self.task.isRunning) return;
    if (!self.stdOutData || !self.stdErrData) return;

    self.complete = YES;
    [self.delegate asyncTaskDidComplete:self];

    // stop run loop started by -_runTask
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)_failCompletingTask {
    self.complete = YES;
    self.stdErrData = [NSData data];
    self.stdOutData = [NSData data];
    [self.delegate asyncTaskDidComplete:self];
}
@end


@implementation AsyncTask (Bash)
+ (AsyncTask *)bashTaskWithCommand:(NSString *)command directoryPath:(NSString *)directoryPath {
    AsyncTask *task = [[AsyncTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.currentDirectoryPath = directoryPath;

    // * login shell is not used because it adds a lot of overhead
    //   to running a check since bash will load all of user settings
    // * user can use bash source command to load additional settings
    // * adding -l could result in 'stty: stdin isn't a terminal'
    NSString *bashCommand = [self _commandWithBundleInPath:command];
    task.arguments = [NSArray arrayWithObjects:@"-c", bashCommand, nil];

    return task;
}

+ (NSString *)_commandWithBundleInPath:(NSString *)command {
    // Exposing mainBundle's path in PATH env var allows
    // included checks to be used without specifying full path.
    return F(@"PATH=$PATH:%@ %@", NSBundle.mainBundle.resourcePath, command);
}
@end


@implementation AsyncTask (Command)
- (NSString *)executedCommand {
    return F(@"cd %@; %@ %@",
             self.task.currentDirectoryPath,
             self.task.launchPath,
             self._argumentsAsEscapedString);
}

// Does not correctly handle quotes
- (NSString *)_argumentsAsEscapedString {
    return F(@"\"%@\"", [self.task.arguments componentsJoinedByString:@"\" \""]);
}
@end
