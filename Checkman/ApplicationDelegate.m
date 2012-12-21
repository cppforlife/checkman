#import "ApplicationDelegate.h"
#import "StatusMenuController.h"
#import "CheckfileCollection.h"
#import "CheckfileEntry.h"
#import "Checkfile.h"
#import "CheckCollection.h"
#import "Check.h"

@interface ApplicationDelegate ()
@property (nonatomic, strong) CheckfileCollection *checkfiles;
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) StatusMenuController *statusMenuController;
@end

@implementation ApplicationDelegate

@synthesize
    checkfiles = _checkfiles,
    checks = _checks,
    statusMenuController = _statusMenuController;

- (void)dealloc {
    self.checkfiles.delegate = nil;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.checks = [[CheckCollection alloc] init];
    self.statusMenuController = [[StatusMenuController alloc] initWithChecks:self.checks];
    [self performSelector:@selector(_loadCheckfiles) withObject:nil afterDelay:0];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.statusMenuController = nil;
    return NSTerminateNow;
}

#pragma mark -

- (void)_loadCheckfiles {
    self.checkfiles = [CheckfileCollection collectionFromHomeDirectoryPath];
    self.checkfiles.delegate = self;
    [self.checkfiles trackChanges];
}

#pragma mark - CheckfileCollectionDelegate

- (void)checkfileCollection:(CheckfileCollection *)collection didAddCheckfile:(Checkfile *)checkfile {
    NSUInteger index = [collection indexOfCheckfile:checkfile];
    [self.statusMenuController insertSectionWithTag:checkfile.tag atIndex:index];
    [self showExistingCheckfileEntries:checkfile];

    checkfile.delegate = self;
    [checkfile trackChanges];
}

- (void)checkfileCollection:(CheckfileCollection *)collection willRemoveCheckfile:(Checkfile *)checkfile {
    checkfile.delegate = nil;
    [self hideCheckfileEntries:checkfile];
    [self.statusMenuController removeSectionWithTag:checkfile.tag];
}

#pragma mark - CheckfileDelegate

- (void)checkfile:(Checkfile *)checkfile didAddEntry:(CheckfileEntry *)entry {
    [self showEntry:entry fromCheckfile:checkfile];
}

- (void)checkfile:(Checkfile *)checkfile willRemoveEntry:(CheckfileEntry *)entry {
    [self hideEntry:entry fromCheckfile:checkfile];
}

#pragma mark - Showing/Hiding entries from the status menu

- (void)showExistingCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self showEntry:entry fromCheckfile:checkfile];
    }
}

- (void)showEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    if ([entry isKindOfClass:[CheckfileCommandEntry class]]) {
        CheckfileCommandEntry *e = (CheckfileCommandEntry *)entry;

        Check *check = [[Check alloc] initWithName:e.name command:e.command directoryPath:checkfile.resolvedDirectoryPath];
        check.tag = entry.tag;
        [check start];

        [self.checks addCheck:check];
    }

    NSInteger index = [checkfile indexOfEntry:entry];
    [self.statusMenuController insertItemWithTag:entry.tag atIndex:index inSectionWithTag:checkfile.tag];
}

- (void)hideCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self hideEntry:entry fromCheckfile:checkfile];
    }
}

- (void)hideEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    [self.statusMenuController removeItemWithTag:entry.tag inSectionWithTag:checkfile.tag];

    if ([entry isKindOfClass:[CheckfileCommandEntry class]]) {
        Check *check = [self.checks checkWithTag:entry.tag];
        [check stop];

        [self.checks removeCheck:check];
    }
}

@end
