#import "CustomNotifier.h"
#import "CustomNotification.h"
#import "NotificationPanel.h"
#import "NSWindow+KeepOpen.h"
#import "NSObject+Delayed.h"
#import "Check.h"

@interface CustomNotifier ()
@property (nonatomic, strong) NSMutableArray *pendingNotifications;
@property (nonatomic, strong) NotificationPanel *notificationPanel;
@end

@implementation CustomNotifier
@synthesize
    pendingNotifications = _pendingNotifications,
    notificationPanel = _notificationPanel;

- (id)init {
    if (self = [super init]) {
        self.pendingNotifications = [[NSMutableArray alloc] init];
    }
    return  self;
}

- (void)showNotification:(CustomNotification *)notification {
    [self.pendingNotifications insertObject:notification atIndex:0];
    [self _openPendingNotification];
}

#pragma mark -

- (void)_openPendingNotification {
    if (self._isNotificationPanelOpen) {
        [self _openPendingNotificationLater];
    } else if (self.pendingNotifications.count) {
        CustomNotification *notification = self.pendingNotifications.lastObject;
        [self _openNotificationPanelForNotification:notification];
        [self.pendingNotifications removeLastObject];
    }
}

- (void)_openPendingNotificationLater {
    [self performSelectorOnNextTick:@selector(_openPendingNotification) afterDelay:6];
}

#pragma mark - Current notification panel

- (void)_openNotificationPanelForNotification:(CustomNotification *)notification {
    NSAssert(!self.notificationPanel, @"Current panel must not be open.");

    self.notificationPanel =
        [[NotificationPanel alloc] initWithNotification:notification];
    [self.notificationPanel keepOpenUntilClosed];
    [self.notificationPanel show];

    [self _closeNotificationPanelLater];
}

- (BOOL)_isNotificationPanelOpen {
    return !!self.notificationPanel;
}

- (void)_closeNotificationPanelLater {
    [self performSelectorOnNextTick:@selector(_closeNotificationPanel) afterDelay:5];
}

- (void)_closeNotificationPanel {
    [self.notificationPanel close];
    self.notificationPanel = nil;
}
@end
