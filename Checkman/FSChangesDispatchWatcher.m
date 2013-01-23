#import "FSChangesDispatchWatcher.h"

#if __has_feature(objc_arc)
#define BRIDGE_CAST(type, thing) (__bridge type)(thing)
#else
#define BRIDGE_CAST(type, thing) (type)(thing)
#endif

@interface FSChangesDispatchWatcher ()
@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, assign) dispatch_group_t group;
@property (nonatomic, strong) NSMutableDictionary *paths;
@end

@implementation FSChangesDispatchWatcher
@synthesize
    delegate = _delegate,
    queue = _queue,
    group = _group,
    paths = _paths;

- (id)init {
    if (self = [super init]) {
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.group = dispatch_group_create();
        self.paths = self.class._nonRetainingMutableDictionary;
    }
    return self;
}

- (void)dealloc {
    NSAssert(self.paths.count == 0, @"All paths must be removed.");
    dispatch_group_leave(self.group);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)addPath:(NSString *)path {
    int fd = open(path.UTF8String, O_EVTONLY);
    if (fd <= 0) return NSLog(@"FSChangesDispatchWatcher - addPath: failed to add %@", path);

    dispatch_source_t source = dispatch_source_create(
        DISPATCH_SOURCE_TYPE_VNODE, (uintptr_t)fd,
        DISPATCH_VNODE_WRITE, self.queue);

    NSValue *sourcePointer = [NSValue valueWithPointer:&source];
    [self.class _setObject:sourcePointer forKey:path
        inNonRetainingMutableDictionary:self.paths];

    __block typeof(self) that = self;
    dispatch_source_set_cancel_handler(source, ^{ close(fd); });
    dispatch_source_set_event_handler(source, ^{
        [that.delegate fsChangesDispatchWatcher:that didNoticeChangeToPath:path];
    });

    dispatch_resume(source);
}

- (void)removePath:(NSString *)path {
    NSValue *sourcePointer = [self.paths objectForKey:path];
    dispatch_source_t source = (dispatch_source_t)[sourcePointer pointerValue];

    if (source) {
        dispatch_source_cancel(source);
        [self.paths removeObjectForKey:path];
    }
}

#pragma mark - Non-retaining dictionary

inline static const void *FSChangesNotifier_RetainCallBack
    (CFAllocatorRef allocator, const void *value) { return CFRetain(value); }
inline static void FSChangesNotifier_ReleaseCallBack
    (CFAllocatorRef allocator, const void *value) { CFRelease(value); }

+ (NSMutableDictionary *)_nonRetainingMutableDictionary {
    CFMutableDictionaryRef dictionary =
        CFDictionaryCreateMutable(nil, 0, &kCFCopyStringDictionaryKeyCallBacks, NULL);
    return CFBridgingRelease(dictionary);
}

+ (void)_setObject:(id)object forKey:(id)key
        inNonRetainingMutableDictionary:(NSMutableDictionary *)dictionary {
    CFDictionarySetValue(
        (CFMutableDictionaryRef)dictionary,
        BRIDGE_CAST(const void *, key),
        BRIDGE_CAST(const void *, object));
}
@end
