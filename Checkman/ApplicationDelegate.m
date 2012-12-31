#import "ApplicationDelegate.h"
#import "CheckDebuggingWindow.h"
#import "CheckManager.h"
#import "MenuController.h"
#import "Settings.h"

@interface ApplicationDelegate () <MenuControllerDelegate, SettingsDelegate>
@property (nonatomic, strong) CheckManager *checkManager;
@property (nonatomic, strong) MenuController *menuController;
@property (nonatomic, strong) Settings *settings;
@end

@implementation ApplicationDelegate

@synthesize
    checkManager = _checkManager,
    menuController = _menuController,
    settings = _settings;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self _announceGitSha];
    [self performSelector:@selector(_setUp) withObject:nil afterDelay:0];
}

- (void)_setUp {
    self.menuController = [[MenuController alloc] init];
    self.menuController.delegate = self;

    self.settings = Settings.userSettings;
    self.settings.delegate = self;
    [self.settings trackChanges];

    self.checkManager =
        [[CheckManager alloc]
            initWithMenuController:self.menuController
            settings:self.settings];
    [self.checkManager loadCheckfiles];
}

#pragma mark - MenuControllerDelegate

- (void)menuController:(MenuController *)controller showDebugOutputForCheck:(Check *)check {
    CheckDebuggingWindow *window = [[CheckDebuggingWindow alloc] initWithCheck:check];
    [window keepOpenUntilClosed];
    [window show];
}

#pragma mark - SettingsDelegate

- (void)settingsDidChange:(Settings *)settings {
    [self.checkManager reloadCheckfiles];
}

#pragma mark - Git SHA

- (void)_announceGitSha {
    NSLog(@"ApplicationDelegate - Git SHA: %@", self.gitSha);
}

- (NSString *)gitSha {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Git SHA"];
}
@end
