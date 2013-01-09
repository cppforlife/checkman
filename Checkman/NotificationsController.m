#import "NotificationsController.h"
#import "CheckCollection.h"
#import "Check.h"

@interface NotificationsController () <CheckCollectionDelegate>
@property (nonatomic, strong) CheckCollection *checks;
@end

@implementation NotificationsController
@synthesize checks = _checks;

- (id)init {
    if (self = [super init]) {
        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;
    }
    return self;
}

- (void)addCheck:(Check *)check {
    [self.checks addCheck:check];
}

- (void)removeCheck:(Check *)check {
    [self.checks removeCheck:check];
}

#pragma mark - CheckCollectionDelegate

- (void)checkCollection:(CheckCollection *)collection
        didUpdateStatusFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
        didUpdateChangingFromCheck:(Check *)check {}

- (void)checkCollection:(CheckCollection *)collection
        checkDidChangeStatus:(Check *)check {
    [self _showNotificationForCheck:check];
}

#pragma mark - Send notification

- (void)_showNotificationForCheck:(Check *)check {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = check.name;
    notification.informativeText = [self _textForStatus:check.status];
    notification.deliveryDate = [NSDate dateWithTimeIntervalSinceNow:1];
    [self _sendNotification:notification];
}

- (void)_sendNotification:(NSUserNotification *)notification {
    NSLog(@"NotificationsController - send: %@ '%@'",
          notification.title, notification.informativeText);
    [NSUserNotificationCenter.defaultUserNotificationCenter scheduleNotification:notification];
}

- (NSString *)_textForStatus:(CheckStatus)status {
    switch (status) {
        case CheckStatusOk: return @"Now OK";
        case CheckStatusFail: return @"Now FAILED";
        case CheckStatusUndetermined: return @"Now ?";
    }
}
@end
