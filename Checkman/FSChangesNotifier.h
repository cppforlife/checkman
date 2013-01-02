#import <Foundation/Foundation.h>

@class FSChangesNotifier;

@protocol FSChangesNotifierDelegate <NSObject>
- (void)fsChangesNotifier:(FSChangesNotifier *)notifier
        filePathDidChange:(NSString *)filePath;
@end

@interface FSChangesNotifier : NSObject

+ (FSChangesNotifier *)sharedNotifier;

// Track directory changes because RubyMine is doing atomic file saves (write tmp, remove, rename)
// more http://timnew.github.com/blog/2012/11/15/pitfall-in-fs-dot-watch/
- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
    forFilePathInDirectory:(NSString *)filePath;

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
    forFilePath:(NSString *)filePath;

- (void)stopNotifying:(id<FSChangesNotifierDelegate>)delegate;
@end
