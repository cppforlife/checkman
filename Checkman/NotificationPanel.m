#import "NotificationPanel.h"
#import "NotificationPanelView.h"
#import "CustomNotification.h"

@interface NotificationPanel ()
@property (nonatomic, strong) CustomNotification *notification;
@end

@implementation NotificationPanel
@synthesize notification = _notification;

- (id)initWithNotification:(CustomNotification *)notification {
    if (self = [super init]) {
        self.notification = notification;

        self.level = NSStatusWindowLevel;
        self.styleMask = NSBorderlessWindowMask | NSNonactivatingPanelMask;
        self.backgroundColor = NSColor.clearColor;
        self.alphaValue = 0.95;
        self.opaque = NO;

        NotificationPanelView *view =
            [[NotificationPanelView alloc] initWithNotification:notification];
        self.minSize = view.frame.size;
        self.contentView = view;
        [self useOptimizedDrawing:YES];

        self.excludedFromWindowsMenu = NO;
        self.hidesOnDeactivate = NO;
        self.oneShot = YES;
        self.canHide = NO;
    }
    return self;
}

- (void)show {
    [self setFrame:CGRectMake(0, 0, self.minSize.width, self.minSize.height) display:NO];
    [self center];
    [self makeKeyAndOrderFront:nil];
    [self orderFrontRegardless];
}
@end
