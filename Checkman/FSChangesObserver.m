#import "FSChangesObserver.h"

@interface FSChangesObserver ()
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *containingFilePath;
@property (nonatomic, strong) NSDate *modificationDate;
@end

@implementation FSChangesObserver
@synthesize
    delegate = _delegate,
    filePath = _filePath,
    containingFilePath = _containingFilePath,
    modificationDate = _modificationDate;

- (id)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        self.filePath = filePath;
        self.containingFilePath = filePath.stringByDeletingLastPathComponent;
        self.modificationDate = self._currentModificationDate;
    }
    return self;
}

#pragma mark -

// Track directory changes because RubyMine (and others)
// could be doing atomic file saves - write tmp, remove, rename.
// more http://timnew.github.com/blog/2012/11/15/pitfall-in-fs-dot-watch/
- (void)startTracking:(id<FSChangesTracker>)tracker {
    [tracker startTrackingFilePath:self.filePath observer:self];
    [tracker startTrackingFilePath:self.containingFilePath observer:self];
}

- (void)stopTracking:(id<FSChangesTracker>)tracker {
    [tracker stopTrackingFilePath:self.filePath observer:self];
    [tracker stopTrackingFilePath:self.containingFilePath observer:self];
}

#pragma mark -

- (void)handleChangeForFilePath:(NSString *)filePath tracker:(id<FSChangesTracker>)tracker {
    NSDate *modificationDate = self._currentModificationDate;
    if (self.modificationDate == modificationDate) return;

    // start/stop tracking file path when it appears/disappears
    // (assumption is that containing file path stays there)
    if (!self.modificationDate && modificationDate)
        [tracker startTrackingFilePath:self.filePath observer:self];
    if (self.modificationDate && !modificationDate)
        [tracker stopTrackingFilePath:self.filePath observer:self];

    self.modificationDate = modificationDate;
    [self.delegate fsChangesObserverDidNoticeChange:self];
}

#pragma mark -

- (NSDate *)_currentModificationDate {
    return [[NSFileManager.defaultManager attributesOfItemAtPath:self.filePath error:nil] fileModificationDate];
}
@end
