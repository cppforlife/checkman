#import <Cocoa/Cocoa.h>
#import "NSWindow+KeepOpen.h"

@class Check;

@interface CheckDebuggingWindow : NSWindow
- (id)initWithCheck:(Check *)check;
- (void)show;
@end
