#import "CheckCollection.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CheckCollectionSpec)

describe(@"CheckCollection", ^{
    __block CheckCollection *checks;

    beforeEach(^{
        checks = [[[CheckCollection alloc] init] autorelease];
    });

    describe(@"-status", ^{
        void (^addCheckWithStatus)(CheckStatus) = ^(CheckStatus s){
            Check *check = [[[Check alloc] init] autorelease];
            spy_on(check);

            check stub_method("status").and_return(s);
            [checks addCheck:check];
        };

        void (^addDisabledCheck)(void) = ^{
            Check *check = [[[Check alloc] init] autorelease];
            check.disabled = YES;
            [checks addCheck:check];
        };

        context(@"when collection contains succeeded, disabled, failed and undetermined", ^{
            it(@"returns undetermined because of undetermined", ^{
                addCheckWithStatus(CheckStatusOk);
                addDisabledCheck();
                addCheckWithStatus(CheckStatusFail);
                addCheckWithStatus(CheckStatusUndetermined);
                checks.status should equal(CheckStatusUndetermined);
            });
        });

        context(@"when collection contains succeeded, disabled and failed", ^{
            it(@"returns failed because of failed", ^{
                addCheckWithStatus(CheckStatusOk);
                addDisabledCheck();
                addCheckWithStatus(CheckStatusFail);
                checks.status should equal(CheckStatusFail);
            });
        });

        context(@"when collection contains succeeded, disabled", ^{
            it(@"returns succeeded (ignoring disabled)", ^{
                addCheckWithStatus(CheckStatusOk);
                addDisabledCheck();
                checks.status should equal(CheckStatusOk);
            });
        });

        context(@"when collection contains succeeded", ^{
            it(@"returns succeeded", ^{
                addCheckWithStatus(CheckStatusOk);
                checks.status should equal(CheckStatusOk);
            });
        });

        context(@"when collection contains disabled", ^{
            it(@"returns succeeded (ignoring disabled)", ^{
                addDisabledCheck();
                checks.status should equal(CheckStatusOk);
            });
        });

        context(@"when collection contains failed", ^{
            it(@"returns failed because of failed", ^{
                addCheckWithStatus(CheckStatusFail);
                checks.status should equal(CheckStatusFail);
            });
        });

        context(@"when collection contains undetermined", ^{
            it(@"returns succeeded because of undetermined", ^{
                addCheckWithStatus(CheckStatusUndetermined);
                checks.status should equal(CheckStatusUndetermined);
            });
        });

        context(@"when collection is empty", ^{
            it(@"returns undetermined", ^{
                checks.status should equal(CheckStatusUndetermined);
            });
        });
    });
});

SPEC_END
