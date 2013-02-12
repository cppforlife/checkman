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
@property (nonatomic, assign, getter = isAfterFirstRun) BOOL afterFirstRun;
@end

@implementation Check
@synthesize
    name = _name,
    command = _command,
    directoryPath = _directoryPath,
    primaryContextName = _primaryContextName,
    secondaryContextName = _secondaryContextName,
    runInterval = _runInterval,
    disabled = _disabled,
    lastRun = _lastRun,
    currentRun = _currentRun,
    afterFirstRun = _afterFirstRun;

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

        self.afterFirstRun = (_lastRun == nil);
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

#define ChangeField(field)                                                      \
    static NSString *CheckDidChange##field = @"CheckDidChange"#field;           \
    - (void)_didChange##field {                                                 \
        [(NSNotificationCenter *)NSNotificationCenter.defaultCenter             \
            postNotificationName:CheckDidChange##field object:self];            \
    }                                                                           \

ChangeField(Status)
ChangeField(Changing)
ChangeField(Running)
@end


@implementation Check (Observers)

#define AddObserver(field)                                                      \
    [(NSNotificationCenter *)NSNotificationCenter.defaultCenter                 \
        addObserver:observer selector:@selector(checkDidChange##field:)         \
        name:CheckDidChange##field object:self];                                \

- (void)addObserver:(id<CheckDelegate>)observer {
    AddObserver(Status)
    AddObserver(Changing)
    AddObserver(Running)
}

#define RemoveObserver(field)                                                   \
    [(NSNotificationCenter *)NSNotificationCenter.defaultCenter                 \
        removeObserver:observer name:CheckDidChange##field object:self];        \

- (void)removeObserver:(id<CheckDelegate>)observer {
    RemoveObserver(Status)
    RemoveObserver(Changing)
    RemoveObserver(Running)
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
- (NSString *)statusNotificationName {
    if (self.primaryContextName && self.secondaryContextName) {
        // Avoid having duplicate subtitles
        if (![self.primaryContextName isEqualToString:self.secondaryContextName]) {
            return F(@"%@ > %@ > %@", self.primaryContextName, self.secondaryContextName, self.name);
        }
    }
    // Primary name will most like be there
    if (self.primaryContextName) {
        return F(@"%@ > %@", self.primaryContextName, self.name);
    }
    return self.name;
}

- (NSString *)statusNotificationStatus {
    switch (self.status) {
        case CheckStatusOk: return @"ok";
        case CheckStatusFail: return @"failed";
        case CheckStatusUndetermined: return @"undetermined";
    }
}

- (NSString *)statusNotificationText {
    switch (self.status) {
        case CheckStatusOk: return @"OK";
        case CheckStatusFail: return @"FAILED";
        case CheckStatusUndetermined: return @"UNDETERMINED";
    }
}

- (NSColor *)statusNotificationColor {
    switch (self.status) {
        case CheckStatusOk: return [NSColor colorWithDeviceRed:58.0/255 green:130.0/255 blue:7.0/255 alpha:1];
        case CheckStatusFail: return [NSColor colorWithDeviceRed:202.0/255 green:26.0/255 blue:22.0/255 alpha:1];
        case CheckStatusUndetermined: return NSColor.darkGrayColor;
    }
}
@end


@implementation Check (Debugging)
DelegateToLastRun(executedCommand, NSString *);
DelegateToLastRun(stdOut, NSString *);
DelegateToLastRun(stdErr, NSString *);
@end
