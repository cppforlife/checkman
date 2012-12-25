#import <Foundation/Foundation.h>
#import "TaggedObject.h"
#import "CheckRun.h"

typedef enum {
    CheckStatusOk = 1,
    CheckStatusFail = 2,
    CheckStatusUndetermined = 0
} CheckStatus;

@interface Check : TaggedObject <CheckRunDelegate>

+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status changing:(BOOL)changing;

- (id)initWithName:(NSString *)name command:(NSString *)command directoryPath:(NSString *)directoryPath;

- (void)addObserverForRunning:(id)observer;
- (void)removeObserverForRunning:(id)observer;

- (void)startImmediately:(BOOL)immediately;
- (void)stop;
- (BOOL)isRunning;

- (CheckStatus)status;
- (BOOL)isChanging;

- (NSString *)name;
- (NSArray *)info;
- (NSURL *)url;
- (void)openUrl;
@end
