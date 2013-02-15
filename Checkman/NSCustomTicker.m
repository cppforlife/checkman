#import "NSCustomTicker.h"

@interface NSCustomTickerTarget : NSObject
@property (nonatomic, assign) NSCustomTicker *ticker;
@end


@interface NSCustomTicker ()
@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, strong) NSCustomTickerTarget *target;
@end

@implementation NSCustomTicker
@synthesize
    delegate = _delegate,
    timer = _timer,
    target = _target;

- (id)initWithInterval:(NSTimeInterval)interval {
    if (self = [super init]) {
        // Need to creat an object to refer to self
        // since NSTimer retains the target and we want to
        // dealloc ourselves without first needing to invalidate.
        self.target = [[NSCustomTickerTarget alloc] init];
        self.target.ticker = self;

        self.timer =
            [NSTimer scheduledTimerWithTimeInterval:interval
                target:self.target selector:@selector(perform)
                userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc {
    self.target.ticker = nil;
    [self.timer invalidate];
}

- (void)perform {
    [self.delegate customTickerDidTick:self];
}
@end


@implementation NSCustomTickerTarget
@synthesize ticker = _ticker;

- (void)perform {
    [self.ticker perform];
}
@end
