#import <Foundation/Foundation.h>

@class Check;

@interface NotificationsController : NSObject
- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
