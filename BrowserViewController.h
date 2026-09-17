#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    UIView *_addressBar;
    UITextField *_addressField;
    UIWebView *_webView;
    UIToolbar *_toolbar;

    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_reloadButton;
    UIBarButtonItem *_stopButton;
    UIBarButtonItem *_homeButton;

    NSString *_pendingLegacyURL;
    BOOL _initialPageLoaded;
}

- (BOOL)handleSuiteURL:(NSURL *)url;
- (void)releaseMemoryIfPossible;

@end
