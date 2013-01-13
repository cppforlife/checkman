#import <Foundation/Foundation.h>

@class CustomNotification;

@interface NotificationPanel : NSPanel
- (id)initWithNotification:(CustomNotification *)notification;
- (void)show;
@end
