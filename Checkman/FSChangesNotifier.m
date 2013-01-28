#import "FSChangesNotifier.h"
#import "FSChangesObserver.h"
#import "FSChangesTracker.h"

@interface FSChangesNotifier () <FSChangesObserverDelegate>
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) FSChangesTracker *tracker;
@end

@implementation FSChangesNotifier
@synthesize
    observers = _observers,
    tracker = _tracker;

+ (FSChangesNotifier *)sharedNotifier {
    static FSChangesNotifier *notifier = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        notifier = [[FSChangesNotifier alloc] init];
    });
    return notifier;
}

- (id)init {
    if (self = [super init]) {
        self.observers = self.class._nonRetainingMutableDictionary;
        self.tracker = [[FSChangesTracker alloc] init];
    }
    return self;
}

#pragma mark -

- (void)startNotifying:(id<FSChangesNotifierDelegate>)delegate
        forFilePath:(NSString *)filePath {
    FSChangesObserver *observer =
        [[FSChangesObserver alloc] initWithFilePath:filePath];
    observer.delegate = self;

    [self.class _setObject:delegate forKey:observer
        inNonRetainingMutableDictionary:self.observers];
    [observer startTracking:self.tracker];
}

- (void)stopNotifying:(id<FSChangesNotifierDelegate>)delegate {
    for (FSChangesObserver *observer in self.observers) {
        if ([self.observers objectForKey:observer] == delegate) {
            [observer stopTracking:self.tracker];
            [self.observers removeObjectForKey:observer];
            return;
        }
    }
}

#pragma mark - FSChangesObserverDelegate

- (void)fsChangesObserverDidNoticeChange:(FSChangesObserver *)observer {
    id<FSChangesNotifierDelegate> delegate = [self.observers objectForKey:observer];
    [delegate fsChangesNotifier:self filePathDidChange:observer.filePath];
}

#pragma mark - Non-retaining dictionary

inline static const void *FSChangesNotifier_RetainCallBack
    (CFAllocatorRef allocator, const void *value) { return CFRetain(value); }
inline static void FSChangesNotifier_ReleaseCallBack
    (CFAllocatorRef allocator, const void *value) { CFRelease(value); }

+ (NSMutableDictionary *)_nonRetainingMutableDictionary {
    CFMutableDictionaryRef dictionary =
        CFDictionaryCreateMutable(nil, 0, &(CFDictionaryKeyCallBacks){
            0, // version
            &FSChangesNotifier_RetainCallBack,
            &FSChangesNotifier_ReleaseCallBack,
            NULL, NULL, NULL,
        }, NULL);
    return CFBridgingRelease(dictionary);
}

#if __has_feature(objc_arc)
#define BRIDGE_CAST(type, thing) (__bridge type)(thing)
#else
#define BRIDGE_CAST(type, thing) (type)(thing)
#endif

+ (void)_setObject:(id)object forKey:(id)key
        inNonRetainingMutableDictionary:(NSMutableDictionary *)dictionary {
    CFDictionarySetValue(
        BRIDGE_CAST(CFMutableDictionaryRef, dictionary),
        BRIDGE_CAST(const void *, key),
        BRIDGE_CAST(const void *, object));
}
@end
