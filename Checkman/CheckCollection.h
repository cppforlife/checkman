#import <Foundation/Foundation.h>
#import "Check.h"

@class CheckCollection;

@protocol CheckCollectionDelegate <NSObject>
- (void)checkCollectionStatusAndChangingDidChange:(CheckCollection *)checks;
@end

@interface CheckCollection : NSObject

@property (nonatomic, assign) id<CheckCollectionDelegate> delegate;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;

- (NSUInteger)indexOfCheck:(Check *)check;
- (Check *)checkWithTag:(NSInteger)tag;

- (CheckStatus)status;
- (BOOL)isChanging;

- (NSString *)statusDescription;
- (NSString *)extendedStatusDescription;
@end
