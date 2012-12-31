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
@property (nonatomic, strong) Settings *settings;
@end

@implementation CheckManager

@synthesize
    checkfiles = _checkfiles,
    menuController = _menuController,
    settings = _settings;

- (id)initWithMenuController:(MenuController *)menuController settings:(Settings *)settings {
    if (self = [super init]) {
        self.menuController = menuController;
        self.settings = settings;
    }
    return self;
}

- (void)loadCheckfiles {
    self.checkfiles = [CheckfileCollection collectionFromCheckmanUserDirectoryPath];
    self.checkfiles.delegate = self;
    [self.checkfiles trackChanges];
}

- (void)reloadCheckfiles {
    NSAssert(self.checkfiles, @"Checkfiles must first be loaded");
    [self.checkfiles reloadFiles];
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
        [check startImmediately:YES];

        [self.menuController
            insertCheck:check
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
    else NSAssert(NO, @"Unknown entry type cannot be shown.");
}

- (Check *)_checkFromEntry:(CheckfileCommandEntry *)entry checkfile:(Checkfile *)checkfile {
    Check *check = [[Check alloc] initWithName:entry.name command:entry.command directoryPath:checkfile.resolvedDirectoryPath];
    check.tag = entry.tag;

    check.runInterval = [self.settings
        runIntervalForCheckWithName:check.name
        inCheckfileWithName:checkfile.name];
    check.disabled = [self.settings
        isCheckWithNameDisabled:check.name
        inCheckfileWithName:checkfile.name];

    return check;
}

#pragma mark - Hiding entries

- (void)_hideCheckfileEntries:(Checkfile *)checkfile {
    for (CheckfileEntry *entry in checkfile.entries) {
        [self _hideEntry:entry fromCheckfile:checkfile];
    }
}

- (void)_hideEntry:(CheckfileEntry *)entry fromCheckfile:(Checkfile *)checkfile {
    if (entry.isCommandEntry) {
        [[self.menuController checkWithTag:entry.tag] stop];
    }

    [self.menuController
        removeItemWithTag:entry.tag
        inSectionWithTag:checkfile.tag];
}
@end
