#import "Checkfile.h"
#import "CheckfileEntry.h"
#import "NSObject+Delayed.h"
#import "FSChangesNotifier.h"

@interface Checkfile () <FSChangesNotifierDelegate>
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *resolvedFilePath;

@property (strong, nonatomic) NSArray *entries;
@property (strong, nonatomic) FSChangesNotifier *fsChangesNotifier;
@end

@implementation Checkfile
@synthesize
    delegate = _delegate,
    filePath = _filePath,
    resolvedFilePath = _resolvedFilePath,
    entries = _entries,
    fsChangesNotifier = _fsChangesNotifier;

- (id)initWithFilePath:(NSString *)filePath
        fsChangesNotifier:(FSChangesNotifier *)fsChangesNotifier {
    if (self = [super init]) {
        self.filePath = filePath;
        self.resolvedFilePath = [filePath stringByResolvingSymlinksInPath];
        self.fsChangesNotifier = fsChangesNotifier;
    }
    return self;
}

- (void)dealloc {
    [self.fsChangesNotifier stopNotifying:self];
}

- (NSString *)description {
    return F(@"<Checkfile: %p> resolvedFilePath=%@ entries#=%ld",
             self, self.resolvedFilePath, self.entries.count);
}

- (NSString *)name {
    return [self.filePath lastPathComponent];
}

- (NSString *)resolvedDirectoryPath {
    return [self.resolvedFilePath stringByDeletingLastPathComponent];
}

- (void)trackChanges {
    [self performSelectorOnNextTick:@selector(_startTrackingChanges)];
}

- (void)_startTrackingChanges {
    [self _reloadEntries];
    [self.fsChangesNotifier startNotifying:self forFilePath:self.resolvedFilePath];
}

- (NSUInteger)indexOfEntry:(CheckfileEntry *)entry {
    return [self.entries indexOfObject:entry];
}

- (void)_reloadEntries {
    NSLog(@"Checkfile - reloading: %@", self.resolvedFilePath);
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
    NSString *fileContents =
        [NSString stringWithContentsOfFile:self.resolvedFilePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"Checkfile - error: %@", error);
        return nil;
    } else {
        NSLog(@"Checkfile - read: %@", self.resolvedFilePath);
    }

    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    NSMutableArray *entries = [[NSMutableArray alloc] init];

    CheckfileTitledSeparatorEntry *lastTitledSeparatorEntry = nil;

    for (NSString *line in lines) {
        CheckfileEntry *entry = [CheckfileEntry fromLine:line];
        if (entry) {
            if (entry.isTitledSeparatorEntry) {
                lastTitledSeparatorEntry = (id)entry;
            } else if (entry.isCommandEntry) {
                CheckfileCommandEntry *e = (id)entry;
                e.primaryContextName = self.name;
                e.secondaryContextName = lastTitledSeparatorEntry.title;
            }
            [entries addObject:entry];
        }
    }
    return entries;
}

#pragma mark - FSChangesNotifierDelegate

- (void)fsChangesNotifier:(FSChangesNotifier *)notifier
        filePathDidChange:(NSString *)filePath {
    [self performSelectorOnMainThread:@selector(_reloadEntries)
          withObject:nil waitUntilDone:NO]; // nuclear!
}
@end
