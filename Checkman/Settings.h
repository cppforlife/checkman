#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings *)userSettings;

- (NSUInteger)checkRunInterval;
@end
