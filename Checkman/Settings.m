#import "Settings.h"

@interface Settings ()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation Settings
@synthesize userDefaults = _userDefaults;

// http://stackoverflow.com/questions/2199106/thread-safe-instantiation-of-a-singleton
+ (Settings *)userSettings {
    static Settings *userSettings = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        userSettings = [Settings alloc];
        userSettings = [userSettings initWithUserDefaults:userDefaults];
    });
    return userSettings;
}

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        self.userDefaults = userDefaults;
    }
    return self;
}

#pragma mark - Check specific

- (NSUInteger)runIntervalForCheckWithName:(NSString *)name
                      inCheckfileWithName:(NSString *)checkfileName {
    static NSString *key = @"checks.%@.%@.runInterval";

    NSInteger runInterval = [self.userDefaults integerForKey:F(key, checkfileName, name)];
    return runInterval > 0 ? (NSUInteger)runInterval : self._checkRunInterval;
}

- (BOOL)isCheckWithNameDisabled:(NSString *)name
            inCheckfileWithName:(NSString *)checkfileName {
    static NSString *key = @"checks.%@.%@.disabled";
    return [self.userDefaults boolForKey:F(key, checkfileName, name)];
}

#pragma mark -

- (NSUInteger)_checkRunInterval {
    static NSString *key = @"checkRunInterval";
    static NSUInteger defaultValue = 10;

    NSNumber *value = [self.userDefaults objectForKey:key];
    return value.unsignedIntegerValue > 0 ? value.unsignedIntegerValue : defaultValue;
}
@end
