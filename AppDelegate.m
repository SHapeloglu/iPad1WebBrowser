#import "AppDelegate.h"
#import "BrowserViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize browserViewController = _browserViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    self.browserViewController = [[[BrowserViewController alloc] init] autorelease];
    self.window.rootViewController = self.browserViewController;
    [self.window makeKeyAndVisible];

    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (launchURL != nil) {
        [self.browserViewController handleSuiteURL:launchURL];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.browserViewController handleSuiteURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [self.browserViewController handleSuiteURL:url];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [self.browserViewController releaseMemoryIfPossible];
}

- (void)dealloc {
    [_browserViewController release];
    [_window release];
    [super dealloc];
}

@end
