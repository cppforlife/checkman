#import "WebUIMessages.h"
#import "CheckCollection.h"
#import "Check.h"

@implementation WebUIMessages

#pragma mark - Heart beat

- (NSString *)heartBeatJSONMessage:(CheckCollection *)checks {
    NSDictionary *jsonObject =
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"heartbeat", @"type",
            [NSNumber numberWithUnsignedInteger:checks.count],
                @"total_checks_count",
            [NSNumber numberWithUnsignedInteger:checks.numberOfDisabledChecks],
                @"disabled_checks_count", nil];
    NSData *data =
        [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - For check

- (NSString *)showCheckJSONMessage:(Check *)check {
    return [self _checkJSONMessage:check type:@"check.show"];
}

- (NSString *)hideCheckJSONMessage:(Check *)check {
    return [self _checkJSONMessage:check type:@"check.hide"];
}

static inline id _WUObjOrNull(id value) {
    return value ? value : [NSNull null];
}

- (NSString *)_checkJSONMessage:(Check *)check type:(NSString *)type {
    NSDictionary *jsonCheckObject =
        [NSDictionary dictionaryWithObjectsAndKeys:
            check.tagAsNumber, @"id",
            _WUObjOrNull(check.name), @"name",
            _WUObjOrNull(check.primaryContextName), @"primary_context_name",
            _WUObjOrNull(check.secondaryContextName), @"secondary_context_name",
            _WUObjOrNull(check.statusNotificationStatus), @"status",
            [NSNumber numberWithBool:check.isChanging], @"changing",
            [NSNumber numberWithBool:check.isDisabled], @"disabled", nil];
    NSDictionary *jsonObject =
        [NSDictionary dictionaryWithObjectsAndKeys:
            type, @"type",
            jsonCheckObject, @"check", nil];
    NSData *data =
        [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
