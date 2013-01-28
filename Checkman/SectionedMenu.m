#import "SectionedMenu.h"
#import <objc/runtime.h>

@interface SectionedMenu_SectionMenuItem : NSMenuItem
+ (NSMenuItem *)sectionMenuItemWithTag:(NSInteger)tag;
@end

@interface NSMenuItem (SectionedMenu)
- (BOOL)sm_isSectionSeparator;
@end


@interface SectionedMenu ()
@property (nonatomic, strong) NSMenuItem *hiddenSectionItem;
@end

@implementation SectionedMenu
@synthesize hiddenSectionItem = _hiddenSectionItem;

- (id)initWithTitle:(NSString *)title {
    if (self = [super initWithTitle:title]) {
        [(NSNotificationCenter *)NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(_didChangeItems:)
            name:NSMenuDidAddItemNotification
            object:self];

        [(NSNotificationCenter *)NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(_didChangeItems:)
            name:NSMenuDidRemoveItemNotification
            object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index {
    NSInteger actualIndex = 0;
    for (NSMenuItem *item in self.itemArray) {
        if (item.sm_isSectionSeparator && index-- == 0) break;
        actualIndex++;
    }

    NSMenuItem *item = [SectionedMenu_SectionMenuItem sectionMenuItemWithTag:tag];
    [self insertItem:item atIndex:actualIndex];
}

- (void)removeSectionWithTag:(NSInteger)tag {
    NSInteger index = [self _actualIndexOfSectionWithTag:tag];
    NSInteger maxIndex = self.numberOfItems;
    [self removeItemAtIndex:index];

    // Delete items that belonged to section being removed
    for (maxIndex--; index < maxIndex; maxIndex--) {
        if ([[self itemAtIndex:index] sm_isSectionSeparator]) return;
        [self removeItemAtIndex:index];
    }
}

- (NSInteger)_actualIndexOfSectionWithTag:(NSInteger)tag {
    return [self indexOfItemWithTag:tag];
}

#pragma mark - Section items

- (void)insertItem:(NSMenuItem *)item
           atIndex:(NSUInteger)index
  inSectionWithTag:(NSInteger)sectionTag {
    [self insertItem:item atIndex:[self _actualIndexOfSectionWithTag:sectionTag] + (NSInteger)index + 1];
}

- (NSMenuItem *)itemWithTag:(NSInteger)tag
           inSectionWithTag:(NSInteger)sectionTag {
    return [self itemWithTag:tag];
}

- (void)removeItemWithTag:(NSInteger)tag
         inSectionWithTag:(NSInteger)sectionTag {
    [self removeItemAtIndex:[self indexOfItemWithTag:tag]];
}

#pragma mark -

- (void)_didChangeItems:(NSNotification *)notification {
    if (self.numberOfItems == 0) {
        self.hiddenSectionItem = nil;
        return;
    }

    NSMenuItem *firstItem = [self itemAtIndex:0];
    if (firstItem != self.hiddenSectionItem) {
        self.hiddenSectionItem.hidden = NO;
        if (firstItem.sm_isSectionSeparator) {
            firstItem.hidden = YES;
            self.hiddenSectionItem = firstItem;
        }
    }
}
@end


@implementation SectionedMenu_SectionMenuItem
+ (NSMenuItem *)sectionMenuItemWithTag:(NSInteger)tag {
    NSMenuItem *item = NSMenuItem.separatorItem;
    object_setClass(item, [SectionedMenu_SectionMenuItem class]);
    item.tag = tag;
    return item;
}
@end


@implementation NSMenuItem (SectionedMenu)
- (BOOL)sm_isSectionSeparator {
    return [self isKindOfClass:[SectionedMenu_SectionMenuItem class]];
}
@end
