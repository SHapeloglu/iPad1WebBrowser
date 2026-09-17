#import "BrowserViewController.h"

@interface LegacyBrowserViewController : BrowserViewController {
    NSString *_lastDiagnosticURL;
    NSString *_lastDiagnosticTitle;
    NSString *_lastDiagnosticUserAgent;
    NSInteger _lastDiagnosticHTMLLength;
    NSInteger _lastDiagnosticBodyLength;
}

@end
