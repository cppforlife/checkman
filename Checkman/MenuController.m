#import "MenuController.h"
#import "ApplicationDelegate.h"
#import "SectionedMenu.h"
#import "CheckMenuItem.h"
#import "SeparatorMenuItem.h"
#import "CheckCollection.h"
#import "Check.h"

@interface MenuController () <CheckCollectionDelegate, CheckMenuItemDelegate>
@property (nonatomic, strong) NSString *gitSha;
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) SectionedMenu *menu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation MenuController
@synthesize
    delegate = _delegate,
    gitSha = _gitSha,
    checks = _checks,
    menu = _menu,
    statusItem = _statusItem;

- (id)initWithGitSha:(NSString *)gitSha {
    if (self = [super init]) {
        self.gitSha = gitSha;

        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;

        // Install status item into the menu bar
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.highlightMode = YES;
        [self _updateStatusAndChanging];

        self.menu = [[SectionedMenu alloc] initWithTitle:@"Checks"];
        self.menu.autoenablesItems = NO;
        self.statusItem.menu = self.menu;

        [self _addMiscMenuSection];
    }
    return self;
}

- (void)dealloc {
    self.checks.delegate = nil;
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

- (Check *)checkWithTag:(NSInteger)tag {
    return [self.checks checkWithTag:tag];
}

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index {
    [self.menu insertSectionWithTag:tag atIndex:index];
}

- (void)removeSectionWithTag:(NSInteger)tag {
    [self.menu removeSectionWithTag:tag];
}

#pragma mark - Section items

- (void)insertCheck:(Check *)check
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag {

    CheckMenuItem *item = [[CheckMenuItem alloc] initWithCheck:check];
    item.delegate = self;
    item.tag = check.tag;

    [self.checks addCheck:check];
    [self.menu insertItem:item atIndex:index inSectionWithTag:sectionTag];
}

- (void)insertSeparatorItemWithTag:(NSInteger)tag
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag {

    SeparatorMenuItem *item = SeparatorMenuItem.separator;
    item.tag = tag;
    [self.menu insertItem:item atIndex:index inSectionWithTag:sectionTag];
}

- (void)insertTitledSeparatorItemWithTag:(NSInteger)tag
    title:(NSString *)title
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag {

    SeparatorMenuItem *item = [SeparatorMenuItem separatorWithTitle:title];
    item.tag = tag;
    [self.menu insertItem:item atIndex:index inSectionWithTag:sectionTag];
}

- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag {
    NSMenuItem *item = [self.menu itemWithTag:tag inSectionWithTag:sectionTag];
    if ([item isKindOfClass:[CheckMenuItem class]]) {
        [self.checks removeCheck:[(CheckMenuItem *)item check]];
    }

    [self.menu removeItemWithTag:tag inSectionWithTag:sectionTag];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollection:(CheckCollection *)collection
        didUpdateStatusFromCheck:(Check *)check {
    [self _updateStatusAndChanging];
}

- (void)checkCollection:(CheckCollection *)collection
        didUpdateChangingFromCheck:(Check *)check {
    [self _updateStatusAndChanging];
}

- (void)_updateStatusAndChanging {
    NSString *statusImageName =
        [Check statusImageNameForCheckStatus:self.checks.status changing:self.checks.isChanging];
    self.statusItem.image = [NSImage imageNamed:statusImageName];
    self.statusItem.title = self.checks.statusDescription;
    self.statusItem.toolTip = self.checks.extendedStatusDescription;
}

#pragma mark - CheckMenuItemDelegate

- (void)checkMenuItemWasClicked:(CheckMenuItem *)item {
    NSUInteger pressedKeys = [NSApp currentEvent].modifierFlags;
    [self.delegate menuController:self didActOnCheck:item.check flags:pressedKeys];
}

#pragma mark - Quit menu item

- (void)_addMiscMenuSection {
    [self.menu insertSectionWithTag:-1 atIndex:0];
    [self.menu insertItem:self._quitMenuItem atIndex:0 inSectionWithTag:-1];
}

- (NSMenuItem *)_quitMenuItem {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = F(@"Quit Checkman (v. %@)", self.gitSha);
    item.target = [NSApplication sharedApplication];
    item.action = @selector(terminate:);
    return item;
}
@end
