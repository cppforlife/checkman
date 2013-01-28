#import "StickiesController.h"
#import "StickyPanel.h"
#import "Sticky.h"
#import "CheckCollection.h"
#import "Check.h"

@interface StickiesController () <CheckCollectionDelegate>
@property (nonatomic, strong) CheckCollection *checks;
@property (nonatomic, strong) NSMutableArray *stickies;
@end

@implementation StickiesController
@synthesize
    allow = _allow,
    checks = _checks,
    stickies = _stickies;

- (id)init {
    if (self = [super init]) {
        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;
        self.stickies = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    self.checks.delegate = nil;
}

- (void)setAllow:(BOOL)allow {
    if ((_allow = allow)) {
        for (Check *check in self.checks) {
            [self _showStickyForCheck:check];
        }
    } else {
        [self _hideAllStickies];
    }
}

- (void)addCheck:(Check *)check {
    [self.checks addCheck:check];
    [self _showStickyForCheck:check];
}

- (void)removeCheck:(Check *)check {
    [self.checks removeCheck:check];
    [self _hideStickyForCheck:check];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollection:(CheckCollection *)collection
    didUpdateStatusFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
    didUpdateChangingFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
        checkDidChangeStatus:(Check *)check {
    [self _hideStickyForCheck:check];
    [self _showStickyForCheck:check];
}

#pragma mark - Showing/hiding checks

- (void)_showStickyForCheck:(Check *)check {
    if (!self.isAllowed) return;
    if (check.isDisabled) return;

    if (check.status == CheckStatusFail ||
        check.status == CheckStatusUndetermined) {

        Sticky *sticky = [[Sticky alloc] init];
        sticky.name = check.statusNotificationName;
        sticky.status = check.statusNotificationText;
        sticky.color = check.statusNotificationColor;
        sticky.tag = check.tag;
        [self _showSticky:sticky];
    }
}

- (void)_hideStickyForCheck:(Check *)check {
    [self _hideStickyWithTag:check.tag];
}

#pragma mark - Showing/hiding stickies

- (void)_showSticky:(Sticky *)sticky {
    StickyPanel *panel = [[StickyPanel alloc] initWithSticky:sticky];
    NSPoint origin = [self _originForNextPanelAbovePanel:self.stickies.lastObject];
    [self.stickies addObject:panel];
    [panel showOnRightScreenEdge:origin];
}

- (void)_hideStickyWithTag:(NSInteger)tag {
    [self _hideStickyPanel:[self _stickyPanelWithStickyWithTag:tag]];
}

- (void)_hideAllStickies {
    for (StickyPanel *panel in self.stickies) {
        [self _hideStickyPanel:panel];
    }
}

- (void)_hideStickyPanel:(StickyPanel *)panel {
    [self _adjustOriginsForPanelsAbovePanel:panel];
    [self.stickies removeObject:panel];
    [panel moveDownOffScreen];
    [panel close];
}

#pragma mark -

- (NSPoint)_originForNextPanelAbovePanel:(StickyPanel *)panel {
    CGFloat panelTopY = panel ? panel.frame.origin.y + panel.frame.size.height : 0;
    return NSMakePoint(10, panelTopY + 10);
}

- (void)_adjustOriginsForPanelsAbovePanel:(StickyPanel *)sentinelPanel {
    BOOL afterPanel = NO;
    for (StickyPanel *panel in self.stickies) {
        if (panel == sentinelPanel) {
            afterPanel = YES;
        } else if (afterPanel) {
            [panel moveDownBy:sentinelPanel.frame.size.height + 10];
        }
    }
}

- (StickyPanel *)_stickyPanelWithStickyWithTag:(NSInteger)tag {
    for (StickyPanel *panel in self.stickies) {
        if (panel.sticky.tag == tag) return panel;
    }
    return nil;
}
@end
