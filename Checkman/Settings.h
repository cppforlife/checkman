#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings *)userSettings;

- (NSUInteger)checkRunInterval;

- (BOOL)isCheckWithNameDisabled:(NSString *)name
            inCheckfileWithName:(NSString *)checkfileName;
@end
