#import <Foundation/Foundation.h>

@interface NSObject (Delayed)
- (void)performSelectorOnNextTick:(SEL)selector;
@end
