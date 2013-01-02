#import <Foundation/Foundation.h>
#import "TaggedObject.h"

@class Checkfile, CheckfileEntry, FSChangesNotifier;

@protocol CheckfileDelegate <NSObject>
- (void)checkfile:(Checkfile *)checkfile didAddEntry:(CheckfileEntry *)entry;
- (void)checkfile:(Checkfile *)checkfile willRemoveEntry:(CheckfileEntry *)entry;
@end

@interface Checkfile : TaggedObject

@property (nonatomic, assign) id<CheckfileDelegate> delegate;

- (id)initWithFilePath:(NSString *)filePath
     fsChangesNotifier:(FSChangesNotifier *)fsChangesNotifier;

- (NSString *)name;
- (NSString *)resolvedDirectoryPath;

- (void)trackChanges;

- (NSArray *)entries;
- (NSUInteger)indexOfEntry:(CheckfileEntry *)entry;
@end
