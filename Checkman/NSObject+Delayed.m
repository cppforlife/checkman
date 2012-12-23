#import "NSObject+Delayed.h"

@implementation NSObject (Delayed)
- (void)performSelectorOnNextTick:(SEL)selector {
    NSArray *modes = [NSArray arrayWithObjects:NSRunLoopCommonModes, NSEventTrackingRunLoopMode, nil];
    [self performSelector:selector withObject:nil afterDelay:0 inModes:modes];
}
@end
