#import "NotificationsController.h"
#import <objc/runtime.h>
#import "CustomNotifier.h"
#import "CustomNotification.h"
#import "GrowlNotifier.h"
#import "GrowlNotification.h"
#import "CheckCollection.h"
#import "Check.h"

// Make compiler happy
@interface NotificationsController (FakeNSUserNotification)
+ (id)defaultUserNotificationCenter;
- (void)setDeliveryDate:(NSDate *)date;
- (void)scheduleNotification:(id)notification;
@end

@interface NotificationsController () <CheckCollectionDelegate>
@property (nonatomic, strong) CustomNotifier *custom;
@property (nonatomic, strong) GrowlNotifier *growl;
@property (nonatomic, strong) CheckCollection *checks;
@end

@interface NotificationsController (Custom)
- (void)_showCustomNotificationForCheck:(Check *)check;
@end

@interface NotificationsController (Growl) <GrowlNotifierDelegate>
- (void)_showGrowlNotificationForCheck:(Check *)check;
@end

@interface NotificationsController (Center)
- (BOOL)_canShowCenterNotification;
- (void)_showCenterNotificationForCheck:(Check *)check;
@end

@implementation NotificationsController

@synthesize
    delegate = _delegate,
    allowCustom = _allowCustom,
    allowGrowl = _allowGrowl,
    allowNotificationCenter = _allowNotificationCenter,
    custom = _custom,
    growl = _growl,
    checks = _checks;

- (id)init {
    if (self = [super init]) {
        self.custom = [[CustomNotifier alloc] init];
        self.checks = [[CheckCollection alloc] init];
        self.checks.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.growl.delegate = nil;
    self.checks.delegate = nil;
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
    if (self.allowCustom) {
        [self _showCustomNotificationForCheck:check];
    }
    if (self.allowGrowl && self.growl.canShowNotification) {
        [self _showGrowlNotificationForCheck:check];
    }
    if (self.allowNotificationCenter && self._canShowCenterNotification) {
        [self _showCenterNotificationForCheck:check];
    }
}
@end


@implementation NotificationsController (Custom)
- (void)_showCustomNotificationForCheck:(Check *)check {
    CustomNotification *notification = [[CustomNotification alloc] init];
    notification.name = check.statusNotificationName;
    notification.status = check.statusNotificationText;
    notification.color = check.statusNotificationColor;
    [self.custom showNotification:notification];
}
@end


@implementation NotificationsController (Growl)
- (GrowlNotifier *)growlNotifier {
    if (!_growl) {
        NSDictionary *notificationTypes =
            [NSDictionary dictionaryWithObjectsAndKeys:
                 @"Check OK", @"CheckStatusOk",
                 @"Check FAILED", @"CheckStatusFail",
                 @"Check UNDETERMINED", @"CheckStatusUndetermined", nil];
        _growl = [[GrowlNotifier alloc] initWithNotificationTypes:notificationTypes];
        _growl.delegate = self;
    }
    return _growl;
}

- (void)_showGrowlNotificationForCheck:(Check *)check {
    GrowlNotification *notification = [[GrowlNotification alloc] init];
    notification.name = check.statusNotificationName;
    notification.status = check.statusNotificationText;
    notification.type = [self _growlNotificationTypeForCheck:check];
    notification.tag = check.tag;
    [self.growl showNotification:notification];
}

- (NSString *)_growlNotificationTypeForCheck:(Check *)check {
    switch (check.status) {
        case CheckStatusOk: return @"CheckStatusOk";
        case CheckStatusFail: return @"CheckStatusFail";
        case CheckStatusUndetermined: return @"CheckStatusUndetermined";
    }
}

- (void)growlNotifier:(GrowlNotifier *)notifier
        didClickOnNotificationWithTag:(NSInteger)tag {
    Check *check = [self.checks checkWithTag:tag];
    [self.delegate notificationsController:self didActOnCheck:check];
}
@end


@implementation NotificationsController (Center)
- (BOOL)_canShowCenterNotification {
    return objc_getClass("NSUserNotification") != nil;
}

- (void)_showCenterNotificationForCheck:(Check *)check {
    NSLog(@"NotificationsController - user notification: %@", check.statusNotificationName);

    id notification = [[NSClassFromString(@"NSUserNotification") alloc] init];
    [notification setTitle:check.statusNotificationName];
    [notification setInformativeText:check.statusNotificationText];
    [notification setDeliveryDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    id notificationCenter = NSClassFromString(@"NSUserNotificationCenter");
    [[notificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}
@end
