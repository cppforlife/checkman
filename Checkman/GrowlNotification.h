#import <Foundation/Foundation.h>

@interface GrowlNotification : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) NSInteger tag;

- (NSNumber *)tagAsNumber;
@end
