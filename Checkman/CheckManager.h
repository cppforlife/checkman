#import <Foundation/Foundation.h>

@class MenuController, Settings;

@interface CheckManager : NSObject
- (id)initWithMenuController:(MenuController *)menuController settings:(Settings *)settings;
- (void)loadCheckfiles;
- (void)reloadCheckfiles;
@end
