#import "CheckCollection.h"

@class MenuController;

@protocol MenuControllerDelegate <NSObject>
- (void)menuController:(MenuController *)controller showDebugOutputForCheck:(Check *)check;
@end

@interface MenuController : NSObject <CheckCollectionDelegate>

@property (nonatomic, assign) id<MenuControllerDelegate> delegate;

- (id)initWithChecks:(CheckCollection *)checks;

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index;
- (void)removeSectionWithTag:(NSInteger)tag;

- (void)insertItemWithTag:(NSInteger)tag atIndex:(NSUInteger)index inSectionWithTag:(NSInteger)sectionTag;
- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag;
@end
