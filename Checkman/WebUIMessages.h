#import <Foundation/Foundation.h>

@class CheckCollection, Check;

@interface WebUIMessages : NSObject

- (NSString *)heartBeatJSONMessage:(CheckCollection *)checks;

- (NSString *)showCheckJSONMessage:(Check *)check;
- (NSString *)hideCheckJSONMessage:(Check *)check;
@end
