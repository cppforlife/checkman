#import "CheckDebuggingWindow.h"
#import "CheckDebuggingView.h"
#import "Check.h"

@interface CheckDebuggingWindow ()
@property (nonatomic, strong) Check *check;
@end

@implementation CheckDebuggingWindow
@synthesize check = _check;

- (id)initWithCheck:(Check *)check {
    if (self = [super init]) {
        self.check = check;
        self.contentView = [[CheckDebuggingView alloc] initWithCheck:check];

        self.title = check.name;
        self.styleMask =
            NSBorderlessWindowMask | NSTitledWindowMask |
            NSClosableWindowMask | NSResizableWindowMask;
    }
    return self;
}

- (void)show {
    [self setFrame:NSMakeRect(0, 0, 400, 500) display:NO];
    [self center];
    [self makeKeyAndOrderFront:nil];
    [self orderFrontRegardless];
}
@end
