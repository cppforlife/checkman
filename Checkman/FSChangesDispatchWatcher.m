#import "FSChangesDispatchWatcher.h"

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
        self.paths = [NSMutableDictionary dictionary];
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

    NSValue *sourcePointer =
        [NSValue value:&source withObjCType:@encode(dispatch_source_t)];
    [self.paths setObject:sourcePointer forKey:path];

    __block typeof(self) that = self;
    dispatch_source_set_cancel_handler(source, ^{ close(fd); });
    dispatch_source_set_event_handler(source, ^{
        [that.delegate fsChangesDispatchWatcher:that didNoticeChangeToPath:path];
    });

    dispatch_resume(source);
}

- (void)removePath:(NSString *)path {
    dispatch_source_t source = NULL;
    [[self.paths objectForKey:path] getValue:&source];

    if (source) {
        dispatch_source_cancel(source);
        [self.paths removeObjectForKey:path];
    }
}
@end
