#import "ApplicationDelegate.h"
#import "CheckDebuggingWindow.h"
#import "MenuController.h"
#import "CheckManager.h"
#import "Settings.h"

@interface ApplicationDelegate () <MenuControllerDelegate>
@property (nonatomic, strong) CheckManager *checkManager;
@property (nonatomic, strong) MenuController *menuController;
@end

@implementation ApplicationDelegate

@synthesize
    checkManager = _checkManager,
    menuController = _menuController;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self _announceGitSha];
    [self performSelector:@selector(_setUp) withObject:nil afterDelay:0];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.menuController = nil;
    return NSTerminateNow;
}

- (void)_setUp {
    self.menuController = [[MenuController alloc] init];
    self.menuController.delegate = self;

    self.checkManager =
        [[CheckManager alloc]
            initWithMenuController:self.menuController
            settings:Settings.userSettings];
    [self.checkManager loadCheckfiles];
}

#pragma mark - MenuControllerDelegate

- (void)menuController:(MenuController *)controller showDebugOutputForCheck:(Check *)check {
    CheckDebuggingWindow *window = [[CheckDebuggingWindow alloc] initWithCheck:check];
    [window keepOpenUntilClosed];
    [window show];
}

#pragma mark - Git SHA

- (void)_announceGitSha {
    NSLog(@"ApplicationDelegate - Git SHA: %@", self.gitSha);
}

- (NSString *)gitSha {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Git SHA"];
}
@end
