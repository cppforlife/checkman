#import <Foundation/Foundation.h>
#import "TaggedObject.h"

typedef enum {
    CheckStatusOk = 99,
    CheckStatusFail = 98,
    CheckStatusUndetermined = 97
} CheckStatus;

@class Check;

@protocol CheckDelegate <NSObject>
- (void)checkDidChangeStatus:(NSNotification *)notification;
- (void)checkDidChangeChanging:(NSNotification *)notification;
- (void)checkDidChangeRunning:(NSNotification *)notification;
@end

@interface Check : TaggedObject

@property (nonatomic, strong) NSString *primaryContextName;
@property (nonatomic, strong) NSString *secondaryContextName;

@property (nonatomic, assign) NSUInteger runInterval;
@property (nonatomic, assign, getter = isDisabled) BOOL disabled;

- (id)initWithName:(NSString *)name
           command:(NSString *)command
     directoryPath:(NSString *)directoryPath;

- (NSString *)name;
- (NSString *)command;

- (void)startImmediately:(BOOL)immediately;
- (void)stop;
- (BOOL)isRunning;
- (BOOL)isAfterFirstRun;

- (CheckStatus)status;
- (BOOL)isChanging;

- (NSArray *)info;
- (NSURL *)url;
@end

@interface Check (Observers)
- (void)addObserver:(id<CheckDelegate>)observer;
- (void)removeObserver:(id<CheckDelegate>)observer;
@end

@interface Check (Image)
+ (NSString *)statusImageNameForCheckStatus:(CheckStatus)status changing:(BOOL)changing;
@end

@interface Check (Notification)
- (NSString *)statusNotificationName;
- (NSString *)statusNotificationStatus;
- (NSString *)statusNotificationText;
- (NSColor *)statusNotificationColor;
@end

@interface Check (Debugging)
- (NSString *)executedCommand;
- (NSString *)stdOut;
- (NSString *)stdErr;
@end
