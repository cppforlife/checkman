#import "ApplicationDelegate.h"
#import "CheckDebuggingWindow.h"
#import "CheckManager.h"
#import "MenuController.h"
#import "NotificationsController.h"
#import "StickiesController.h"
#import "Settings.h"
#import "Check.h"
#import "WebUI.h"

@interface ApplicationDelegate ()
    <SettingsDelegate, MenuControllerDelegate, NotificationsControllerDelegate>
@property (nonatomic, strong) CheckManager *checkManager;
@property (nonatomic, strong) MenuController *menuController;
@property (nonatomic, strong) StickiesController *stickiesController;
@property (nonatomic, strong) NotificationsController *notificationsController;
@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) WebUI *webUI;
@end

@implementation ApplicationDelegate
@synthesize
    checkManager = _checkManager,
    menuController = _menuController,
    stickiesController = _stickiesController,
    notificationsController = _notificationsController,
    settings = _settings,
    webUI = _webUI;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self _announceGitSha];
    [self performSelector:@selector(_setUp) withObject:nil afterDelay:0];
}

- (void)_setUp {
    [self _setUpSettings];
    [self _setUpMenu];
    [self _setUpStickies];
    [self _setUpNotifications];
    [self _setUpWebUI];
    [self _setUpCheckManager];
}

- (void)_setUpSettings {
    self.settings = Settings.userSettings;
    self.settings.delegate = self;
    [self.settings trackChanges];
}

- (void)_setUpMenu {
    self.menuController = [[MenuController alloc] initWithGitSha:self._gitSha];
    self.menuController.delegate = self;
}

- (void)_setUpStickies {
    self.stickiesController = [[StickiesController alloc] init];
    [self _configureStickiesController];
}

- (void)_configureStickiesController {
    self.stickiesController.allow = self.settings.allowStickies;
}

- (void)_setUpNotifications {
    self.notificationsController = [[NotificationsController alloc] init];
    self.notificationsController.delegate = self;
    [self _configureNotificationsController];
}

- (void)_configureNotificationsController {
    self.notificationsController.allowCustom =
        self.settings.allowCustomNotifications;
    self.notificationsController.allowGrowl =
        self.settings.allowGrowlNotifications;
    self.notificationsController.allowNotificationCenter =
        self.settings.allowNotificationCenterNotifications;
}

- (void)_setUpCheckManager {
    self.checkManager =
        [[CheckManager alloc]
            initWithMenuController:self.menuController
            stickiesController:self.stickiesController
            notificationsController:self.notificationsController
            webUI:self.webUI
            settings:self.settings];
    [self.checkManager loadCheckfiles];
}

- (void)_setUpWebUI {
    self.webUI = [[WebUI alloc] initWithPort:self.settings.webUIPort];
    [self.webUI start];
}

#pragma mark - SettingsDelegate

- (void)settingsDidChange:(Settings *)settings {
    [self.checkManager reloadCheckfiles];
    [self _configureNotificationsController];
    [self _configureStickiesController];
}

#pragma mark - Acting on check

- (void)menuController:(MenuController *)controller
        didActOnCheck:(Check *)check flags:(NSUInteger)flags {
    if (flags & NSAlternateKeyMask) {
        [self _showDebuggingWindow:check];
    } else if (flags & NSControlKeyMask) {
        [check stop];
        [check startImmediately:YES];
    } else [self _actOnCheck:check];
}

- (void)notificationsController:(NotificationsController *)controller
        didActOnCheck:(Check *)check {
    [self _actOnCheck:check];
}

- (void)_showDebuggingWindow:(Check *)check {
    CheckDebuggingWindow *window = [[CheckDebuggingWindow alloc] initWithCheck:check];
    [window keepOpenUntilClosed];
    [window show];
}

- (void)_actOnCheck:(Check *)check {
    if (check.url) {
        [NSWorkspace.sharedWorkspace openURL:check.url];
    }
}

#pragma mark - Git SHA

- (void)_announceGitSha {
    NSLog(@"ApplicationDelegate - Git SHA: %@", self._gitSha);
}

- (NSString *)_gitSha {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Git SHA"];
}
@end
