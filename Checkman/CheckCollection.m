#import "CheckCollection.h"
#import "Check.h"

@interface CheckCollection ()
@property (nonatomic, strong) NSMutableArray *checks;
@property (nonatomic, assign) CheckStatus status;
@property (nonatomic, assign, getter = isChanging) BOOL changing;
@end

@implementation CheckCollection

@synthesize
    delegate = _delegate,
    checks = _checks,
    status = _status,
    changing = _changing;

- (id)init {
    if (self = [super init]) {
        self.checks = [NSMutableArray array];
        self.status = CheckStatusUndetermined;
    }
    return self;
}

- (void)dealloc {
    for (Check *check in self.checks) {
        [self removeCheck:check];
    }
}

- (NSString *)description {
    return F(@"<CheckCollection: %p> status=%d changing=%d checks#=%d", self, self.status, self.isChanging, self.checks.count);
}

#pragma mark -

- (void)addCheck:(Check *)check {
    [self.checks addObject:check];
    [self _updateStatusAndChanging];
    [check addObserverForRunning:self];
}

- (void)removeCheck:(Check *)check {
    [check removeObserverForRunning:self];
    [self.checks removeObject:check];
    [self _updateStatusAndChanging];
}

- (NSUInteger)indexOfCheck:(Check *)check {
    return [self.checks indexOfObject:check];
}

- (Check *)checkWithTag:(NSInteger)tag {
    for (Check *check in self.checks) {
        if (check.tag == tag) return check;
    }
    return nil;
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self _updateStatusAndChanging];
}

- (void)_updateStatusAndChanging {
    self.status = [self _updateStatus];
    self.changing = [self _updateChanging];
    [self.delegate checkCollectionStatusAndChangingDidChange:self];
}

- (CheckStatus)_updateStatus {
    for (Check *check in self.checks) {
        if (check.status == CheckStatusFail) return CheckStatusFail;
        if (check.status == CheckStatusUndetermined) return CheckStatusUndetermined;
    }
    return self.checks.count ? CheckStatusOk : CheckStatusUndetermined;
}

- (BOOL)_updateChanging {
    for (Check *check in self.checks) {
        if (check.isChanging) return YES;
    }
    return NO;
}

- (NSString *)statusDescription {
    if (self.status == CheckStatusFail || self.status == CheckStatusUndetermined) {
        return F(@"%d", [self _numberOfChecksWithStatus:self.status]);
    }
    return nil;
}

- (int)_numberOfChecksWithStatus:(CheckStatus)status {
    int count = 0;
    for (Check *check in self.checks) {
        if (check.status == status) count++;
    }
    return count;
}
@end
