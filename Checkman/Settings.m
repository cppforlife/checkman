#import "Settings.h"
#import "FSChangesNotifier.h"

@interface Settings () <FSChangesNotifierDelegate>
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDictionary *currentValues;
@property (nonatomic, strong) FSChangesNotifier *fsChangesNotifier;
@end

@implementation Settings
@synthesize
    delegate = _delegate,
    userDefaults = _userDefaults,
    currentValues = _currentValues,
    fsChangesNotifier = _fsChangesNotifier;

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
        self.currentValues = self._loadCurrentValues;
        self.fsChangesNotifier = [FSChangesNotifier sharedNotifier];
    }
    return self;
}

- (void)dealloc {
    [self.fsChangesNotifier stopNotifying:self];
}

#pragma mark -

- (void)trackChanges {
    NSString *tildeFilePath = F(@"~/Library/Preferences/%@.plist", NSBundle.mainBundle.bundleIdentifier);
    NSString *filePath = [tildeFilePath stringByExpandingTildeInPath];
    [self.fsChangesNotifier startNotifying:self forFilePath:filePath];
}

- (NSDictionary *)_loadCurrentValues {
    return [self.userDefaults persistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
}

- (void)_reload {
    NSDictionary *newCurrentValues = self._loadCurrentValues;

    // Watch out [nil isEqual:nil] returns nil!
    if (!self.currentValues && !newCurrentValues) return;

    if (![self.currentValues isEqual:newCurrentValues]) {
        self.currentValues = newCurrentValues;
        [self.delegate settingsDidChange:self];
    }
}

- (void)fsChangesNotifier:(FSChangesNotifier *)notifier
        filePathDidChange:(NSString *)filePath {
    [self.userDefaults synchronize];
    [self performSelectorOnMainThread:@selector(_reload)
          withObject:nil waitUntilDone:NO];
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

#pragma mark - Stickies

- (BOOL)allowStickies {
    return ![self.userDefaults boolForKey:@"stickies.disabled"];
}

#pragma mark - Notifications

- (BOOL)allowCustomNotifications {
    return [self.userDefaults boolForKey:@"notifications.custom.enabled"];
}

- (BOOL)allowGrowlNotifications {
    return [self.userDefaults boolForKey:@"notifications.growl.enabled"];
}

- (BOOL)allowNotificationCenterNotifications {
    return [self.userDefaults boolForKey:@"notifications.center.enabled"];
}

#pragma mark - WebUI

- (uint16_t)webUIPort {
    NSInteger port = [self.userDefaults integerForKey:@"webUI.port"];
    return port > 0 ? (uint16_t)port : 1234;
}
@end
