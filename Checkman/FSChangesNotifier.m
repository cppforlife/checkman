#import "FSChangesNotifier.h"
#import "VDKQueue.h"

@interface FSChangesNotifier () <VDKQueueDelegate>
@property (nonatomic, strong) NSMutableDictionary *watchedFilePaths;
@property (nonatomic, strong) VDKQueue *watcher;
@end

@implementation FSChangesNotifier

@synthesize 
    watchedFilePaths = _watchedFilePaths,
    watcher = _watcher;

+ (FSChangesNotifier *)sharedNotifier {
    static FSChangesNotifier *notifier = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        notifier = [FSChangesNotifier alloc];
        notifier = [notifier init];
    });
    return notifier;
}

- (id)init {
    if (self = [super init]) {
        self.watchedFilePaths = [NSMutableDictionary dictionary];
        self.watcher = [[VDKQueue alloc] init];
        self.watcher.delegate = self;
    }
    return self;
}

#pragma mark -

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
    forFilePathInDirectory:(NSString *)filePath {

    [self startNotifying:delegate forFilePath:filePath];
    [self startNotifying:delegate forFilePath:filePath.stringByDeletingLastPathComponent];
}

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
    forFilePath:(NSString *)filePath {

    [[self _delegatesForFilePath:filePath] addObject:delegate];
    [self.watcher addPath:filePath];
}

- (void)stopNotifying:(id<FSChangesNotifierDelegate>)delegate {
    for (NSString *filePath in self.watchedFilePaths) {
        [[self _delegatesForFilePath:filePath] removeObject:delegate];

        if ([self _delegatesForFilePath:filePath].count == 0) {
            [self.watcher removePath:filePath];
        }
    }
}

#pragma mark - VDKQueueDelegate

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)notificationName forPath:(NSString *)path {
    if (notificationName == VDKQueueWriteNotification) {
        NSLog(@"FSChangesNotifier - %@: %@", notificationName, path);
        NSArray *delegates = [self.watchedFilePaths objectForKey:path];
        for (id<FSChangesNotifierDelegate> delegate in delegates) {
            [delegate fsChangesNotifier:self filePathDidChange:path];
        }
    } else {
        NSLog(@"FSChangesNotifier - %@: %@", notificationName, path);
    }
}

#pragma mark -

- (NSMutableArray *)_delegatesForFilePath:(NSString *)filePath {
    NSMutableArray *delegates = [self.watchedFilePaths objectForKey:filePath];
    if (!delegates) {
        delegates = [self.class _mutableNonRetainingArrayWithCapacity:1];
        [self.watchedFilePaths setObject:delegates forKey:filePath];
    }
    return delegates;
}

+ (id)_mutableNonRetainingArrayWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (__bridge_transfer id)(CFArrayCreateMutable(0, (CFIndex)capacity, &callbacks));
}
@end
