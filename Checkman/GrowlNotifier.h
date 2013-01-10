#import <Foundation/Foundation.h>

@class Check;

@interface GrowlNotifier : NSObject
- (BOOL)canShowNotification;
- (void)showNotificationForCheck:(Check *)check;
@end
