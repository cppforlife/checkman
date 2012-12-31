#import "InfoMenuItem.h"

@interface InfoMenuItem ()
@property (nonatomic, strong) NSString *value;
@end

@implementation InfoMenuItem
@synthesize value = _value;

+ (InfoMenuItem *)menuItemWithName:(NSString *)name value:(NSString *)value {
    if ([name isEqualToString:@"-"]) {
        return (id)[self separatorItem];
    }
    return [[self alloc] initWithName:name value:value];
}

- (id)initWithName:(NSString *)name value:(NSString *)value {
    if (self = [super init]) {
        self.value = value;
        self.enabled = NO;

        NSString *title = F(@"%@: %@", name, value);
        NSMutableAttributedString *attributedTitle = 
            [[NSMutableAttributedString alloc] initWithString:title];
        [attributedTitle 
            addAttribute:NSForegroundColorAttributeName 
            value:NSColor.darkGrayColor 
            range:NSMakeRange(0, title.length)];
        self.attributedTitle = attributedTitle;

        self.target = self;
        self.action = @selector(performAction);
    }
    return self;
}

- (void)performAction {
    [self writeStringToPasteBoard:self.value];
}

- (void)writeStringToPasteBoard:(NSString *)string {
    if (self.value) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard clearContents];
        [pasteBoard writeObjects:[NSArray arrayWithObject:string]];
    }
}
@end
