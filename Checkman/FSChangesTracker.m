#import "FSChangesTracker.h"
#import "FSChangesDispatchWatcher.h"

@interface FSChangesTracker () <FSChangesDispatchWatcherDelegate>
@property (nonatomic, strong) NSMutableDictionary *filePathObservers;
@property (nonatomic, strong) FSChangesDispatchWatcher *watcher;
@end

@implementation FSChangesTracker
@synthesize
    filePathObservers = _filePathObservers,
    watcher = _watcher;

- (id)init {
    if (self = [super init]) {
        self.filePathObservers = [NSMutableDictionary dictionary];
        self.watcher = [[FSChangesDispatchWatcher alloc] init];
        self.watcher.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.watcher.delegate = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - FSChangesTracker

- (void)startTrackingFilePath:(NSString *)filePath
         observer:(id<FSChangesObserver>)observer {
    [[self _observersForFilePath:filePath] addObject:observer];
    [self.watcher addPath:filePath];
}

- (void)stopTrackingFilePath:(NSString *)filePath
        observer:(id<FSChangesObserver>)observer {
    NSMutableArray *observers = [self _observersForFilePath:filePath];
    [observers removeObjectIdenticalTo:observer];
    if (observers.count == 0) {
        [self.watcher removePath:filePath];
    }
}

#pragma mark - FSChangesDispatchWatcherDelegate

- (void)fsChangesDispatchWatcher:(FSChangesDispatchWatcher *)watcher didNoticeChangeToPath:(NSString *)path {
    NSLog(@"FSChangesNotifier - didNoticeChangeToPath: %@", path);

    // Copy list of observers to avoid 'NSArray... was mutated while being enumerated'
    // since who knows what might happen in observer's handleChangeForFilePath:
    // (e.g. observer calls stopTrackingFilePath:observer:)
    NSArray *observers = [[self.filePathObservers objectForKey:path] copy];
    for (id<FSChangesObserver> observer in observers) {
        [observer handleChangeForFilePath:path tracker:self];
    }
}

#pragma mark -

- (NSMutableArray *)_observersForFilePath:(NSString *)filePath {
    NSMutableArray *observers = [self.filePathObservers objectForKey:filePath];
    if (!observers) {
        observers = [NSMutableArray arrayWithCapacity:1];
        [self.filePathObservers setObject:observers forKey:filePath];
    }
    return observers;
}
@end

