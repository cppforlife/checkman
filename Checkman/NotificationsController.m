#import "NotificationsController.h"
#import <objc/runtime.h>
#import "GrowlNotifier.h"
#import "CheckCollection.h"
#import "Check.h"

@interface NotificationsController () <CheckCollectionDelegate>
@property (nonatomic, strong) GrowlNotifier *growl;
@property (nonatomic, strong) CheckCollection *checks;
@end

@implementation NotificationsController
@synthesize
    allowGrowl = _allowGrowl,
    allowNotificationCenter = _allowNotificationCenter,
    growl = _growl,
    checks = _checks;

- (id)init {
    if (self = [super init]) {
        self.growl = [[GrowlNotifier alloc] init];
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
    if (!check.isAfterFirstRun) {
        [self _showNotificationForCheck:check];
    }
}

#pragma mark -

- (void)_showNotificationForCheck:(Check *)check {
    if (self.allowGrowl && self.growl.canShowNotification) {
        [self.growl showNotificationForCheck:check];
    } else if (self.allowNotificationCenter && self._canShowCenterNotification) {
        [self _showCenterNotificationForCheck:check];
    } else NSLog(@"NotificationsController - swallowed notification");
}

#pragma mark - OS X Notification Center

- (BOOL)_canShowCenterNotification {
    return objc_getClass("NSUserNotification") != nil;
}

- (void)_showCenterNotificationForCheck:(Check *)check {
    NSLog(@"NotificationsController - user notification: %@", check.name);

    id notification = [[NSClassFromString(@"NSUserNotification") alloc] init];
    [notification setTitle:check.name];
    [notification setInformativeText:check.statusNotificationText];
    [notification setDeliveryDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    id notificationCenter = NSClassFromString(@"NSUserNotificationCenter");
    [[notificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}
@end
