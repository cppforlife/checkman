#import <Foundation/Foundation.h>

@class MenuController;

@interface CheckManager : NSObject
- (id)initWithMenuController:(MenuController *)menuController;
- (void)loadCheckfiles;
@end
