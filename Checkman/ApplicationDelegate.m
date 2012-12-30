#import "ApplicationDelegate.h"
#import "MenuController.h"
#import "CheckDebuggingWindow.h"
#import "CheckCollection.h"
#import "CheckManager.h"

@interface ApplicationDelegate () <MenuControllerDelegate>
@property (nonatomic, strong) CheckManager *checkManager;
@property (nonatomic, strong) MenuController *menuController;
@end

@implementation ApplicationDelegate

@synthesize
    checkManager = _checkManager,
    menuController = _menuController;

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
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

    self.checkManager = [[CheckManager alloc] initWithMenuController:self.menuController];
    [self.checkManager loadCheckfiles];
}

#pragma mark - MenuControllerDelegate

- (void)menuController:(MenuController *)controller showDebugOutputForCheck:(Check *)check {
    CheckDebuggingWindow *window = [[CheckDebuggingWindow alloc] initWithCheck:check];
    [window keepOpenUntilClosed];
    [window show];
}
@end
