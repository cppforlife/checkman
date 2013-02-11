#import <Foundation/Foundation.h>

@class Check;

@interface WebUI : NSObject

- (void)start;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
