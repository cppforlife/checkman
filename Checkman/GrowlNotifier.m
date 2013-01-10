#import "GrowlNotifier.h"
#import <Growl/Growl.h>
#import "Check.h"

@interface GrowlNotifier () <GrowlApplicationBridgeDelegate>
@property (nonatomic, assign) BOOL canShowNotification;
@end

@implementation GrowlNotifier
@synthesize
    delegate = _delegate,
    canShowNotification = _canShowNotification;

- (id)init {
    if (self = [super init]) {
        GrowlApplicationBridge.growlDelegate = self;
        self.canShowNotification =
            GrowlApplicationBridge.isGrowlRunning;
    }
    return self;
}

- (void)dealloc {
    GrowlApplicationBridge.growlDelegate = nil;
}

- (void)showNotificationForCheck:(Check *)check {
    NSLog(@"GrowlNotifier - show: %@", check.name);

    [GrowlApplicationBridge
        notifyWithTitle:check.name
        description:check.statusNotificationText
        notificationName:[self _growlNotificationForStatus:check.status]
        iconData:nil priority:0 isSticky:NO
        clickContext:check.tagAsNumber];
}

#pragma mark - Potential notifications

static NSString
    *CheckStatusOkGrowl = @"CheckStatusOk",
    *CheckStatusFailGrowl = @"CheckStatusFail",
    *CheckStatusUndeterminedGrowl = @"CheckStatusUndetermined";

- (NSDictionary *)_growlNotifications {
    static NSDictionary *notifications = nil;
    if (!notifications) notifications =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"Check OK", CheckStatusOkGrowl,
         @"Check FAILED", CheckStatusFailGrowl,
         @"Check UNDETERMINED", CheckStatusUndeterminedGrowl, nil];
    return notifications;
}

- (NSString *)_growlNotificationForStatus:(CheckStatus)status {
    switch (status) {
        case CheckStatusOk: return CheckStatusOkGrowl;
        case CheckStatusFail: return CheckStatusFailGrowl;
        case CheckStatusUndetermined: return CheckStatusUndeterminedGrowl;
    }
}

#pragma mark - GrowlApplicationBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            NSProcessInfo.processInfo.processName, GROWL_APP_NAME,
            GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT,
            self._growlNotifications.allKeys, GROWL_NOTIFICATIONS_ALL,
            self._growlNotifications, GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES, nil];
}

- (void)growlNotificationWasClicked:(id)clickContext {
    NSNumber *checkTag = (NSNumber *)clickContext;
    [self.delegate growlNotifier:self didClickOnCheckWithTag:checkTag.integerValue];
}
@end
