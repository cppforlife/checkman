#import "NSObject+Delayed.h"

@implementation NSObject (Delayed)
- (void)performSelectorOnNextTick:(SEL)selector {
    [self performSelectorOnNextTick:selector afterDelay:0];
}

- (void)performSelectorOnNextTick:(SEL)selector afterDelay:(NSTimeInterval)delay {
    NSArray *modes = [NSArray arrayWithObjects:NSRunLoopCommonModes, NSEventTrackingRunLoopMode, nil];
    [self performSelector:selector withObject:nil afterDelay:delay inModes:modes];
}

- (void)cancelPerformSelectorOnNextTick:(SEL)selector {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
}
@end
