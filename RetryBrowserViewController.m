#import "RetryBrowserViewController.h"

static NSString * const IP1LegacyCompatHeaderAlpha9 = @"X-iPad1-Legacy-Compat";
static NSString * const IP1LegacyRetryHeaderAlpha9 = @"X-iPad1-Legacy-Retry";

@implementation RetryBrowserViewController

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];

    [_lastRetriedURL release];
    _lastRetriedURL = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] == NSURLErrorTimedOut) {
        NSURL *failedURL = [[webView request] URL];
        NSString *target = [failedURL absoluteString];
        NSString *scheme = [[failedURL scheme] lowercaseString];

        if (!([scheme isEqualToString:@"http"] && [target length] > 0)) {
            NSURL *requested = [NSURL URLWithString:_requestedURL];
            NSString *requestedScheme = [[requested scheme] lowercaseString];
            if ([requestedScheme isEqualToString:@"http"] && [_requestedURL length] > 0) {
                failedURL = requested;
                target = _requestedURL;
                scheme = requestedScheme;
            }
        }

        if ([scheme isEqualToString:@"http"] &&
            [target length] > 0 &&
            ![_lastRetriedURL isEqualToString:target]) {

            [_lastRetriedURL release];
            _lastRetriedURL = [target copy];

            NSMutableURLRequest *retryRequest = [NSMutableURLRequest requestWithURL:failedURL
                                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                     timeoutInterval:45.0];
            [retryRequest setValue:@"1" forHTTPHeaderField:IP1LegacyCompatHeaderAlpha9];
            [retryRequest setValue:@"1" forHTTPHeaderField:IP1LegacyRetryHeaderAlpha9];
            [retryRequest setValue:@"close" forHTTPHeaderField:@"Connection"];
            [retryRequest setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];
            [retryRequest setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];

            _addressField.text = target;
            [_webView loadRequest:retryRequest];
            return;
        }
    }

    [super webView:webView didFailLoadWithError:error];
}

- (void)dealloc {
    [_lastRetriedURL release];
    [super dealloc];
}

@end
