#import "Check.h"
#import "NSObject+Delayed.h"

@interface Check ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic, strong) CheckRun *lastRun;
@property (nonatomic, strong) CheckRun *currentRun;
@end

@implementation Check

@synthesize
    name = _name,
    command = _command,
    directoryPath = _directoryPath,
    runInterval = _runInterval,
    lastRun = _lastRun,
    currentRun = _currentRun;

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status {
    switch (status) {
        case CheckStatusOk: return @"icon-ok";
        case CheckStatusFail: return @"icon-fail";
        case CheckStatusUndetermined: return @"icon-undetermined";
    }
}

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status changing:(BOOL)changing {
    NSString *imageName = [self statusImageNameForCheckStatus:status];
    if (changing) imageName = [imageName stringByAppendingString:@"-changing"];
    return imageName;
}

#pragma mark -

- (id)initWithName:(NSString *)name command:(NSString *)command directoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.name = name;
        self.command = command;
        self.directoryPath = directoryPath;
    }
    return self;
}

- (CheckStatus)status {
    if (self.lastRun && self.lastRun.isValid) {
        return self.lastRun.isSuccessful ? CheckStatusOk : CheckStatusFail;
    }
    return CheckStatusUndetermined;
}

- (BOOL)isChanging {
    return self.lastRun.isChanging;
}

- (NSArray *)info {
    return self.lastRun.info;
}

- (NSString *)output {
    return self.lastRun.output;
}

- (NSURL *)url {
    return self.lastRun.url;
}

- (void)openUrl {
    [[NSWorkspace sharedWorkspace] openURL:self.url];
}

#pragma mark - Observing running state

- (void)addObserverForRunning:(id)observer {
    [self addObserver:observer forKeyPath:@"currentRun" options:0 context:NULL];
}

- (void)removeObserverForRunning:(id)observer {
    [self removeObserver:observer forKeyPath:@"currentRun"];
}

#pragma mark -

- (void)startImmediately:(BOOL)immediately {
    NSAssert(self.runInterval > 0, @"Run interval must be > 0");
    if (immediately) {
        [self _run];
    } else {
        [self performSelectorOnNextTick:@selector(_run) afterDelay:self.runInterval];
    }
}

- (BOOL)isRunning {
    return self.currentRun != nil;
}

- (void)stop {
    @synchronized(self) {
        [self cancelPerformSelectorOnNextTick:@selector(_run)];
        self.currentRun.delegate = nil;
        self.currentRun = nil;
    }
}

- (void)_run {
    @synchronized(self) {
        NSAssert(!self.currentRun, @"Run already in progress.");
        self.currentRun = [[CheckRun alloc] initWithCommand:self.command directoryPath:self.directoryPath];
        self.currentRun.delegate = self;
        [self.currentRun start];
    }
}

- (void)checkRunDidFinish:(CheckRun *)run {
    @synchronized(self) {
        NSAssert(self.currentRun == run, @"Run must be current.");
        self.lastRun = self.currentRun;
        [self stop];
        [self startImmediately:NO];
    }
}
@end
