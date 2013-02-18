#import <Foundation/Foundation.h>

@class Check;

@interface WebUI : NSObject

- (id)initWithPort:(uint16_t)port;
- (void)start;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;
@end
