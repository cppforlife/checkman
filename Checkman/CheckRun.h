#import <Foundation/Foundation.h>

@class CheckRun;

@protocol CheckRunDelegate <NSObject>
- (void)checkRunDidFinish:(CheckRun *)run;
@end

@interface CheckRun : NSObject

@property (nonatomic, assign) id<CheckRunDelegate> delegate;

- (id)initWithCommand:(NSString *)command
        directoryPath:(NSString *)directoryPath;

- (void)start;
- (BOOL)isValid;

- (BOOL)isSuccessful;
- (BOOL)isChanging;
- (NSURL *)url;
- (NSArray *)info;
@end

@interface CheckRun (Debugging)
- (NSString *)executedCommand;
- (NSString *)stdOut;
- (NSString *)stdErr;
@end
