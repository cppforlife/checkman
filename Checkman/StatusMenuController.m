#import "StatusMenuController.h"
#import <objc/runtime.h>
#import "Check.h"
#import "CheckCollection.h"
#import "CheckMenuItem.h"

@interface StatusMenuController_SectionMenuItem : NSMenuItem
+ (NSMenuItem *)sectionMenuItemWithTag:(NSInteger)tag;
@end


@interface StatusMenuController ()
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) NSMenu *menu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation StatusMenuController

@synthesize 
    menu = _menu,
    checks = _checks,
    statusItem = _statusItem;

- (id)initWithChecks:(CheckCollection *)checks {
    if (self = [super init]) {
        self.checks = checks;
        self.checks.delegate = self;

        // Install status item into the menu bar
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.highlightMode = YES;
        [self _updateStatusAndChanging];

        self.menu = [[NSMenu alloc] initWithTitle:@"Checks"];
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
    NSUInteger actualIndex = 0;

    for (NSMenuItem *item in self.menu.itemArray) {
        if ([item isKindOfClass:[StatusMenuController_SectionMenuItem class]]) {
            if (index-- == 0) break;
        }
        actualIndex++;
    }

    NSMenuItem *sectionItem = [StatusMenuController_SectionMenuItem sectionMenuItemWithTag:tag];
    [self.menu insertItem:sectionItem atIndex:actualIndex];
}

- (void)removeSectionWithTag:(NSInteger)tag {
    [self.menu removeItemAtIndex:[self indexOfSectionWithTag:tag]];
}

- (NSUInteger)indexOfSectionWithTag:(NSInteger)tag {
    return [self.menu indexOfItemWithTag:tag];
}

#pragma mark - Items in sections

- (void)insertItemWithTag:(NSInteger)tag atIndex:(NSUInteger)index inSectionWithTag:(NSInteger)sectionTag {
    Check *check = [self.checks checkWithTag:tag];

    NSMenuItem *menuItem = 
        check ? [[CheckMenuItem alloc] initWithCheck:check] : NSMenuItem.separatorItem;
    menuItem.tag = tag;

    NSUInteger sectionIndex = [self indexOfSectionWithTag:sectionTag];
    [self.menu insertItem:menuItem atIndex:sectionIndex + index + 1];
}

- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag {
    [self.menu removeItemAtIndex:[self.menu indexOfItemWithTag:tag]];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollection:(CheckCollection *)collection didAddCheck:(Check *)check {}
- (void)checkCollection:(CheckCollection *)collection willRemoveCheck:(Check *)check {}

- (void)checkCollectionStatusAndChangingDidChange:(CheckCollection *)collection {
    [self _updateStatusAndChanging];
}

- (void)_updateStatusAndChanging {
    NSString *statusImageName = [Check statusImageNameForCheckStatus:self.checks.status changing:self.checks.isChanging];
    self.statusItem.image = [NSImage imageNamed:statusImageName];
    self.statusItem.title = self.checks.statusDescription;
}
@end


@implementation StatusMenuController_SectionMenuItem
+ (NSMenuItem *)sectionMenuItemWithTag:(NSInteger)tag {
    NSMenuItem *item = NSMenuItem.separatorItem;
    item.tag = tag;

    // differentiate plain separators from section separators
    object_setClass(item, [StatusMenuController_SectionMenuItem class]);
    return item;
}
@end
