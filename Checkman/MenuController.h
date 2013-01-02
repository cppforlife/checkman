#import <Foundation/Foundation.h>

@class Check, MenuController;

@protocol MenuControllerDelegate <NSObject>
- (void)menuController:(MenuController *)controller
    showDebugOutputForCheck:(Check *)check;
@end

@interface MenuController : NSObject

@property (nonatomic, assign) id<MenuControllerDelegate> delegate;

- (Check *)checkWithTag:(NSInteger)tag;

#pragma mark - Sections

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index;
- (void)removeSectionWithTag:(NSInteger)tag;

#pragma mark - Items

- (void)insertCheck:(Check *)check
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag;

- (void)insertSeparatorItemWithTag:(NSInteger)tag
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag;

- (void)insertTitledSeparatorItemWithTag:(NSInteger)tag
    title:(NSString *)title
    atIndex:(NSUInteger)index
    inSectionWithTag:(NSInteger)sectionTag;

- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag;
@end
