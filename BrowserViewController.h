#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
    UIView *_addressBar;
    UITextField *_addressField;
    UIWebView *_webView;
    UIToolbar *_toolbar;

    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_reloadButton;
    UIBarButtonItem *_stopButton;
    UIBarButtonItem *_homeButton;

    BOOL _initialPageLoaded;
}

- (BOOL)handleSuiteURL:(NSURL *)url;
- (void)releaseMemoryIfPossible;

@end
