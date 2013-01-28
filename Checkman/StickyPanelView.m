#import "StickyPanelView.h"
#import "Sticky.h"

@interface StickyPanelView ()
@property (nonatomic, strong) Sticky *sticky;
@property (nonatomic, strong) NSTextView *statusText;
@end

@implementation StickyPanelView
@synthesize
    sticky = _sticky,
    statusText = _statusText;

- (id)initWithSticky:(Sticky *)sticky {
    if (self = [super init]) {
        self.sticky = sticky;
        self.frame = self.statusText.frame;
        [self addSubview:self.statusText];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSBezierPath *path =
        [NSBezierPath bezierPathWithRoundedRect:self.frame xRadius:10 yRadius:10];
    [self.sticky.color set];
    [path fill];
}

- (NSTextView *)statusText {
    if (!_statusText) {
        _statusText = self._buildTextView;
        _statusText.font = [NSFont systemFontOfSize:10];
        _statusText.string = F(@"%@ %@", self.sticky.name, self.sticky.status);
        _statusText.textContainerInset = NSMakeSize(5, 5);
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
