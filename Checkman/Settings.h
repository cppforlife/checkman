#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings *)userSettings;

#pragma mark - Check specific

- (NSUInteger)runIntervalForCheckWithName:(NSString *)name
    inCheckfileWithName:(NSString *)checkfileName;

- (BOOL)isCheckWithNameDisabled:(NSString *)name
    inCheckfileWithName:(NSString *)checkfileName;
@end
