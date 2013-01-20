#import "FSChangesNotifier.h"
#import "CedarAsync.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSString* createTmpDirectory();
void writeFile(NSString *_filePath);
void _changeFile(NSString *_filePath, BOOL atomically);
void changeFileNonAtomically(NSString *_filePath);
void changeFileAtomically(NSString *_filePath);
void deleteFile(NSString *_filePath);

SPEC_BEGIN(FSChangesNotifierSpec)

describe(@"FSChangesNotifier", ^{
    describe(@"-startNotifying:forFilePath:", ^{
        __block NSString *directory, *filePath;

        beforeEach(^{
            directory = createTmpDirectory();
            filePath = F(@"%@/file_%d", directory, rand());
            writeFile(F(@"%@_existing", filePath));
        });

        __block FSChangesNotifier *notifier;
        __block id<CedarDouble, FSChangesNotifierDelegate> delegate;
        const char *fsChangesNotifier_filePathDidChange = "fsChangesNotifier:filePathDidChange:";

        beforeEach(^{
            notifier = [[FSChangesNotifier alloc] init];
            delegate = fake_for(@protocol(FSChangesNotifierDelegate));
            delegate stub_method(fsChangesNotifier_filePathDidChange).and_do(^(NSInvocation *){
                NSLog(@"Received notification");
            });
        });

        afterEach(^{
            [notifier stopNotifying:delegate];
        });

        void (^resetDelegate)(void) = ^{
            in_time(delegate) should_not have_received("some-method-that-does-not-exist");
            [delegate reset_sent_messages];
            delegate.sent_messages.count should equal(0);
            NSLog(@"Done resetting sent messages");
        };

        void (^itNotifies)(void) = ^{
            it(@"notifies the delegate", ^{
                in_time(delegate) should have_received(fsChangesNotifier_filePathDidChange);
                [[NSSet setWithArray:delegate.sent_messages] count] should equal(1);
            });
        };

        void (^itDoesNotNotify)(void) = ^{
            it(@"does not notify the delegate", ^{
                in_time(delegate) should_not have_received(fsChangesNotifier_filePathDidChange);
                delegate.sent_messages.count should equal(0);
            });
        };

        sharedExamplesFor(@"notifier that notices file creation", ^(NSDictionary *_) {
            beforeEach(^{ resetDelegate(); });

            context(@"when file is created", ^{
                beforeEach(^{ writeFile(filePath); });
                itNotifies();
                itShouldBehaveLike(@"notifier that notices file changes atomically");
                itShouldBehaveLike(@"notifier that notices file changes non-atomically");
                // itShouldBehaveLike(@"notifier that notices file deletion");
            });

            context(@"when file is not created", ^{
                itDoesNotNotify();
            });

            context(@"when unrelated new file is created in the same directory", ^{
                beforeEach(^{ writeFile(F(@"%@_new", filePath)); });
                itDoesNotNotify();
            });

            context(@"when unrelated existing file changes in the same directory", ^{
                beforeEach(^{ changeFileNonAtomically(F(@"%@_existing", filePath)); });
                itDoesNotNotify();
            });
        });

        sharedExamplesFor(@"notifier that notices file changes non-atomically", ^(NSDictionary *_) {
            beforeEach(^{ resetDelegate(); });

            context(@"when file changes", ^{
                beforeEach(^{ changeFileNonAtomically(filePath); });
                itNotifies();
            });

            context(@"when file does not change", ^{
                itDoesNotNotify();
            });

            context(@"when unrelated new file is created in the same directory", ^{
                beforeEach(^{ writeFile(F(@"%@_new", filePath)); });
                itDoesNotNotify();
            });

            context(@"when unrelated existing file changes in the same directory", ^{
                beforeEach(^{ changeFileNonAtomically(F(@"%@_existing", filePath)); });
                itDoesNotNotify();
            });
        });

        sharedExamplesFor(@"notifier that notices file changes atomically", ^(NSDictionary *_) {
            beforeEach(^{ resetDelegate(); });

            context(@"when file changes", ^{
                beforeEach(^{ changeFileAtomically(filePath); });
                itNotifies();
            });

            context(@"when file does not change", ^{
                itDoesNotNotify();
            });

            context(@"when unrelated new file is created in the same directory", ^{
                beforeEach(^{ writeFile(F(@"%@_new", filePath)); });
                itDoesNotNotify();
            });

            context(@"when unrelated existing file changes in the same directory", ^{
                beforeEach(^{ changeFileAtomically(F(@"%@_existing", filePath)); });
                itDoesNotNotify();
            });
        });

        sharedExamplesFor(@"notifier that notices file deletion", ^(NSDictionary *_) {
            beforeEach(^{ resetDelegate(); });

            context(@"when file is deleted", ^{
                beforeEach(^{ deleteFile(filePath); });
                itShouldBehaveLike(@"notifier that notices file creation");
            });
        });

        context(@"when file does not exist before beginning to observe", ^{
            beforeEach(^{ [notifier startNotifying:delegate forFilePath:filePath]; });
            itShouldBehaveLike(@"notifier that notices file creation");
        });

        context(@"when file already exists before beginning to observe", ^{
            beforeEach(^{
                writeFile(filePath);
                [notifier startNotifying:delegate forFilePath:filePath];
            });

            itShouldBehaveLike(@"notifier that notices file changes atomically");
            itShouldBehaveLike(@"notifier that notices file changes non-atomically");
            itShouldBehaveLike(@"notifier that notices file deletion");
        });
    });
});

SPEC_END

NSString* createTmpDirectory() {
    NSString *directoryPath = F(@"/tmp/fs_changes_notifier_%d", rand());
    NSLog(@"Creating dir %@", directoryPath);
    NSError *error = nil;
    [[NSFileManager defaultManager]
        createDirectoryAtPath:directoryPath
        withIntermediateDirectories:YES attributes:nil error:&error];
    error should be_nil;
    return directoryPath;
};

void writeFile(NSString *_filePath) {
    NSLog(@"Creating file %@", _filePath);
    NSError *error = nil;
    [@"initial" writeToFile:_filePath atomically:YES encoding:NSASCIIStringEncoding error:&error];
    error should be_nil;
}

void _changeFile(NSString *_filePath, BOOL atomically) {
    sleep(1); // m/ctime has 1sec resolution
    NSLog(@"Changing file %@ (atomically=%d)", _filePath, atomically);
    NSError *error = nil;
    [@"changed" writeToFile:_filePath atomically:atomically encoding:NSASCIIStringEncoding error:&error];
    error should be_nil;
}

void changeFileAtomically(NSString *_filePath) { _changeFile(_filePath, YES); }
void changeFileNonAtomically(NSString *_filePath) { _changeFile(_filePath, NO); }

void deleteFile(NSString *_filePath) {
    NSLog(@"Deleting file %@", _filePath);
    NSError *error = nil;
    [NSFileManager.defaultManager removeItemAtPath:_filePath error:&error];
    error should be_nil;
}
