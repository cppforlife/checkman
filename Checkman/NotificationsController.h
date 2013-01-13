#import <Foundation/Foundation.h>

@class Check, NotificationsController;

@protocol NotificationsControllerDelegate <NSObject>
- (void)notificationsController:(NotificationsController *)controller
                  didActOnCheck:(Check *)check;
@end

@interface NotificationsController : NSObject

@property (nonatomic, assign) id<NotificationsControllerDelegate> delegate;
@property (nonatomic, assign) BOOL allowCustom;
@property (nonatomic, assign) BOOL allowGrowl;
@property (nonatomic, assign) BOOL allowNotificationCenter;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
