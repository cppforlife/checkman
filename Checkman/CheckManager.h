#import <Foundation/Foundation.h>

@class MenuController, StickiesController, NotificationsController, Settings;

@interface CheckManager : NSObject

- (id)initWithMenuController:(MenuController *)menuController
          stickiesController:(StickiesController *)stickiesController
     notificationsController:(NotificationsController *)notificationsController
                    settings:(Settings *)settings;

- (void)loadCheckfiles;
- (void)reloadCheckfiles;
@end
