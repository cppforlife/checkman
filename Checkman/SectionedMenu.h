#import <Cocoa/Cocoa.h>

@interface SectionedMenu : NSMenu

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index;
- (void)removeSectionWithTag:(NSInteger)tag;

#pragma mark - Section items

- (void)insertItem:(NSMenuItem *)item
           atIndex:(NSUInteger)index
  inSectionWithTag:(NSInteger)sectionTag;

- (NSMenuItem *)itemWithTag:(NSInteger)tag
           inSectionWithTag:(NSInteger)sectionTag;

- (void)removeItemWithTag:(NSInteger)tag
         inSectionWithTag:(NSInteger)sectionTag;
@end
