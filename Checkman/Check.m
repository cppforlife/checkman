#import "Check.h"

@interface Check ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic, assign) CheckStatus status;
@property (nonatomic, assign, getter = isRunning) BOOL running;
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *info;
@end

@implementation Check

@synthesize 
    name = _name,
    command = _command,
    directoryPath = _directoryPath,
    status = _status,
    running = _running,
    updatedAt = _updatedAt,
    url = _url,
    info = _info;

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status {
    switch (status) {
        case CheckStatusOk: return @"icon-ok";
        case CheckStatusFail: return @"icon-fail";
        case CheckStatusUndetermined: return @"icon-undetermined";
    }
}

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status running:(BOOL)running {
    NSString *imageName = [self statusImageNameForCheckStatus:status];
    if (running) imageName = [imageName stringByAppendingString:@"-running"];
    return imageName;
}

#pragma mark -

- (id)initWithName:(NSString *)name command:(NSString *)command directoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.name = name;
        self.command = command;
        self.directoryPath = directoryPath;

        self.status = CheckStatusUndetermined;
        self.running = NO;
    }
    return self;
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

- (void)setStatusValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        self.status = [value boolValue] ? CheckStatusOk : CheckStatusFail;
    } else {
        self.status = CheckStatusUndetermined;
    }
}

- (void)setRunningValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        self.running = [value boolValue];
    } else {
        self.running = NO;
    }
}

#pragma mark -

- (void)addObserverForStatusAndRunning:(id)observer {
    [self addObserver:observer forKeyPath:@"status" options:0 context:NULL];
    [self addObserver:observer forKeyPath:@"running" options:0 context:NULL];
}

- (void)removeObserverForStatusAndRunning:(id)observer {
    [self removeObserver:observer forKeyPath:@"status"];
    [self removeObserver:observer forKeyPath:@"running"];
}

#pragma mark - 

- (void)openUrl {
    [[NSWorkspace sharedWorkspace] openURL:self.url];
}

#pragma mark -

- (void)start {
    [self performSelectorInBackground:@selector(_startTask) withObject:nil];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)_scheduleRun {
    [self performSelector:@selector(start) withObject:self afterDelay:10 
                  inModes:[NSArray arrayWithObjects:NSRunLoopCommonModes, NSEventTrackingRunLoopMode, nil]];
}

- (void)_startTask {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.currentDirectoryPath = self.directoryPath;
    task.arguments = [NSArray arrayWithObjects:@"-lc", self._commandInDirectoryPath, nil];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardError:[NSPipe pipe]];
    [task setStandardInput:[NSPipe pipe]];
    [task launch];
    [task waitUntilExit];

    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *outputData = [file readDataToEndOfFile];

    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:outputData options:0 error:&error];

    if (error) {
        NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        NSLog(@"Command '%@' (%@) did not return valid json:\nError %@\n%@", self.name, self.command, error, output);
    } else {
        NSLog(@"Command '%@' ran.", self.name);
    }
    [self performSelectorOnMainThread:@selector(_finishTask:) withObject:result waitUntilDone:NO];
}

- (void)_finishTask:(NSDictionary *)result {
    @synchronized(self) {
        self.updatedAt = [NSDate date];

        if (result) {
            self.urlValue = [result objectForKey:@"url"];
            self.infoValue = [result objectForKey:@"info"];
            self.statusValue = [result objectForKey:@"result"];
            self.runningValue = [result objectForKey:@"running"];
        } else {
            self.url = nil;
            self.info = nil;
            self.status = CheckStatusUndetermined;
            self.running = NO;
        }
    }
    [self _scheduleRun];
}

#pragma mark -

- (NSString *)_commandInDirectoryPath {
    // Exposing bundleScripsPath in PATH env var allows
    // included checks to be used without specifying full path.
    return [NSString stringWithFormat:@"PATH=$PATH:%@ %@", self._bundleScriptsPath, self.command];
}

- (NSString *)_bundleScriptsPath {
    return [[NSBundle mainBundle] resourcePath];
}

@end
