#import <Foundation/Foundation.h>

@protocol FSChangesObserver;

@protocol FSChangesTracker <NSObject>
- (void)startTrackingFilePath:(NSString *)filePath
    observer:(id<FSChangesObserver>)observer;

- (void)stopTrackingFilePath:(NSString *)filePath
    observer:(id<FSChangesObserver>)observer;
@end

@protocol FSChangesObserver <NSObject>
- (void)handleChangeForFilePath:(NSString *)path
    tracker:(id<FSChangesTracker>)tracker;
@end
