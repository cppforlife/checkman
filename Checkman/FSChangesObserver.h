#import <Foundation/Foundation.h>
#import "FSChanges.h"

@class FSChangesObserver;

@protocol FSChangesObserverDelegate <NSObject>
- (void)fsChangesObserverDidNoticeChange:(FSChangesObserver *)observer;
@end

@interface FSChangesObserver : NSObject <FSChangesObserver>

@property (nonatomic, assign) id<FSChangesObserverDelegate> delegate;

- (id)initWithFilePath:(NSString *)filePath;
- (NSString *)filePath;

- (void)startTracking:(id<FSChangesTracker>)tracker;
- (void)stopTracking:(id<FSChangesTracker>)tracker;

- (void)handleChangeForFilePath:(NSString *)filePath
    tracker:(id<FSChangesTracker>)tracker;
@end
