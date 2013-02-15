#import <Foundation/Foundation.h>

@class NSCustomTicker;

@protocol NSCustomTickerDelegate <NSObject>
- (void)customTickerDidTick:(NSCustomTicker *)ticker;
@end

@interface NSCustomTicker : NSObject
@property (nonatomic, assign) id<NSCustomTickerDelegate> delegate;
- (id)initWithInterval:(NSTimeInterval)interval;
@end
