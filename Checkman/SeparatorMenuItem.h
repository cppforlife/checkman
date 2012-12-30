#import <Cocoa/Cocoa.h>

@interface SeparatorMenuItem : NSMenuItem
+ (SeparatorMenuItem *)separator;
+ (SeparatorMenuItem *)separatorWithTitle:(NSString *)title;
@end
