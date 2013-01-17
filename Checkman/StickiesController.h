#import <Foundation/Foundation.h>

@class Check;

@interface StickiesController : NSObject

@property (nonatomic, assign, getter = isAllowed) BOOL allow;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
