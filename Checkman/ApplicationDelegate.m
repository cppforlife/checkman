#import "ApplicationDelegate.h"
#import "MenuController.h"
#import "Settings.h"
#import "CheckfileCollection.h"
#import "CheckfileEntry.h"
#import "Checkfile.h"
#import "CheckCollection.h"
#import "Check.h"

@interface ApplicationDelegate ()
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) CheckfileCollection *checkfiles;
@property (nonatomic, strong) MenuController *menuController;
@end

@implementation ApplicationDelegate

@synthesize
    checks = _checks,
    checkfiles = _checkfiles,
    menuController = _menuController;

- (void)dealloc {
    self.checkfiles.delegate = nil;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.checks = [[CheckCollection alloc] init];
    self.menuController = [[MenuController alloc] initWithChecks:self.checks];
    [self performSelector:@selector(_loadCheckfiles) withObject:nil afterDelay:0];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.menuController = nil;
    return NSTerminateNow;
}

#pragma mark -

- (void)_loadCheckfiles {
    self.checkfiles = [CheckfileCollection collectionFromCheckmanUserDirectoryPath];
    self.checkfiles.delegate = self;
    [self.checkfiles trackChanges];
}

#pragma mark - CheckfileCollectionDelegate

- (void)checkfileCollection:(CheckfileCollection *)collection didAddCheckfile:(Checkfile *)checkfile {
    NSUInteger index = [collection indexOfCheckfile:checkfile];
    [self.menuController insertSectionWithTag:checkfile.tag atIndex:index];
    [self _showCheckfileEntries:checkfile];

    checkfile.delegate = self;
    [checkfile trackChanges];
}

- (void)checkfileCollection:(CheckfileCollection *)collection willRemoveCheckfile:(Checkfile *)checkfile {
    checkfile.delegate = nil;
    [self _hideCheckfileEntries:checkfile];
    [self.menuController removeSectionWithTag:checkfile.tag];
}

#pragma mark - CheckfileDelegate

- (void)checkfile:(Checkfile *)checkfile didAddEntry:(CheckfileEntry *)entry {
    [self _showEntry:entry fromCheckfile:checkfile];
}

- (void)checkfile:(Checkfile *)checkfile willRemoveEntry:(CheckfileEntry *)entry {
    [self _hideEntry:entry fromCheckfile:checkfile];
}

#pragma mark - Showing/Hiding entries from the status menu

- (void)_showCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self _showEntry:entry fromCheckfile:checkfile];
    }
}

- (void)_showEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    if (entry.isCommandEntry) {
        Check *check = [self _checkFromEntry:(id)entry checkfile:checkfile];
        [self.checks addCheck:check];
        [check startImmediately:YES];
    }

    [self.menuController
        insertItemWithTag:entry.tag
        atIndex:[checkfile indexOfEntry:entry]
        inSectionWithTag:checkfile.tag];
}

- (Check *)_checkFromEntry:(CheckfileCommandEntry *)entry checkfile:(Checkfile *)checkfile {
    Check *check = [[Check alloc] initWithName:entry.name command:entry.command directoryPath:checkfile.resolvedDirectoryPath];
    check.runInterval = Settings.userSettings.checkRunInterval;
    check.tag = entry.tag;
    return check;
}

- (void)_hideCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self _hideEntry:entry fromCheckfile:checkfile];
    }
}

- (void)_hideEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    [self.menuController
        removeItemWithTag:entry.tag
        inSectionWithTag:checkfile.tag];

    if (entry.isCommandEntry) {
        Check *check = [self.checks checkWithTag:entry.tag];
        [self.checks removeCheck:check];
        [check stop];
    }
}
@end
