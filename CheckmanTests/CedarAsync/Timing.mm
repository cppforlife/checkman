#import "Timing.h"

namespace CedarAsync {
    namespace Timing {
        NSTimeInterval default_poll = 0.1;
        NSTimeInterval current_poll = default_poll;

        NSTimeInterval default_timeout = 1;
        NSTimeInterval current_timeout = default_timeout;
    }

    void with_timeout(NSTimeInterval timeout, void(^block)(void)) {
        NSTimeInterval before = Timing::current_timeout;
        Timing::current_timeout = timeout;
        block();
        Timing::current_timeout = before;
    }
}

@implementation CDRATiming
+ (void)pollRunLoop:(CDRATimingPoll(^)(BOOL))block
              every:(NSTimeInterval)poll
            timeout:(NSTimeInterval)timeout {

    NSAssert(poll > 0, @"Poll must be > 0");

    while (block(timeout <= 0) == CDRATimingPollContinue) {
        NSTimeInterval step = MIN(timeout, poll);
        timeout -= step;

        NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:step];
        [[NSRunLoop currentRunLoop] runUntilDate:futureDate];
    }
}
@end

@implementation CDRAResetTimeout
+ (void)beforeEach {
    using namespace CedarAsync::Timing;
    current_poll = default_poll;
    current_timeout = default_timeout;
}
@end
