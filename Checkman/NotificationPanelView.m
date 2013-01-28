#import "NotificationPanelView.h"
#import "CustomNotification.h"

@interface NotificationPanelView ()
@property (nonatomic, strong) CustomNotification *notification;
@property (nonatomic, strong) NSTextView *statusText;
@end

@implementation NotificationPanelView
@synthesize
    notification = _notification,
    statusText = _statusText;

- (id)initWithNotification:(CustomNotification *)notification {
    if (self = [super init]) {
        self.notification = notification;
        self.frame = self.statusText.frame;
        [self addSubview:self.statusText];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSBezierPath *path =
        [NSBezierPath bezierPathWithRoundedRect:self.frame xRadius:10 yRadius:10];
    [self.notification.color set];
    [path fill];
}

- (NSTextView *)statusText {
    if (!_statusText) {
        _statusText = self._buildTextView;
        _statusText.font = [NSFont systemFontOfSize:20];
        _statusText.string = F(@"%@ %@", self.notification.name, self.notification.status);
        _statusText.textContainerInset = NSMakeSize(10, 10);
        [self _sizeTextView:_statusText];
    }
    return _statusText;
}

- (NSTextView *)_buildTextView {
    NSTextView *view = [[NSTextView alloc] init];
    view.backgroundColor = NSColor.clearColor;
    view.selectable = NO;
    view.editable = NO;

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = NSColor.darkGrayColor;
    shadow.shadowOffset = CGSizeMake(1, 1);

    NSDictionary *typingAttrbutes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            shadow, NSShadowAttributeName,
            NSColor.whiteColor, NSForegroundColorAttributeName, nil];
    view.typingAttributes = typingAttrbutes;

    return view;
}

- (void)_sizeTextView:(NSTextView *)view {
    NSDictionary *attrbutes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            view.font, NSFontAttributeName, nil];

    CGSize size = [view.string sizeWithAttributes:attrbutes];
    CGSize inset = view.textContainerInset;

    // Needs weird extra 10px to keep text on a single line
    view.frame = CGRectMake(0, 0, size.width + 10 + inset.width*2, size.height + inset.height*2);
}
@end
