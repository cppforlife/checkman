#import <Foundation/Foundation.h>

@class MenuController, StickiesController, NotificationsController, WebUI, Settings;

@interface CheckManager : NSObject

- (id)initWithMenuController:(MenuController *)menuController
          stickiesController:(StickiesController *)stickiesController
     notificationsController:(NotificationsController *)notificationsController
                       webUI:(WebUI *)webUI
                    settings:(Settings *)settings;

- (void)loadCheckfiles;
- (void)reloadCheckfiles;
@end
