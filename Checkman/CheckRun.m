#import "CheckRun.h"

@interface CheckRun ()
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic, assign, getter = isValid) BOOL valid;
@property (nonatomic, assign, getter = isSuccessful) BOOL successful;
@property (nonatomic, assign, getter = isChanging) BOOL changing;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *info;
@end

@implementation CheckRun

@synthesize
    command = _command,
    directoryPath = _directoryPath,
    delegate = _delegate,
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

- (void)start {
    [self performSelectorInBackground:@selector(_runTask) withObject:nil];
}

- (void)_runTask {
    NSData *output = [self _getOutputByRunningTask:self._task];
    NSDictionary *result = [self _parseJSONData:output];

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

- (NSTask *)_task {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.currentDirectoryPath = self.directoryPath;
    task.arguments = [NSArray arrayWithObjects:@"-lc", self._commandInDirectoryPath, nil];
    return task;
}

- (NSData *)_getOutputByRunningTask:(NSTask *)task {
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardError:[NSPipe pipe]];
    [task setStandardInput:[NSPipe pipe]];

    [task launch];
    [task waitUntilExit];

    return [pipe.fileHandleForReading readDataToEndOfFile];
}

- (NSDictionary *)_parseJSONData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Command '%@' did not return valid json:\nError %@\n%@", self.command, error, string);
    }
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
