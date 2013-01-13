#import <Foundation/Foundation.h>

@class GrowlNotification, GrowlNotifier;

@protocol GrowlNotifierDelegate <NSObject>
- (void)growlNotifier:(GrowlNotifier *)notifier
    didClickOnNotificationWithTag:(NSInteger)tag;
@end

@interface GrowlNotifier : NSObject

@property (nonatomic, assign) id<GrowlNotifierDelegate> delegate;

- (id)initWithNotificationTypes:(NSDictionary *)notificationTypes;

- (BOOL)canShowNotification;
- (void)showNotification:(GrowlNotification *)notification;
@end
