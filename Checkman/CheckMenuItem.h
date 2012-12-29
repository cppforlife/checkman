#import <Cocoa/Cocoa.h>

@class CheckMenuItem, Check;

@protocol CheckMenuItemDelegate <NSObject>
- (void)checkMenuItemWasClicked:(CheckMenuItem *)item;
@end

@interface CheckMenuItem : NSMenuItem

@property (nonatomic, assign) id<CheckMenuItemDelegate> delegate;

- (id)initWithCheck:(Check *)check;
- (Check *)check;
@end
