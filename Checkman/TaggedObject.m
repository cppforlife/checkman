#import "TaggedObject.h"

@implementation TaggedObject
@synthesize tag = _tag;

+ (NSInteger)_nextTag {
    static NSInteger tag = 0;
    NSAssert(++tag != 0, @"Tag must not be zero.");
    return tag;
}

- (id)init {
    if (self = [super init]) {
        self.tag = self.class._nextTag;
    }
    return self;
}

- (NSNumber *)tagAsNumber {
    return [NSNumber numberWithInteger:self.tag];
}

- (BOOL)isEqual:(id)object {
    if ([object respondsToSelector:@selector(tag)] && [object tag]) {
        return self.tag == [object tag];
    } else {
        return self == object;
    }
}
@end
