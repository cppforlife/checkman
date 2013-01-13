#import <Cocoa/Cocoa.h>

@class CustomNotification;

@interface NotificationPanelView : NSView
- (id)initWithNotification:(CustomNotification *)notification;
@end
