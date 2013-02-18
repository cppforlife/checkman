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

#pragma mark - Stickies

- (BOOL)allowStickies;

#pragma mark - Notifications

- (BOOL)allowCustomNotifications;
- (BOOL)allowGrowlNotifications;
- (BOOL)allowNotificationCenterNotifications;

#pragma mark - WebUI

- (uint16_t)webUIPort;
@end
