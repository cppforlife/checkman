#import "CheckRun.h"
#import "AsyncTask.h"

@interface CheckRun () <AsyncTaskDelegate>
@property (nonatomic, strong) AsyncTask *task;
@property (nonatomic, assign, getter = isValid) BOOL valid;

@property (nonatomic, assign, getter = isSuccessful) BOOL successful;
@property (nonatomic, assign, getter = isChanging) BOOL changing;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *info;
@end

@implementation CheckRun
@synthesize
    delegate = _delegate,
    task = _task,
    valid = _valid,
    successful = _successful,
    changing = _changing,
    url = _url,
    info = _info;

- (id)initWithCommand:(NSString *)command
        directoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.task = [AsyncTask bashTaskWithCommand:command directoryPath:directoryPath];
        self.task.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.task.delegate = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (NSString *)description {
    return F(@"<CheckRun: %p> command='%@'", self, self.task.executedCommand);
}

#pragma mark -

- (void)start {
    [self.task run];
}

- (void)asyncTaskDidComplete:(AsyncTask *)task {
    NSDictionary *result = [self _parseJSONData:self.task.stdOutData];
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
        NSLog(@"CheckRun - invalid json: (%p)\nError: %@\n%@", self, error, string);
    } else {
        NSLog(@"CheckRun - finished: (%p)", self);
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
    return [[NSString alloc] initWithData:self.task.stdOutData encoding:NSUTF8StringEncoding];
}

- (NSString *)stdErr {
    return [[NSString alloc] initWithData:self.task.stdErrData encoding:NSUTF8StringEncoding];
}
@end
