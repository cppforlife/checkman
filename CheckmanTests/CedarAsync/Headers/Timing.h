#import <Foundation/Foundation.h>
#include <chrono>

namespace CedarAsync {
    namespace Timing {
        extern NSTimeInterval default_poll, current_poll;
        extern NSTimeInterval default_timeout, current_timeout;
    }

    void with_timeout(NSTimeInterval, void(^)(void));
}

typedef enum {
    CDRATimingPollContinue = 99,
    CDRATimingPollStop = 98
} CDRATimingPoll;

@interface CDRATiming : NSObject
+ (void)pollRunLoop:(CDRATimingPoll(^)(BOOL))block
              every:(NSTimeInterval)poll
            timeout:(NSTimeInterval)timeout;
@end

@interface CDRAResetTimeout : NSObject
+ (void)beforeEach;
@end
