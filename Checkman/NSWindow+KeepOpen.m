#import "NSWindow+KeepOpen.h"

@implementation NSWindow (KeepOpen)
- (void)keepOpenUntilClosed {
    self.releasedWhenClosed = YES;
    [self retain];
}
@end
