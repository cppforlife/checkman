#import "Check.h"
#import "CheckRun.h"
#import "NSObject+Delayed.h"

#define DelegateToLastRun(name, type) \
    - (type)name { return self.lastRun.name; }

@interface Check (Observers_Private)
- (void)_didChangeStatus;
- (void)_didChangeChanging;
- (void)_didChangeRunning;
@end

@interface Check () <CheckRunDelegate>
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
    disabled = _disabled,
    lastRun = _lastRun,
    currentRun = _currentRun;

- (id)initWithName:(NSString *)name
           command:(NSString *)command
     directoryPath:(NSString *)directoryPath {

    if (self = [super init]) {
        self.name = name;
        self.command = command;
        self.directoryPath = directoryPath;
    }
    return self;
}

- (NSString *)description {
    return F(@"<Check: %p> name=%@ command='%@' directoryPath=%@ runInterval=%ld",
             self, self.name, self.command, self.directoryPath, self.runInterval);
}

- (void)setDisabled:(BOOL)disabled {
    @synchronized(self) {
        _disabled = disabled;
        self.lastRun = nil;
        [self stop];
    }
}

- (void)setLastRun:(CheckRun *)lastRun {
    @synchronized(self) {
        CheckStatus oldStatus = self.status;
        BOOL oldChanging = self.isChanging;

        _lastRun = lastRun;

        if (oldStatus != self.status) {
            [self _didChangeStatus];
        }
        if (oldChanging != self.isChanging) {
            [self _didChangeChanging];
        }
    }
}

- (void)setCurrentRun:(CheckRun *)currentRun {
    @synchronized(self) {
        BOOL oldRunning = self.isRunning;
        _currentRun = currentRun;
        if (oldRunning != self.isRunning) {
            [self _didChangeRunning];
        }
    }
}

- (CheckStatus)status {
    if (self.lastRun && self.lastRun.isValid) {
        return self.lastRun.isSuccessful ? CheckStatusOk : CheckStatusFail;
    }
    return CheckStatusUndetermined;
}

DelegateToLastRun(isChanging, BOOL);
DelegateToLastRun(info, NSArray *);
DelegateToLastRun(url, NSURL *);

#pragma mark -

- (void)startImmediately:(BOOL)immediately {
    if (self.disabled) return;
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

#pragma mark - CheckRunDelegate

- (void)checkRunDidFinish:(CheckRun *)run {
    @synchronized(self) {
        NSAssert(self.currentRun == run, @"Run must be current.");
        self.lastRun = self.currentRun;
        [self stop];
        [self startImmediately:NO];
    }
}
@end


@implementation Check (Observers_Private)
static NSString *CheckDidChangeStatus = @"CheckDidChangeStatus";
static NSString *CheckDidChangeChanging = @"CheckDidChangeChanging";
static NSString *CheckDidChangeRunning = @"CheckDidChangeRunning";

- (void)_didChangeStatus {
    [NSNotificationCenter.defaultCenter
        postNotificationName:CheckDidChangeStatus object:self];
}

- (void)_didChangeChanging {
    [NSNotificationCenter.defaultCenter
        postNotificationName:CheckDidChangeChanging object:self];
}

- (void)_didChangeRunning {
    [NSNotificationCenter.defaultCenter
        postNotificationName:CheckDidChangeRunning object:self];
}
@end


@implementation Check (Observers)
- (void)addObserver:(id<CheckDelegate>)observer {
    [NSNotificationCenter.defaultCenter
        addObserver:observer selector:@selector(checkDidChangeStatus:)
        name:CheckDidChangeStatus object:self];
    [NSNotificationCenter.defaultCenter
        addObserver:observer selector:@selector(checkDidChangeChanging:)
        name:CheckDidChangeChanging object:self];
    [NSNotificationCenter.defaultCenter
        addObserver:observer selector:@selector(checkDidChangeRunning:)
        name:CheckDidChangeRunning object:self];
}

- (void)removeObserver:(id<CheckDelegate>)observer {
    [NSNotificationCenter.defaultCenter
        removeObserver:observer name:CheckDidChangeStatus object:self];
    [NSNotificationCenter.defaultCenter
        removeObserver:observer name:CheckDidChangeChanging object:self];
    [NSNotificationCenter.defaultCenter
        removeObserver:observer name:CheckDidChangeRunning object:self];
}
@end


@implementation Check (Image)
+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status changing:(BOOL)changing {
    NSString *imageName = [self _statusImageNameForCheckStatus:status];
    if (changing) imageName = [imageName stringByAppendingString:@"-changing"];
    return imageName;
}

+ (NSString *)_statusImageNameForCheckStatus:(CheckStatus)status {
    switch (status) {
        case CheckStatusOk: return @"icon-ok";
        case CheckStatusFail: return @"icon-fail";
        case CheckStatusUndetermined: return @"icon-undetermined";
    }
}
@end


@implementation Check (Notification)
- (NSString *)statusNotificationText {
    switch (self.status) {
        case CheckStatusOk: return @"Now OK";
        case CheckStatusFail: return @"Now FAILED";
        case CheckStatusUndetermined: return @"Now ?";
    }
}
@end


@implementation Check (Debugging)
DelegateToLastRun(executedCommand, NSString *);
DelegateToLastRun(stdOut, NSString *);
DelegateToLastRun(stdErr, NSString *);
@end
