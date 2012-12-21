#import "CheckMenuItem.h"
#import "InfoMenuItem.h"
#import "Check.h"

@interface CheckMenuItem ()
@property (nonatomic, strong) Check *check;
@end

@implementation CheckMenuItem

@synthesize check = _check;

- (id)initWithCheck:(Check *)check {
    if (self = [super init]) {
        self.check = check;
        self.title = self.check.name;
        self.enabled = YES;

        self.target = self;
        self.action = @selector(performAction);

        [self refreshStatusImage];
        [self.check addObserverForStatusAndRunning:self];
    }
    return self;
}

- (void)dealloc {
    [self.check removeObserverForStatusAndRunning:self];
}

#pragma mark - 

- (void)performAction {
    [self.check openUrl];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self refreshStatusImage];
    [self refreshInfoSubmenu];
}

- (void)refreshStatusImage {
    NSString *statusImageName = [Check statusImageNameForCheckStatus:self.check.status running:self.check.isRunning];
    self.image = [NSImage imageNamed:statusImageName];
}

- (void)refreshInfoSubmenu {
    if (self.check.info) {
        // Reuse existing submenu to avoid orphaning possibly opened menu
        self.submenu = self.submenu ? self.submenu : [[NSMenu alloc] init];
        [self udpateMenu:self.submenu fromArray:self.check.info];
    } else {
        self.submenu = nil;
    }
}

- (void)udpateMenu:(NSMenu *)menu fromArray:(NSArray *)array {
    [menu removeAllItems];

    for (NSArray *keyValuePair in array) {
        NSString *key = [keyValuePair objectAtIndex:0];
        NSString *value = [keyValuePair objectAtIndex:1];
        NSString *valueString = [NSString stringWithFormat:@"%@", value];
        [menu addItem:[InfoMenuItem menuItemWithName:key value:valueString]];
    }
    [menu update];
}
@end
