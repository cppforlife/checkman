#import "GrowlNotification.h"

@implementation GrowlNotification
@synthesize
    name = _name,
    status = _status,
    type = _type,
    tag = _tag;

- (NSNumber *)tagAsNumber {
    return [NSNumber numberWithInteger:self.tag];
}
@end
