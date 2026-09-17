#import "AppDelegate.h"
#import "RetryBrowserViewController.h"

static NSString * const IP1UserAgentModeDefaultsKey = @"IP1UserAgentMode";
static NSString * const IP1DesktopUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.50.2 (KHTML, like Gecko) Version/5.0 Safari/534.50.2";

@implementation AppDelegate

@synthesize window = _window;
@synthesize browserViewController = _browserViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mode = [defaults stringForKey:IP1UserAgentModeDefaultsKey];
    if ([mode isEqualToString:@"desktop"]) {
        [defaults setObject:IP1DesktopUserAgent forKey:@"UserAgent"];
    } else {
        [defaults removeObjectForKey:@"UserAgent"];
    }
    [defaults synchronize];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    self.browserViewController = [[[RetryBrowserViewController alloc] init] autorelease];
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
