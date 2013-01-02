#import <Foundation/Foundation.h>

@class CheckfileCollection, Checkfile;

@protocol CheckfileCollectionDelegate <NSObject>
- (void)checkfileCollection:(CheckfileCollection *)collection
            didAddCheckfile:(Checkfile *)checkfile;

- (void)checkfileCollection:(CheckfileCollection *)collection
        willRemoveCheckfile:(Checkfile *)checkfile;
@end

@interface CheckfileCollection : NSObject

@property (nonatomic, assign) id<CheckfileCollectionDelegate> delegate;

+ (CheckfileCollection *)collectionFromCheckmanUserDirectoryPath;

- (id)initWithDirectoryPath:(NSString *)directoryPath;

- (void)trackChanges;
- (void)reloadFiles;

- (NSArray *)files;
- (NSUInteger)indexOfCheckfile:(Checkfile *)checkfile;
@end
