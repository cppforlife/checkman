#import "CheckDebuggingView.h"
#import "Check.h"

@interface CheckDebuggingView () <CheckDelegate>
@property (nonatomic, strong) Check *check;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTextView *outputTextView;
@end

@implementation CheckDebuggingView
@synthesize
    check = _check,
    scrollView = _scrollView,
    outputTextView = _outputTextView;

- (id)initWithCheck:(Check *)check {
    if (self = [super init]) {
        self.check = check;

        self.scrollView.documentView = self.outputTextView;
        [self addSubview:self.scrollView];

        [self _appendLatestCheckInfo];
        [self.check addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.check removeObserver:self];
}

#pragma mark - CheckDelegate

- (void)checkDidChangeStatus:(NSNotification *)notification {}
- (void)checkDidChangeChanging:(NSNotification *)notification {}

- (void)checkDidChangeRunning:(NSNotification *)notification {
    if (!self.check.isRunning) {
        [self _appendLatestCheckInfo];
    }
}

#pragma mark -

- (void)_appendLatestCheckInfo {
    [self.outputTextView.textStorage appendAttributedString:self._latestCheckInfo];
    self.outputTextView.font = [NSFont fontWithName:@"Monaco" size:12];
    [self.scrollView flashScrollers];
}

- (NSAttributedString *)_latestCheckInfo {
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];

    if (self.check.executedCommand) {
        [result appendAttributedString:[self _commandString:self.check.executedCommand]];
        [result appendAttributedString:[self _stdOutString:self.check.stdOut]];
        [result appendAttributedString:[self _stdErrString:self.check.stdErr]];
    } else {
        [result appendAttributedString:[self _messageString:@"Did not finish running yet."]];
    }
    return result;
}

- (NSAttributedString *)_commandString:(NSString *)command {
    NSDictionary *attributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, nil];
    return [[NSAttributedString alloc] initWithString:F(@"%@\n\n", command) attributes:attributes];
}

- (NSAttributedString *)_stdOutString:(NSString *)stdOut {
    return [[NSAttributedString alloc] initWithString:F(@"%@%@", stdOut, stdOut.length ? @"\n" : @"")];
}

- (NSAttributedString *)_stdErrString:(NSString *)stdErr {
    NSDictionary *attributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            NSColor.lightGrayColor, NSForegroundColorAttributeName, nil];
    return [[NSAttributedString alloc]
                initWithString:F(@"%@%@", stdErr, stdErr.length ? @"\n" : @"")
                attributes:attributes];
}

- (NSAttributedString *)_messageString:(NSString *)message {
    NSDictionary *attributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
            NSColor.lightGrayColor, NSForegroundColorAttributeName, nil];
    return [[NSAttributedString alloc]
                initWithString:F(@"%@%@", message, message.length ? @"\n" : @"")
                attributes:attributes];
}

#pragma mark -

- (NSScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[NSScrollView alloc] init];
        _scrollView.borderType = NSNoBorder;
        _scrollView.hasVerticalScroller = YES;
        _scrollView.hasHorizontalScroller = NO;
        _scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
    return _scrollView;
}

- (NSTextView *)outputTextView {
    if (!_outputTextView) {
        _outputTextView = [[NSTextView alloc] init];
        _outputTextView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _outputTextView.backgroundColor = NSColor.controlLightHighlightColor;
        _outputTextView.editable = NO;
        _outputTextView.selectable = YES;
        _outputTextView.usesFindBar = YES;
    }
    return _outputTextView;
}
@end
