#import "BrowserViewController.h"

@interface LegacyBrowserViewController : BrowserViewController {
    NSString *_lastDiagnosticURL;
    NSString *_lastDiagnosticTitle;
    NSString *_lastDiagnosticUserAgent;
    NSInteger _lastDiagnosticHTMLLength;
    NSInteger _lastDiagnosticBodyLength;

    NSString *_requestedURL;
    NSString *_lastSuccessfulURL;
    NSString *_lastLoadError;
    BOOL _lastLoadingState;
}

@end
