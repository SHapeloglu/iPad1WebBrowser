#import <UIKit/UIKit.h>

@class BrowserViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    BrowserViewController *_browserViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) BrowserViewController *browserViewController;

@end
