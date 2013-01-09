#import <Foundation/Foundation.h>

@class MenuController, NotificationsController, Settings;

@interface CheckManager : NSObject

- (id)initWithMenuController:(MenuController *)menuController
     notificationsController:(NotificationsController *)notificationsController
                    settings:(Settings *)settings;

- (void)loadCheckfiles;
- (void)reloadCheckfiles;
@end
