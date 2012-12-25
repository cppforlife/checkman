#import "SectionedMenu.h"
#import <objc/runtime.h>

@interface SectionedMenu_SectionMenuItem : NSMenuItem
+ (NSMenuItem *)sectionMenuItemWithTag:(NSInteger)tag;
@end

@interface NSMenuItem (SectionedMenu)
- (BOOL)sm_isSectionSeparator;
@end


@implementation SectionedMenu

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index {
    NSUInteger actualIndex = 0;
    for (NSMenuItem *item in self.itemArray) {
        if (item.sm_isSectionSeparator && index-- == 0) break;
        actualIndex++;
    }

    NSMenuItem *item = [SectionedMenu_SectionMenuItem sectionMenuItemWithTag:tag];
    [self insertItem:item atIndex:actualIndex];
}

- (void)removeSectionWithTag:(NSInteger)tag {
    NSUInteger index = [self _actualIndexOfSectionWithTag:tag];
    NSUInteger maxIndex = self.numberOfItems;
    [self removeItemAtIndex:index];

    // Delete items that belonged to section being removed
    for (maxIndex--; index < maxIndex; maxIndex--) {
        if ([[self itemAtIndex:index] sm_isSectionSeparator]) return;
        [self removeItemAtIndex:index];
    }
}

- (NSUInteger)_actualIndexOfSectionWithTag:(NSInteger)tag {
    return [self indexOfItemWithTag:tag];
}

#pragma mark - Section items

- (void)insertItem:(NSMenuItem *)item
           atIndex:(NSUInteger)index
  inSectionWithTag:(NSInteger)sectionTag {
    [self insertItem:item atIndex:[self _actualIndexOfSectionWithTag:sectionTag] + index + 1];
}

- (void)removeItemWithTag:(NSInteger)tag
         inSectionWithTag:(NSInteger)sectionTag {
    [self removeItemAtIndex:[self indexOfItemWithTag:tag]];
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
