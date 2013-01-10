#import <Foundation/Foundation.h>

@class Check;

@interface NotificationsController : NSObject

@property (nonatomic, assign) BOOL allowGrowl;
@property (nonatomic, assign) BOOL allowNotificationCenter;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
