#import "CheckfileCollection.h"
#import "Checkfile.h"

@interface CheckfileCollection ()
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

+ (CheckfileCollection *)collectionFromHomeDirectoryPath {
    NSString *checkmanPath = [NSString stringWithFormat:@"%@/Checkman", NSHomeDirectory()];
    return [[self alloc] initWithDirectoryPath:checkmanPath];
}

- (id)initWithDirectoryPath:(NSString *)directoryPath {
    if (self = [super init]) {
        self.directoryPath = directoryPath;
        self.fsChangesNotifier = [[FSChangesNotifier alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self.fsChangesNotifier stopNotifying:self];
}

- (void)trackChanges {
    // avoid immediately populating files to avoid for potential delegate calls to finish
    [self performSelector:@selector(_startTrackingChanges) withObject:nil afterDelay:0 
                  inModes:[NSArray arrayWithObjects:NSRunLoopCommonModes, NSEventTrackingRunLoopMode, nil]];
}

- (void)_startTrackingChanges {
    [self _reloadFiles];
    [self.fsChangesNotifier startNotifying:self forFilePath:self.directoryPath];
}

- (NSUInteger)indexOfCheckfile:(Checkfile *)checkfile {
    return [self.files indexOfObject:checkfile];
}

- (void)_reloadFiles {
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
        if ([fileName isEqualToString:@".DS_Store"]) continue;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];

        BOOL isDirectory = NO;
        [NSFileManager.defaultManager fileExistsAtPath:filePath isDirectory:&isDirectory];

        if (!isDirectory) [filePaths addObject:filePath];
    }
    return filePaths;
}

#pragma mark - FSChangesNotifierDelegate

- (void)fsChangesNotifier:(FSChangesNotifier *)notifier filePathDidChange:(NSString *)filePath {
    [self _reloadFiles]; // nuclear!
}
@end
