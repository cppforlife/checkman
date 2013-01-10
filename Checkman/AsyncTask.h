#import <Foundation/Foundation.h>

@class AsyncTask;

@protocol AsyncTaskDelegate <NSObject>
// Will be executed on the thread started by -run.
- (void)asyncTaskDidComplete:(AsyncTask *)task;
@end

@interface AsyncTask : NSObject

@property (nonatomic, assign) id<AsyncTaskDelegate> delegate;

- (void)setLaunchPath:(NSString *)launchPath;
- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath;
- (void)setArguments:(NSArray *)arguments;

// Runs task on a separate thread in a non-blocking manner.
- (void)run;

- (NSData *)stdOutData;
- (NSData *)stdErrData;
@end

@interface AsyncTask (Bash)
+ (AsyncTask *)bashTaskWithCommand:(NSString *)command
    directoryPath:(NSString *)directoryPath;
@end

@interface AsyncTask (Command)
- (NSString *)executedCommand;
@end
