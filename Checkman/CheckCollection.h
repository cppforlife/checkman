#import <Foundation/Foundation.h>
#import "Check.h"

@class CheckCollection;

@protocol CheckCollectionDelegate <NSObject>
- (void)checkCollection:(CheckCollection *)checks didAddCheck:(Check *)check;
- (void)checkCollection:(CheckCollection *)checks willRemoveCheck:(Check *)check;
- (void)checkCollectionStatusAndChangingDidChange:(CheckCollection *)checks;
@end

@interface CheckCollection : NSObject

@property (nonatomic, assign) id<CheckCollectionDelegate> delegate;

- (void)addCheck:(Check *)check;
- (void)removeCheck:(Check *)check;

- (NSUInteger)indexOfCheck:(Check *)check;
- (Check *)checkWithTag:(NSInteger)tag;

- (CheckStatus)status;
- (NSString *)statusDescription;
- (BOOL)isChanging;
@end
