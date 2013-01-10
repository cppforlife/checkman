#import <Foundation/Foundation.h>

@class Check, GrowlNotifier;

@protocol GrowlNotifierDelegate <NSObject>
- (void)growlNotifier:(GrowlNotifier *)notifier
    didClickOnCheckWithTag:(NSInteger)tag;
@end

@interface GrowlNotifier : NSObject

@property (nonatomic, assign) id<GrowlNotifierDelegate> delegate;

- (BOOL)canShowNotification;
- (void)showNotificationForCheck:(Check *)check;
@end
