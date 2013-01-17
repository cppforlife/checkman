#import "StickyPanel.h"
#import "StickyPanelView.h"
#import "Sticky.h"

@interface StickyPanel ()
@property (nonatomic, strong) Sticky *sticky;
@end

@implementation StickyPanel
@synthesize sticky = _sticky;

- (id)initWithSticky:(Sticky *)sticky {
    if (self = [super init]) {
        self.sticky = sticky;

        self.level = NSStatusWindowLevel;
        self.styleMask = NSBorderlessWindowMask | NSNonactivatingPanelMask;
        self.backgroundColor = NSColor.clearColor;
        self.alphaValue = 0.95;
        self.opaque = NO;

        StickyPanelView *view =
            [[StickyPanelView alloc] initWithSticky:sticky];
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

- (void)showOnRightScreenEdge:(NSPoint)origin {
    NSScreen *mainScreen = [NSScreen.screens objectAtIndex:0];
    [self setFrame:CGRectMake(
        mainScreen.frame.size.width - self.minSize.width - origin.x,
        origin.y,
        self.minSize.width,
        self.minSize.height
    ) display:NO];

    [self makeKeyAndOrderFront:nil];
    [self orderFrontRegardless];
}

- (void)moveDownBy:(CGFloat)distance {
    NSRect frame = self.frame;
    NSPoint origin = frame.origin;
    origin.y -= distance;
    frame.origin = origin;
    [self setFrame:frame display:YES animate:YES];
}

- (void)moveDownOffScreen {
    NSRect frame = self.frame;
    NSPoint origin = frame.origin;
    origin.y = -frame.size.height;
    frame.origin = origin;
    [self setFrame:frame display:YES animate:YES];
}
@end
