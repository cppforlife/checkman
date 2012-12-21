#import <Cocoa/Cocoa.h>

@interface InfoMenuItem : NSMenuItem
+ (InfoMenuItem *)menuItemWithName:(NSString *)name value:(NSString *)value;
- (id)initWithName:(NSString *)name value:(NSString *)value;
@end
