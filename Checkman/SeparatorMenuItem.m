#import "SeparatorMenuItem.h"
#import <objc/runtime.h>

@implementation SeparatorMenuItem
+ (SeparatorMenuItem *)separator {
    NSMenuItem *item = NSMenuItem.separatorItem;
    object_setClass(item, [SeparatorMenuItem class]);
    return (SeparatorMenuItem *)item;
}

+ (SeparatorMenuItem *)separatorWithTitle:(NSString *)title {
    SeparatorMenuItem *item = [[SeparatorMenuItem alloc] init];
    item.attributedTitle = [self _separatorTitle:title];
    item.enabled = NO;
    return item;
}

+ (NSAttributedString *)_separatorTitle:(NSString *)title {
    NSDictionary *attributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            NSCursor.arrowCursor, NSCursorAttributeName,
            NSColor.lightGrayColor, NSForegroundColorAttributeName,
            [NSFont fontWithName:@"Lucida Grande" size:10], NSFontAttributeName, nil];
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}
@end
