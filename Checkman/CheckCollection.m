#import "CheckCollection.h"

@interface CheckCollection () <CheckDelegate>
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
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (NSString *)description {
    return F(@"<CheckCollection: %p> status=%d changing=%d checks#=%ld",
             self, self.status, self.isChanging, self.checks.count);
}

#pragma mark -

- (void)addCheck:(Check *)check {
    [self.checks addObject:check];
    [self _updateStatusAndChangingFromCheck:check];
    [check addObserver:self];
}

- (void)removeCheck:(Check *)check {
    [check removeObserver:self];
    [self.checks removeObject:check];
    [self _updateStatusAndChangingFromCheck:check];
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

#pragma mark - CheckDelegate

- (void)checkDidChangeStatus:(NSNotification *)notification {
    Check *check = (Check *)notification.object;
    [self _updateStatusFromCheck:check];

    // Delegate individual check status changes for conveniece
    if ([self.delegate respondsToSelector:@selector(checkCollection:checkDidChangeStatus:)]) {
        [self.delegate checkCollection:self checkDidChangeStatus:check];
    }
}

- (void)checkDidChangeChanging:(NSNotification *)notification {
    Check *check = (Check *)notification.object;
    [self _updateChangingFromCheck:check];

    // Delegate individual check changing changes for conveniece
    if ([self.delegate respondsToSelector:@selector(checkCollection:checkDidChangeChanging:)]) {
        [self.delegate checkCollection:self checkDidChangeChanging:check];
    }
}

- (void)checkDidChangeRunning:(NSNotification *)notification {}

#pragma mark -

- (void)_updateStatusAndChangingFromCheck:(Check *)check {
    [self _updateStatusFromCheck:check];
    [self _updateChangingFromCheck:check];
}

- (void)_updateStatusFromCheck:(Check *)check {
    self.status = [self _aggregateStatus];
    [self.delegate checkCollection:self didUpdateStatusFromCheck:check];
}

- (void)_updateChangingFromCheck:(Check *)check {
    self.changing = [self _aggregateChanging];
    [self.delegate checkCollection:self didUpdateChangingFromCheck:check];
}

- (CheckStatus)_aggregateStatus {
    if (self.checks.count == 0)
        return CheckStatusUndetermined;

    BOOL hasFailed = NO;

    for (Check *check in self.checks) {
        if (check.isDisabled)
            continue;
        if (check.status == CheckStatusFail)
            hasFailed = YES;
        if (check.status == CheckStatusUndetermined)
            return CheckStatusUndetermined;
    }
    return hasFailed ? CheckStatusFail : CheckStatusOk;
}

- (BOOL)_aggregateChanging {
    for (Check *check in self.checks) {
        if (check.isChanging) return YES;
    }
    return NO;
}

#pragma mark -

- (NSString *)statusDescription {
    if (self.status == CheckStatusFail || self.status == CheckStatusUndetermined) {
        return F(@"%ld", [self _numberOfChecksWithStatus:self.status]);
    }
    return nil;
}

- (NSString *)extendedStatusDescription {
    return F(@"%ld Ok\n%ld Failed\n%ld Undetermined\n%ld Disabled",
        [self _numberOfChecksWithStatus:CheckStatusOk],
        [self _numberOfChecksWithStatus:CheckStatusFail],
        [self _numberOfChecksWithStatus:CheckStatusUndetermined],
        self.numberOfDisabledChecks);
}

- (NSUInteger)_numberOfChecksWithStatus:(CheckStatus)status {
    NSUInteger count = 0;
    for (Check *check in self.checks) {
        if (check.isDisabled) continue;
        if (check.status == status) count++;
    }
    return count;
}

- (NSUInteger)numberOfDisabledChecks {
    NSUInteger count = 0;
    for (Check *check in self.checks) {
        if (check.isDisabled) count++;
    }
    return count;
}

- (NSUInteger)count {
    return self.checks.count;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
        objects:(id __unsafe_unretained [])buffer count:(NSUInteger)length {
    return [self.checks countByEnumeratingWithState:state objects:buffer count:length];
}
@end
