#import "Checkfile.h"
#import "CheckfileEntry.h"
#import "NSObject+Delayed.h"

@interface Checkfile ()
@property (strong, nonatomic) NSString *resolvedFilePath;
@property (strong, nonatomic) NSArray *entries;
@property (strong, nonatomic) FSChangesNotifier *fsChangesNotifier;
@end

@implementation Checkfile

@synthesize
    delegate = _delegate,
    resolvedFilePath = _resolvedFilePath,
    entries = _entries,
    fsChangesNotifier = _fsChangesNotifier;

- (id)initWithFilePath:(NSString *)filePath fsChangesNotifier:(FSChangesNotifier *)fsChangesNotifier {
    if (self = [super init]) {
        self.resolvedFilePath = [filePath stringByResolvingSymlinksInPath];
        self.fsChangesNotifier = fsChangesNotifier;        
    }
    return self;
}

- (void)dealloc {
    [self.fsChangesNotifier stopNotifying:self];
}

- (NSString *)description {
    return F(@"<Checkfile: %p> resolvedFilePath=%@ entries#=%d", self, self.resolvedFilePath, self.entries.count);
}

- (NSString *)resolvedDirectoryPath {
    return [self.resolvedFilePath stringByDeletingLastPathComponent];
}

- (void)trackChanges {
    [self performSelectorOnNextTick:@selector(_startTrackingChanges)];
}

- (void)_startTrackingChanges {
    [self _reloadEntries];

    // Track directory changes because RubyMine is doing atomic file saves (write tmp, remove, rename)
    // more http://timnew.github.com/blog/2012/11/15/pitfall-in-fs-dot-watch/
    [self.fsChangesNotifier startNotifying:self forFilePath:self.resolvedDirectoryPath];
    [self.fsChangesNotifier startNotifying:self forFilePath:self.resolvedFilePath];
}

- (NSUInteger)indexOfEntry:(CheckfileEntry *)entry {
    return [self.entries indexOfObject:entry];
}

- (void)_reloadEntries {
    for (CheckfileEntry *entry in self.entries) {
        [self.delegate checkfile:self willRemoveEntry:entry];
    }
    self.entries = self._loadEntries;
    for (CheckfileEntry *entry in self.entries) {
        [self.delegate checkfile:self didAddEntry:entry];
    }
}

- (NSArray *)_loadEntries {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:self.resolvedFilePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"Checkfile - error: %@", error);
        return nil;
    } else {
        NSLog(@"Checkfile - read: %@", self.resolvedFilePath);
    }

    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    NSMutableArray *entries = [[NSMutableArray alloc] init];

    for (NSString *line in lines) {
        CheckfileEntry *entry = [CheckfileEntry fromLine:line];
        if (entry) [entries addObject:entry];
    }
    return entries;
}

#pragma mark - FSChangesNotifierDelegate

- (void)fsChangesNotifier:(FSChangesNotifier *)notifier filePathDidChange:(NSString *)filePath {
    [self performSelectorOnNextTick:@selector(_reloadEntries)]; // nuclear!
}
@end
