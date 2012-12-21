#import "FSChangesNotifier.h"
#import "VDKQueue.h"

@interface FSChangesNotifier ()
@property (nonatomic, strong) NSMutableDictionary *watchedFilePaths;
@property (nonatomic, strong) VDKQueue *watcher;
@end

@implementation FSChangesNotifier

@synthesize 
    watchedFilePaths = _watchedFilePaths,
    watcher = _watcher;

- (id)init {
    if (self = [super init]) {
        self.watchedFilePaths = [NSMutableDictionary dictionary];
        self.watcher = [[VDKQueue alloc] init];
        self.watcher.delegate = self;
    }
    return self;
}

#pragma mark -

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate forFilePath:(NSString *)filePath {
    [[self delegatesForFilePath:filePath] addObject:delegate];
    [self.watcher addPath:filePath];
}

- (void)stopNotifying:(id<FSChangesNotifierDelegate>)delegate {
    for (NSString *filePath in self.watchedFilePaths) {
        [[self delegatesForFilePath:filePath] removeObject:delegate];
    }
}

#pragma mark - VDKQueueDelegate

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)notificationName forPath:(NSString *)path {
    if (notificationName == VDKQueueWriteNotification) {
        NSLog(@"FSChangesNotifier - %@: %@", notificationName, path);
        for (id<FSChangesNotifierDelegate> delegate in [self.watchedFilePaths objectForKey:path]) {
            [delegate fsChangesNotifier:self filePathDidChange:path];
        }
    }
}

#pragma mark -

- (NSMutableArray *)delegatesForFilePath:(NSString *)filePath {
    NSMutableArray *delegates = [self.watchedFilePaths objectForKey:filePath];
    if (!delegates) {
        delegates = [self.class _mutableNonRetainingArrayWithCapacity:1];
        [self.watchedFilePaths setObject:delegates forKey:filePath];
    }
    return delegates;
}

+ (id)_mutableNonRetainingArrayWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (__bridge_transfer id)(CFArrayCreateMutable(0, capacity, &callbacks));
}
@end
