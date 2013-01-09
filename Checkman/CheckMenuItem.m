#import "CheckMenuItem.h"
#import "InfoMenuItem.h"
#import "Check.h"

@interface CheckMenuItem () <CheckDelegate>
@property (nonatomic, strong) Check *check;
@end

@implementation CheckMenuItem
@synthesize delegate = _delegate, check = _check;

- (id)initWithCheck:(Check *)check {
    if (self = [super init]) {
        self.check = check;
        self.enabled = !self.check.isDisabled;

        self.target = self;
        self.action = @selector(_performAction);

        [self _refreshName];
        [self _refreshStatusImage];
        [self _refreshInfoSubmenu];
        [self.check addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.check removeObserver:self];
}

- (void)_performAction {
    [self.delegate checkMenuItemWasClicked:self];
}

#pragma mark - CheckDelegate

- (void)checkDidChangeStatus:(NSNotification *)notification { [self _refreshStatusImage]; }
- (void)checkDidChangeChanging:(NSNotification *)notification { [self _refreshStatusImage]; }

- (void)checkDidChangeRunning:(NSNotification *)notification {
    [self _refreshName];
    [self _refreshInfoSubmenu];
}

#pragma mark -

- (void)_refreshName {
    static NSString *hellip = @"...", *spaces = @"   ";
    self.title = [self.check.name stringByAppendingString:self.check.isRunning ? hellip: spaces];
}

- (void)_refreshStatusImage {
    NSString *statusImageName =
        [Check statusImageNameForCheckStatus:self.check.status changing:self.check.isChanging];
    self.image = [NSImage imageNamed:statusImageName];
}

- (void)_refreshInfoSubmenu {
    if (self.check.info) {
        // Reuse existing submenu to avoid orphaning possibly opened menu
        self.submenu = self.submenu ? self.submenu : [[NSMenu alloc] init];
        [self _udpateMenu:self.submenu fromArray:self.check.info];
    } else {
        self.submenu = nil;
    }
}

- (void)_udpateMenu:(NSMenu *)menu fromArray:(NSArray *)array {
    [menu removeAllItems];

    for (NSArray *keyValuePair in array) {
        NSString *key = [keyValuePair objectAtIndex:0];
        NSString *value = [keyValuePair objectAtIndex:1];
        [menu addItem:[InfoMenuItem menuItemWithName:key value:value.description]];
    }
    [menu update];
}
@end
