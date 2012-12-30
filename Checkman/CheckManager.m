#import "CheckManager.h"
#import "MenuController.h"
#import "Settings.h"
#import "CheckfileCollection.h"
#import "Checkfile.h"
#import "CheckfileEntry.h"
#import "CheckCollection.h"
#import "Check.h"

@interface CheckManager () <CheckfileCollectionDelegate, CheckfileDelegate>
@property (nonatomic, strong) CheckfileCollection *checkfiles;
@property (nonatomic, strong) MenuController *menuController;
@end

@implementation CheckManager

@synthesize
    checkfiles = _checkfiles,
    menuController = _menuController;

- (id)initWithMenuController:(MenuController *)menuController {
    if (self = [super init]) {
        self.menuController = menuController;
    }
    return self;
}

- (void)dealloc {
    self.checkfiles.delegate = nil;
}

- (void)loadCheckfiles {
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

#pragma mark - Showing entries

- (void)_showCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self _showEntry:entry fromCheckfile:checkfile];
    }
}

- (void)_showEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    NSUInteger entryIndex = [checkfile indexOfEntry:entry];

    if (entry.isCommandEntry) {
        Check *check = [self _checkFromEntry:(id)entry checkfile:checkfile];
        [self.menuController.checks addCheck:check];
        [check startImmediately:YES];

        [self.menuController
            insertItemWithTag:entry.tag
            atIndex:entryIndex
            inSectionWithTag:checkfile.tag];
    }
    else if (entry.isSeparatorEntry) {
        [self.menuController
            insertSeparatorItemWithTag:entry.tag
            atIndex:entryIndex
            inSectionWithTag:checkfile.tag];
    }
    else if (entry.isTitledSeparatorEntry) {
        [self.menuController
            insertTitledSeparatorItemWithTag:entry.tag
            title:[(CheckfileTitledSeparatorEntry *)entry title]
            atIndex:entryIndex
            inSectionWithTag:checkfile.tag];
    }
}

- (Check *)_checkFromEntry:(CheckfileCommandEntry *)entry checkfile:(Checkfile *)checkfile {
    Check *check = [[Check alloc] initWithName:entry.name command:entry.command directoryPath:checkfile.resolvedDirectoryPath];
    check.runInterval = Settings.userSettings.checkRunInterval;
    check.tag = entry.tag;
    return check;
}

#pragma mark - Hiding entries

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
        Check *check = [self.menuController.checks checkWithTag:entry.tag];
        [self.menuController.checks removeCheck:check];
        [check stop];
    }
}
@end
