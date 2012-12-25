#import "MenuController.h"
#import <objc/runtime.h>
#import "Check.h"
#import "CheckCollection.h"
#import "CheckMenuItem.h"
#import "SectionedMenu.h"

@interface MenuController ()
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) SectionedMenu *menu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation MenuController

@synthesize
    checks = _checks,
    menu = _menu,
    statusItem = _statusItem;

- (id)initWithChecks:(CheckCollection *)checks {
    if (self = [super init]) {
        self.checks = checks;
        self.checks.delegate = self;

        // Install status item into the menu bar
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.highlightMode = YES;
        [self _updateStatusAndChanging];

        self.menu = [[SectionedMenu alloc] initWithTitle:@"Checks"];
        self.menu.autoenablesItems = NO;
        self.statusItem.menu = self.menu;
    }
    return self;
}

- (void)dealloc {
    self.checks.delegate = nil;
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index {
    [self.menu insertSectionWithTag:tag atIndex:index];
}

- (void)removeSectionWithTag:(NSInteger)tag {
    [self.menu removeSectionWithTag:tag];
}

#pragma mark - Section items

- (void)insertItemWithTag:(NSInteger)tag atIndex:(NSUInteger)index inSectionWithTag:(NSInteger)sectionTag {
    Check *check = [self.checks checkWithTag:tag];

    NSMenuItem *item = NSMenuItem.separatorItem;
    if (check) item = [[CheckMenuItem alloc] initWithCheck:check];
    item.tag = tag;

    [self.menu insertItem:item atIndex:index inSectionWithTag:sectionTag];
}

- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag {
    [self.menu removeItemWithTag:tag inSectionWithTag:sectionTag];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollectionStatusAndChangingDidChange:(CheckCollection *)collection {
    [self _updateStatusAndChanging];
}

- (void)_updateStatusAndChanging {
    NSString *statusImageName = [Check statusImageNameForCheckStatus:self.checks.status changing:self.checks.isChanging];
    self.statusItem.image = [NSImage imageNamed:statusImageName];
    self.statusItem.title = self.checks.statusDescription;
}
@end
