#import "GrowlNotifier.h"
#import "GrowlNotification.h"
#import <Growl/Growl.h>

@interface GrowlNotifier () <GrowlApplicationBridgeDelegate>
@property (nonatomic, strong) NSDictionary *notificationTypes;
@property (nonatomic, assign) BOOL canShowNotification;
@end

@implementation GrowlNotifier
@synthesize
    delegate = _delegate,
    notificationTypes = _notificationTypes,
    canShowNotification = _canShowNotification;

- (id)initWithNotificationTypes:(NSDictionary *)notificationTypes {
    if (self = [super init]) {
        self.notificationTypes = notificationTypes;
        self.canShowNotification = GrowlApplicationBridge.isGrowlRunning;
        GrowlApplicationBridge.growlDelegate = self;
    }
    return self;
}

- (void)dealloc {
    GrowlApplicationBridge.growlDelegate = nil;
}

- (void)showNotification:(GrowlNotification *)notification {
    NSLog(@"GrowlNotifier - show: %@", notification.name);

    [GrowlApplicationBridge
        notifyWithTitle:notification.name
        description:notification.status
        notificationName:notification.type
        iconData:nil priority:0 isSticky:NO
        clickContext:notification.tagAsNumber];
}

#pragma mark - GrowlApplicationBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            NSProcessInfo.processInfo.processName, GROWL_APP_NAME,
            GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT,
            self.notificationTypes.allKeys, GROWL_NOTIFICATIONS_ALL,
            self.notificationTypes, GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES, nil];
}

- (void)growlNotificationWasClicked:(id)clickContext {
    NSNumber *checkTag = (NSNumber *)clickContext;
    [self.delegate growlNotifier:self didClickOnNotificationWithTag:checkTag.integerValue];
}
@end
