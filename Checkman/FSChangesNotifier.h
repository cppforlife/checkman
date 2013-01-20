#import <Foundation/Foundation.h>

@class FSChangesNotifier;

@protocol FSChangesNotifierDelegate <NSObject>
- (void)fsChangesNotifier:(FSChangesNotifier *)notifier
        filePathDidChange:(NSString *)filePath;
@end

@interface FSChangesNotifier : NSObject

+ (FSChangesNotifier *)sharedNotifier;

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
    forFilePath:(NSString *)filePath;

- (void)stopNotifying:(id<FSChangesNotifierDelegate>)delegate;
@end
