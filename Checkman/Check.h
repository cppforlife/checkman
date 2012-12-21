#import <Foundation/Foundation.h>
#import "TaggedObject.h"

typedef enum {
    CheckStatusOk = 1,
    CheckStatusFail = 2,
    CheckStatusUndetermined = 0
} CheckStatus;

@interface Check : TaggedObject

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status running:(BOOL)running;

- (id)initWithName:(NSString *)name command:(NSString *)command directoryPath:(NSString *)directoryPath;

- (void)addObserverForStatusAndRunning:(id)observer;
- (void)removeObserverForStatusAndRunning:(id)observer;

- (NSString *)name;
- (NSArray *)info;
- (CheckStatus)status;

- (NSURL *)url;
- (void)openUrl;

- (void)start;
- (void)stop;
- (BOOL)isRunning;
@end
