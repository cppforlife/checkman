#import <Foundation/Foundation.h>

@interface TaggedObject : NSObject
@property (nonatomic, assign) NSInteger tag;
- (NSNumber *)tagAsNumber;
@end
