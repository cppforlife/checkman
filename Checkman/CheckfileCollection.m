#import "CheckfileCollection.h"
#import "Checkfile.h"
#import "NSObject+Delayed.h"
#import "FSChangesNotifier.h"

@interface CheckfileCollection () <FSChangesNotifierDelegate>
@property (nonatomic, strong) NSString *directoryPath;
@property (nonatomic, strong) NSMutableArray *files;
@property (strong, nonatomic) FSChangesNotifier *fsChangesNotifier;
@end

@implementation CheckfileCollection
@synthesize
    delegate = _delegate,
    directoryPath = _directoryPath,
    files = _files,
    fsChangesNotifier = _fsChangesNotifier;

+ (CheckfileCollection *)collectionFromCheckmanUserDirectoryPath {
    NSString *directoryPath = [@"~/Checkman" stringByExpandingTildeInPath];
    [self _makeSureDirectoryPathExists:directoryPath];
    return [[self alloc] initWithDirectoryPath:directoryPath];
}

+ (void)_makeSureDirectoryPathExists:(NSString *)directoryPath {
    NSError *error = nil;
    [[NSFileManager defaultManager]
        createDirectoryAtPath:directoryPath
        withIntermediateDirectories:YES
        attributes:nil
        error:&error];

    if (error) {
        NSLog(@"CheckfileCollection - failed to create user directory: %@", error);
        @throw error;
    }
}

#pragma mark -

- (id)initWithDirectoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.directoryPath = directoryPath;
        self.fsChangesNotifier = [FSChangesNotifier sharedNotifier];
    }
    return self;
}

- (void)dealloc {
    [self.fsChangesNotifier stopNotifying:self];
}

- (NSString *)description {
    return F(@"<CheckfileCollection: %p> directoryPath=%@", self, self.directoryPath);
}

- (void)trackChanges {
    [self performSelectorOnNextTick:@selector(_startTrackingChanges)];
}

- (void)_startTrackingChanges {
    [self reloadFiles];
    [self.fsChangesNotifier startNotifying:self forFilePath:self.directoryPath];
}

- (NSUInteger)indexOfCheckfile:(Checkfile *)checkfile {
    return [self.files indexOfObject:checkfile];
}

- (void)reloadFiles {
    NSLog(@"CheckfileCollection - reloading: %@", self.directoryPath);
    for (Checkfile *checkfile in self.files) {
        [self.delegate checkfileCollection:self willRemoveCheckfile:checkfile];
    }

    self.files = self._loadFiles;
    for (Checkfile *checkfile in self.files) {
        [self.delegate checkfileCollection:self didAddCheckfile:checkfile];
    }
}

- (NSMutableArray *)_loadFiles {
    NSArray *filePaths = [self _filePathsAtDirectoryPath:self.directoryPath];
    NSMutableArray *files = [NSMutableArray array];

    for (NSString *filePath in filePaths) {
        [files addObject:[[Checkfile alloc] initWithFilePath:filePath fsChangesNotifier:self.fsChangesNotifier]];
    }
    return files;
}

- (NSArray *)_filePathsAtDirectoryPath:(NSString *)directoryPath {
    NSMutableArray *filePaths = [NSMutableArray array];

    NSString *fileName = nil;
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:directoryPath];

    while (fileName = [enumerator nextObject]) {
        if ([fileName characterAtIndex:0] == '.') continue;
        if ([fileName rangeOfString:@"/."].location != NSNotFound) continue;
        NSString *filePath = F(@"%@/%@", directoryPath, fileName);

        BOOL isDirectory = NO;
        [NSFileManager.defaultManager fileExistsAtPath:filePath isDirectory:&isDirectory];

        if (!isDirectory) [filePaths addObject:filePath];
    }
    return filePaths;
}

#pragma mark - FSChangesNotifierDelegate

- (void)fsChangesNotifier:(FSChangesNotifier *)notifier
        filePathDidChange:(NSString *)filePath {
    [self performSelectorOnMainThread:@selector(reloadFiles)
          withObject:nil waitUntilDone:NO]; // nuclear!
}
@end
