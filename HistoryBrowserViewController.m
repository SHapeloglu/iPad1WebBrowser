#import "HistoryBrowserViewController.h"

static NSString * const IP1HistoryDefaultsKeyAlpha8 = @"IP1History";
static NSUInteger const IP1HistoryMaxItemsAlpha8 = 50;
static NSTimeInterval const IP1HistoryCommitDelayAlpha8 = 2.5;

@interface LegacyBrowserViewController (Alpha8Hooks)
- (void)loadHome;
- (void)showHistoryPage;
@end

@interface HistoryBrowserViewController ()
- (void)scheduleHistoryURL:(NSString *)url title:(NSString *)title;
- (void)commitPendingHistory;
- (void)captureInheritedDiagnosticsForWebView:(UIWebView *)webView;
- (BOOL)isTransientHistoryTitle:(NSString *)title;
- (void)cleanupStoredTransientHistory;
- (void)clearPendingHistory;
@end

@implementation HistoryBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cleanupStoredTransientHistory];
}

- (BOOL)isTransientHistoryTitle:(NSString *)title {
    if ([title length] == 0) {
        return NO;
    }

    NSString *lower = [title lowercaseString];
    static NSArray *markers = nil;
    if (markers == nil) {
        markers = [[NSArray alloc] initWithObjects:
                   @"connecting",
                   @"redirecting",
                   @"loading",
                   @"please wait",
                   @"just a moment",
                   @"bağlanıyor",
                   @"baglaniyor",
                   @"yönlendiriliyor",
                   @"yonlendiriliyor",
                   @"yükleniyor",
                   @"yukleniyor",
                   @"lütfen bekleyin",
                   @"lutfen bekleyin",
                   nil];
    }

    NSEnumerator *enumerator = [markers objectEnumerator];
    NSString *marker = nil;
    while ((marker = [enumerator nextObject]) != nil) {
        if ([lower rangeOfString:marker].location != NSNotFound) {
            return YES;
        }
    }

    return NO;
}

- (void)clearPendingHistory {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(commitPendingHistory)
                                               object:nil];

    [_pendingHistoryURL release];
    _pendingHistoryURL = nil;

    [_pendingHistoryTitle release];
    _pendingHistoryTitle = nil;
}

- (void)cleanupStoredTransientHistory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stored = [defaults arrayForKey:IP1HistoryDefaultsKeyAlpha8];
    if ([stored count] == 0) {
        return;
    }

    NSMutableArray *cleaned = [NSMutableArray arrayWithCapacity:[stored count]];
    NSEnumerator *enumerator = [stored objectEnumerator];
    NSDictionary *entry = nil;
    BOOL changed = NO;

    while ((entry = [enumerator nextObject]) != nil) {
        NSString *title = [entry objectForKey:@"title"];
        if ([self isTransientHistoryTitle:title]) {
            changed = YES;
            continue;
        }
        [cleaned addObject:entry];
    }

    if (changed) {
        [defaults setObject:cleaned forKey:IP1HistoryDefaultsKeyAlpha8];
        [defaults synchronize];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(commitPendingHistory)
                                               object:nil];
    [super webViewDidStartLoad:webView];
}

- (void)captureInheritedDiagnosticsForWebView:(UIWebView *)webView {
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"String(location.href || '')"];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"String(document.title || '')"];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"String(navigator.userAgent || '')"];
    NSString *htmlLength = [webView stringByEvaluatingJavaScriptFromString:@"String(document.documentElement ? document.documentElement.outerHTML.length : 0)"];
    NSString *bodyLength = [webView stringByEvaluatingJavaScriptFromString:@"String(document.body ? document.body.innerHTML.length : 0)"];

    [_lastDiagnosticURL release];
    _lastDiagnosticURL = [url copy];

    [_lastDiagnosticTitle release];
    _lastDiagnosticTitle = [title copy];

    [_lastDiagnosticUserAgent release];
    _lastDiagnosticUserAgent = [userAgent copy];

    _lastDiagnosticHTMLLength = [htmlLength integerValue];
    _lastDiagnosticBodyLength = [bodyLength integerValue];
    _lastLoadingState = [webView isLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *requestURL = [[webView request] URL];
    if (requestURL != nil) {
        NSString *scheme = [[requestURL scheme] lowercaseString];
        if (!([scheme isEqualToString:@"about"] && [_addressField.text length] > 0)) {
            _addressField.text = [requestURL absoluteString];
        }
    }

    _backButton.enabled = [webView canGoBack];
    _forwardButton.enabled = [webView canGoForward];
    _stopButton.enabled = [webView isLoading];

    [self captureInheritedDiagnosticsForWebView:webView];

    NSString *documentURL = [webView stringByEvaluatingJavaScriptFromString:@"String(location.href || '')"];
    NSURL *parsedURL = [NSURL URLWithString:documentURL];
    NSString *scheme = [[parsedURL scheme] lowercaseString];

    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        [_lastSuccessfulURL release];
        _lastSuccessfulURL = [documentURL copy];

        [_lastLoadError release];
        _lastLoadError = nil;

        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"String(document.title || '')"];
        [self scheduleHistoryURL:documentURL title:title];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self clearPendingHistory];
    [super webView:webView didFailLoadWithError:error];
}

- (void)scheduleHistoryURL:(NSString *)url title:(NSString *)title {
    if ([url length] == 0) {
        return;
    }

    if ([self isTransientHistoryTitle:title]) {
        [self clearPendingHistory];
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(commitPendingHistory)
                                               object:nil];

    [_pendingHistoryURL release];
    _pendingHistoryURL = [url copy];

    [_pendingHistoryTitle release];
    if ([title length] > 0) {
        _pendingHistoryTitle = [title copy];
    } else {
        _pendingHistoryTitle = [url copy];
    }

    [self performSelector:@selector(commitPendingHistory)
               withObject:nil
               afterDelay:IP1HistoryCommitDelayAlpha8];
}

- (void)commitPendingHistory {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(commitPendingHistory)
                                               object:nil];

    if ([_pendingHistoryURL length] == 0) {
        return;
    }

    if ([self isTransientHistoryTitle:_pendingHistoryTitle]) {
        [self clearPendingHistory];
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stored = [defaults arrayForKey:IP1HistoryDefaultsKeyAlpha8];
    NSMutableArray *items = [NSMutableArray arrayWithArray:(stored != nil ? stored : [NSArray array])];

    NSInteger index = (NSInteger)[items count] - 1;
    while (index >= 0) {
        NSDictionary *entry = [items objectAtIndex:(NSUInteger)index];
        if ([[entry objectForKey:@"url"] isEqualToString:_pendingHistoryURL]) {
            [items removeObjectAtIndex:(NSUInteger)index];
        }
        index--;
    }

    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                           _pendingHistoryURL, @"url",
                           ([_pendingHistoryTitle length] > 0 ? _pendingHistoryTitle : _pendingHistoryURL), @"title",
                           nil];
    [items insertObject:entry atIndex:0];

    while ([items count] > IP1HistoryMaxItemsAlpha8) {
        [items removeLastObject];
    }

    [defaults setObject:items forKey:IP1HistoryDefaultsKeyAlpha8];
    [defaults synchronize];

    [self clearPendingHistory];
}

- (void)loadHome {
    if (![self isTransientHistoryTitle:_pendingHistoryTitle]) {
        [self commitPendingHistory];
    } else {
        [self clearPendingHistory];
    }
    [super loadHome];
}

- (void)showHistoryPage {
    if (![self isTransientHistoryTitle:_pendingHistoryTitle]) {
        [self commitPendingHistory];
    } else {
        [self clearPendingHistory];
    }
    [self cleanupStoredTransientHistory];
    [super showHistoryPage];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_pendingHistoryURL release];
    [_pendingHistoryTitle release];
    [super dealloc];
}

@end
