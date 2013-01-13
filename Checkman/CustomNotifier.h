#import <Foundation/Foundation.h>

@class CustomNotification;

@interface CustomNotifier : NSObject
- (void)showNotification:(CustomNotification *)notification;
@end
