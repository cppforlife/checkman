#import "CheckRun.h"

@interface CheckRun ()
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSString *stdErr;
@property (nonatomic, strong) NSString *stdOut;

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
    stdErr = _stdErr,
    stdOut = _stdOut,
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

- (NSString *)executedCommand {
    return F(@"cd %@; %@ \"%@\"",
             self.task.currentDirectoryPath,
             self.task.launchPath,
             [self.task.arguments componentsJoinedByString:@" "]);
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
    NSData *output = nil, *error = nil;
    [self _getOutput:&output error:&error fromTask:self.task];

    NSDictionary *result = [self _parseJSONData:output];
    self.valid = (result != nil);
    self.stdOut = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    self.stdErr = [[NSString alloc] initWithData:error encoding:NSUTF8StringEncoding];

    self.resultValue = [result objectForKey:@"result"];
    self.changingValue = [result objectForKey:@"changing"];
    self.urlValue = [result objectForKey:@"url"];
    self.infoValue = [result objectForKey:@"info"];

    [(NSObject *)self.delegate
        performSelectorOnMainThread:@selector(checkRunDidFinish:)
        withObject:self
        waitUntilDone:NO];
}

- (void)_getOutput:(NSData **)output error:(NSData **)error fromTask:(NSTask *)task {
    NSPipe *outputPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;

    NSPipe *errorPipe = [NSPipe pipe];
    task.standardError = errorPipe;

#ifdef DEBUG
    // NSTask breaks Xcode's console when bash is executed (http://cocoadev.com/wiki/NSTask)
    task.standardInput = NSPipe.pipe;
#endif

    [task launch];
    [task waitUntilExit];

    *output = [outputPipe.fileHandleForReading readDataToEndOfFile];
    *error = [errorPipe.fileHandleForReading readDataToEndOfFile];
}

- (NSDictionary *)_parseJSONData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

#ifdef DEBUG
    if (error) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Command '%@' did not return valid json:\nError %@\n%@", self.command, error, string);
    } else {
        NSLog(@"Command '%@' finished.", self.command);
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
