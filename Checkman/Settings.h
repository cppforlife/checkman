#import <Foundation/Foundation.h>

@class Settings;

@protocol SettingsDelegate <NSObject>
- (void)settingsDidChange:(Settings *)settings;
@end

@interface Settings : NSObject

@property (nonatomic, assign) id<SettingsDelegate> delegate;

+ (Settings *)userSettings;

- (void)trackChanges;

#pragma mark - Check specific

- (NSUInteger)runIntervalForCheckWithName:(NSString *)name
    inCheckfileWithName:(NSString *)checkfileName;

- (BOOL)isCheckWithNameDisabled:(NSString *)name
    inCheckfileWithName:(NSString *)checkfileName;

#pragma mark - Notifications

- (BOOL)allowGrowlNotifications;
- (BOOL)allowNotificationCenterNotifications;
@end
