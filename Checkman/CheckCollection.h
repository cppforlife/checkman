#import <Foundation/Foundation.h>
#import "Check.h"

@class CheckCollection;

@protocol CheckCollectionDelegate <NSObject>
- (void)checkCollection:(CheckCollection *)collection
    didUpdateStatusFromCheck:(Check *)check;

- (void)checkCollection:(CheckCollection *)collection
    didUpdateChangingFromCheck:(Check *)check;

@optional
- (void)checkCollection:(CheckCollection *)collection
    checkDidChangeStatus:(Check *)check;

- (void)checkCollection:(CheckCollection *)collection
   checkDidChangeChanging:(Check *)check;
@end

@interface CheckCollection : NSObject <NSFastEnumeration>

@property (nonatomic, assign) id<CheckCollectionDelegate> delegate;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;

- (NSUInteger)indexOfCheck:(Check *)check;
- (Check *)checkWithTag:(NSInteger)tag;

- (CheckStatus)status;
- (BOOL)isChanging;

- (NSString *)statusDescription;
- (NSString *)extendedStatusDescription;

- (NSUInteger)numberOfDisabledChecks;
- (NSUInteger)count;
@end
