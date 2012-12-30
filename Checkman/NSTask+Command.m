#import "NSTask+Command.h"

@implementation NSTask (Command)
- (NSString *)executedCommand {
    return F(@"cd %@; %@ %@",
             self.currentDirectoryPath,
             self.launchPath,
             self._argumentsAsEscapedString);
}

// Does not correctly handle quotes
- (NSString *)_argumentsAsEscapedString {
    return F(@"\"%@\"", [self.arguments componentsJoinedByString:@"\" \""]);
}
@end
