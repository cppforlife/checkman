#import "CheckCollection.h"

@interface StatusMenuController : NSObject <CheckCollectionDelegate>
- (id)initWithChecks:(CheckCollection *)checks;

- (void)insertSectionWithTag:(NSInteger)tag atIndex:(NSUInteger)index;
- (void)removeSectionWithTag:(NSInteger)tag;

- (void)insertItemWithTag:(NSInteger)tag atIndex:(NSUInteger)index inSectionWithTag:(NSInteger)sectionTag;
- (void)removeItemWithTag:(NSInteger)tag inSectionWithTag:(NSInteger)sectionTag;
@end
