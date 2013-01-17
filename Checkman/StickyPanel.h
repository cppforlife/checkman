#import <Cocoa/Cocoa.h>

@class Sticky;

@interface StickyPanel : NSPanel
- (id)initWithSticky:(Sticky *)sticky;
- (Sticky *)sticky;

- (void)showOnRightScreenEdge:(NSPoint)origin;
- (void)moveDownBy:(CGFloat)distance;
- (void)moveDownOffScreen;
@end
