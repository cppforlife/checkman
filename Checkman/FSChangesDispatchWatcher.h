#import <Foundation/Foundation.h>

@class FSChangesDispatchWatcher;

@protocol FSChangesDispatchWatcherDelegate <NSObject>
- (void)fsChangesDispatchWatcher:(FSChangesDispatchWatcher *)watcher
           didNoticeChangeToPath:(NSString *)path;
@end

@interface FSChangesDispatchWatcher : NSObject
@property (nonatomic, assign) id<FSChangesDispatchWatcherDelegate> delegate;

- (void)addPath:(NSString *)path;
- (void)removePath:(NSString *)path;
@end
