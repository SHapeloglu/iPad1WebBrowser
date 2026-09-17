#import "LegacyBrowserViewController.h"

static NSString * const IP1UserAgentModeDefaultsKey = @"IP1UserAgentMode";
static NSString * const IP1LegacyGatewayDefaultsKeyAlpha4 = @"IP1LegacyGatewayBaseURL";
static NSString * const IP1LegacyCompatHeader = @"X-iPad1-Legacy-Compat";
static NSString * const IP1BookmarksDefaultsKey = @"IP1Bookmarks";
static NSString * const IP1HistoryDefaultsKey = @"IP1History";
static NSUInteger const IP1MaxBookmarks = 100;
static NSUInteger const IP1MaxHistory = 50;

@interface LegacyBrowserViewController ()
- (void)loadHome;
- (void)showDiagnostics;
- (void)captureDiagnosticsForWebView:(UIWebView *)webView;
- (void)setUserAgentMode:(NSString *)mode;
- (void)rememberRequestedURL:(NSURL *)url;
- (NSArray *)bookmarks;
- (NSArray *)history;
- (void)saveBookmarks:(NSArray *)items;
- (void)saveHistory:(NSArray *)items;
- (void)addCurrentBookmark;
- (void)rememberHistoryURL:(NSString *)url title:(NSString *)title;
- (void)showBookmarksPage;
- (void)showHistoryPage;
- (void)clearHistory;
- (void)removeBookmarkURL:(NSString *)url;
- (NSString *)localHTMLSafeString:(NSString *)value;
- (NSString *)localPercentEscape:(NSString *)value;
- (NSString *)localQueryValueForKey:(NSString *)key URL:(NSURL *)url;
@end

@implementation LegacyBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil] autorelease];
    UIBarButtonItem *bookmark = [[[UIBarButtonItem alloc] initWithTitle:@"Yer İmi"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(addCurrentBookmark)] autorelease];
    UIBarButtonItem *history = [[[UIBarButtonItem alloc] initWithTitle:@"Geçmiş"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showHistoryPage)] autorelease];
    UIBarButtonItem *info = [[[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showDiagnostics)] autorelease];

    NSMutableArray *items = [NSMutableArray arrayWithArray:_toolbar.items];
    [items addObject:space];
    [items addObject:bookmark];
    [items addObject:history];
    [items addObject:info];
    _toolbar.items = items;
}

- (NSArray *)bookmarks {
    NSArray *items = [[NSUserDefaults standardUserDefaults] arrayForKey:IP1BookmarksDefaultsKey];
    return (items != nil) ? items : [NSArray array];
}

- (NSArray *)history {
    NSArray *items = [[NSUserDefaults standardUserDefaults] arrayForKey:IP1HistoryDefaultsKey];
    return (items != nil) ? items : [NSArray array];
}

- (void)saveBookmarks:(NSArray *)items {
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:IP1BookmarksDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveHistory:(NSArray *)items {
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:IP1HistoryDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)localHTMLSafeString:(NSString *)value {
    if (value == nil) {
        return @"";
    }
    NSString *result = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    result = [result stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"];
    return result;
}

- (NSString *)localPercentEscape:(NSString *)value {
    if (value == nil) {
        return @"";
    }
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)value,
                                                                  NULL,
                                                                  CFSTR(":/?#[]@!$&'()*+,;="),
                                                                  kCFStringEncodingUTF8);
    return [(NSString *)escaped autorelease];
}

- (NSString *)localQueryValueForKey:(NSString *)key URL:(NSURL *)url {
    NSString *query = [url query];
    if ([query length] == 0) {
        return nil;
    }

    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSEnumerator *enumerator = [pairs objectEnumerator];
    NSString *pair = nil;
    while ((pair = [enumerator nextObject]) != nil) {
        NSRange separator = [pair rangeOfString:@"="];
        NSString *rawKey = nil;
        NSString *rawValue = @"";
        if (separator.location == NSNotFound) {
            rawKey = pair;
        } else {
            rawKey = [pair substringToIndex:separator.location];
            rawValue = [pair substringFromIndex:separator.location + 1];
        }

        NSString *decodedKey = [rawKey stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([decodedKey isEqualToString:key]) {
            NSString *plusFixed = [rawValue stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            return [plusFixed stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

- (void)loadHome {
    NSString *mode = [[NSUserDefaults standardUserDefaults] stringForKey:IP1UserAgentModeDefaultsKey];
    if ([mode length] == 0) {
        mode = @"system";
    }

    NSString *gateway = [[NSUserDefaults standardUserDefaults] stringForKey:IP1LegacyGatewayDefaultsKeyAlpha4];
    NSString *gatewayState = ([gateway length] > 0) ? @"Ayarlı" : @"Kapalı";
    NSString *uaLabel = [mode isEqualToString:@"desktop"] ? @"Masaüstü Safari" : @"Sistem / iPad";

    _addressField.text = @"about:home";

    NSString *html = [NSString stringWithFormat:
        @"<html><head><meta name='viewport' content='width=device-width'/></head>"
         "<body style='font-family:Helvetica;padding:24px;color:#222'>"
         "<h2>iPad1 WebBrowser</h2>"
         "<p>iOS 5.1.1 için hafif tarayıcı.</p>"
         "<hr/>"
         "<p><b>User-Agent:</b> %@</p>"
         "<p><b>Legacy Gateway:</b> %@</p>"
         "<p><b>HTTP uyumluluk:</b> Connection: close + identity</p>"
         "<p><b>Yer İmleri:</b> %lu &nbsp; <b>Geçmiş:</b> %lu</p>"
         "<p><a href='ipad1browser://bookmarks'>Yer İmlerini Aç</a><br/>"
         "<a href='ipad1browser://history'>Geçmişi Aç</a><br/>"
         "<a href='ipad1browser://addBookmark'>Bu sayfayı Yer İmlerine ekle</a></p>"
         "<p><a href='ipad1browser://debug'>Son sayfanın debug bilgisini göster</a></p>"
         "<p><a href='ipad1browser://setUA?mode=system'>Sistem / iPad User-Agent kullan</a><br/>"
         "<a href='ipad1browser://setUA?mode=desktop'>Masaüstü Safari User-Agent kullan</a></p>"
         "<p><a href='http://neverssl.com/'>HTTP test sayfasını aç</a></p>"
         "<p><a href='ipad1browser://gatewaySettings'>Legacy Gateway ayarları</a></p>"
         "<hr/>"
         "<p><small>Adres çubuğuna doğrudan URL yazabilirsiniz. Modern HTTPS/TLS veya JavaScript kullanan siteler iOS 5.1.1 sınırlarına takılabilir.</small></p>"
         "</body></html>",
        uaLabel,
        gatewayState,
        (unsigned long)[[self bookmarks] count],
        (unsigned long)[[self history] count]];

    [_webView loadHTMLString:html baseURL:nil];
}

- (void)addCurrentBookmark {
    NSString *url = [_webView stringByEvaluatingJavaScriptFromString:@"String(location.href || '')"];
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"String(document.title || '')"];
    NSURL *parsed = [NSURL URLWithString:url];
    NSString *scheme = [[parsed scheme] lowercaseString];

    if (!([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Yer İmi"
                                                        message:@"Yalnızca gerçek web sayfaları Yer İmlerine eklenebilir."
                                                       delegate:nil
                                              cancelButtonTitle:@"Tamam"
                                              otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }

    if ([title length] == 0) {
        title = url;
    }

    NSMutableArray *items = [NSMutableArray arrayWithArray:[self bookmarks]];
    NSInteger index = [items count] - 1;
    while (index >= 0) {
        NSDictionary *entry = [items objectAtIndex:(NSUInteger)index];
        if ([[entry objectForKey:@"url"] isEqualToString:url]) {
            [items removeObjectAtIndex:(NSUInteger)index];
        }
        index--;
    }

    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                           url, @"url",
                           title, @"title",
                           nil];
    [items insertObject:entry atIndex:0];
    while ([items count] > IP1MaxBookmarks) {
        [items removeLastObject];
    }
    [self saveBookmarks:items];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Yer İmi"
                                                    message:@"Sayfa Yer İmlerine eklendi."
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)rememberHistoryURL:(NSString *)url title:(NSString *)title {
    if ([url length] == 0) {
        return;
    }
    NSURL *parsed = [NSURL URLWithString:url];
    NSString *scheme = [[parsed scheme] lowercaseString];
    if (!([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        return;
    }

    if ([title length] == 0) {
        title = url;
    }

    NSMutableArray *items = [NSMutableArray arrayWithArray:[self history]];
    NSInteger index = [items count] - 1;
    while (index >= 0) {
        NSDictionary *entry = [items objectAtIndex:(NSUInteger)index];
        if ([[entry objectForKey:@"url"] isEqualToString:url]) {
            [items removeObjectAtIndex:(NSUInteger)index];
        }
        index--;
    }

    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                           url, @"url",
                           title, @"title",
                           nil];
    [items insertObject:entry atIndex:0];
    while ([items count] > IP1MaxHistory) {
        [items removeLastObject];
    }
    [self saveHistory:items];
}

- (void)showBookmarksPage {
    NSArray *items = [self bookmarks];
    NSMutableString *html = [NSMutableString stringWithString:
        @"<html><head><meta name='viewport' content='width=device-width'/></head>"
         "<body style='font-family:Helvetica;padding:24px;color:#222'>"
         "<h2>Yer İmleri</h2>"
         "<p><a href='ipad1browser://home'>Ana Sayfa</a></p><hr/>"];

    if ([items count] == 0) {
        [html appendString:@"<p>Henüz Yer İmi yok.</p>"];
    } else {
        NSEnumerator *enumerator = [items objectEnumerator];
        NSDictionary *entry = nil;
        while ((entry = [enumerator nextObject]) != nil) {
            NSString *url = [entry objectForKey:@"url"];
            NSString *title = [entry objectForKey:@"title"];
            NSString *safeURL = [self localHTMLSafeString:url];
            NSString *safeTitle = [self localHTMLSafeString:title];
            NSString *encodedURL = [self localPercentEscape:url];
            [html appendFormat:
                @"<p><a href=\"%@\"><b>%@</b></a><br/><small>%@</small><br/>"
                 "<a href='ipad1browser://removeBookmark?url=%@'>Sil</a></p><hr/>",
                safeURL, safeTitle, safeURL, encodedURL];
        }
    }

    [html appendString:@"</body></html>"];
    _addressField.text = @"about:bookmarks";
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)showHistoryPage {
    NSArray *items = [self history];
    NSMutableString *html = [NSMutableString stringWithString:
        @"<html><head><meta name='viewport' content='width=device-width'/></head>"
         "<body style='font-family:Helvetica;padding:24px;color:#222'>"
         "<h2>Geçmiş</h2>"
         "<p><a href='ipad1browser://home'>Ana Sayfa</a> &nbsp; "
         "<a href='ipad1browser://clearHistory'>Geçmişi Temizle</a></p><hr/>"];

    if ([items count] == 0) {
        [html appendString:@"<p>Geçmiş boş.</p>"];
    } else {
        NSEnumerator *enumerator = [items objectEnumerator];
        NSDictionary *entry = nil;
        while ((entry = [enumerator nextObject]) != nil) {
            NSString *url = [entry objectForKey:@"url"];
            NSString *title = [entry objectForKey:@"title"];
            NSString *safeURL = [self localHTMLSafeString:url];
            NSString *safeTitle = [self localHTMLSafeString:title];
            [html appendFormat:@"<p><a href=\"%@\"><b>%@</b></a><br/><small>%@</small></p><hr/>",
                               safeURL, safeTitle, safeURL];
        }
    }

    [html appendString:@"</body></html>"];
    _addressField.text = @"about:history";
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)clearHistory {
    [self saveHistory:[NSArray array]];
    [self showHistoryPage];
}

- (void)removeBookmarkURL:(NSString *)url {
    if ([url length] == 0) {
        return;
    }
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self bookmarks]];
    NSInteger index = [items count] - 1;
    while (index >= 0) {
        NSDictionary *entry = [items objectAtIndex:(NSUInteger)index];
        if ([[entry objectForKey:@"url"] isEqualToString:url]) {
            [items removeObjectAtIndex:(NSUInteger)index];
        }
        index--;
    }
    [self saveBookmarks:items];
    [self showBookmarksPage];
}

- (void)rememberRequestedURL:(NSURL *)url {
    if (url == nil) {
        return;
    }

    NSString *scheme = [[url scheme] lowercaseString];
    if (!([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        return;
    }

    [_requestedURL release];
    _requestedURL = [[url absoluteString] copy];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    BOOL allowedByBase = [super webView:webView
                    shouldStartLoadWithRequest:request
                               navigationType:navigationType];
    if (!allowedByBase) {
        return NO;
    }

    NSURL *url = [request URL];
    [self rememberRequestedURL:url];

    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme isEqualToString:@"http"] &&
        ![[request valueForHTTPHeaderField:IP1LegacyCompatHeader] isEqualToString:@"1"]) {

        NSMutableURLRequest *legacyRequest = [[request mutableCopy] autorelease];
        [legacyRequest setValue:@"1" forHTTPHeaderField:IP1LegacyCompatHeader];
        [legacyRequest setValue:@"close" forHTTPHeaderField:@"Connection"];
        [legacyRequest setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];
        [legacyRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [legacyRequest setTimeoutInterval:30.0];

        [_webView loadRequest:legacyRequest];
        return NO;
    }

    return YES;
}

- (void)captureDiagnosticsForWebView:(UIWebView *)webView {
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    _lastLoadingState = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    [self captureDiagnosticsForWebView:webView];

    NSURL *url = [[webView request] URL];
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        [_lastSuccessfulURL release];
        _lastSuccessfulURL = [[url absoluteString] copy];
        [_lastLoadError release];
        _lastLoadError = nil;

        NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"String(document.title || '')"];
        [self rememberHistoryURL:[url absoluteString] title:title];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _lastLoadingState = [webView isLoading];

    [_lastLoadError release];
    _lastLoadError = [[NSString stringWithFormat:@"%@ (kod: %ld)",
                       [error localizedDescription],
                       (long)[error code]] copy];

    [super webView:webView didFailLoadWithError:error];
}

- (void)showDiagnostics {
    [self captureDiagnosticsForWebView:_webView];

    NSString *requested = ([_requestedURL length] > 0) ? _requestedURL : @"(yok)";
    NSString *current = ([_lastDiagnosticURL length] > 0) ? _lastDiagnosticURL : @"(yok)";
    NSString *title = ([_lastDiagnosticTitle length] > 0) ? _lastDiagnosticTitle : @"(boş)";
    NSString *success = ([_lastSuccessfulURL length] > 0) ? _lastSuccessfulURL : @"(yok)";
    NSString *lastError = ([_lastLoadError length] > 0) ? _lastLoadError : @"(yok)";
    NSString *ua = ([_lastDiagnosticUserAgent length] > 0) ? _lastDiagnosticUserAgent : @"(alınamadı)";

    if ([ua length] > 240) {
        ua = [ua substringToIndex:240];
    }

    NSString *message = [NSString stringWithFormat:
        @"Requested URL:\n%@\n\nCurrent URL:\n%@\n\nLoading: %@\nLast success:\n%@\n\nLast error:\n%@\n\nTitle: %@\nHTML: %ld\nBody: %ld\n\nUser-Agent:\n%@",
        requested,
        current,
        [_webView isLoading] ? @"YES" : @"NO",
        success,
        lastError,
        title,
        (long)_lastDiagnosticHTMLLength,
        (long)_lastDiagnosticBodyLength,
        ua];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sayfa Debug Bilgisi"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)setUserAgentMode:(NSString *)mode {
    if (!([mode isEqualToString:@"system"] || [mode isEqualToString:@"desktop"])) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:mode forKey:IP1UserAgentModeDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *label = [mode isEqualToString:@"desktop"] ? @"Masaüstü Safari" : @"Sistem / iPad";
    NSString *message = [NSString stringWithFormat:
        @"User-Agent modu '%@' olarak kaydedildi. Değişikliğin kesin uygulanması için uygulamayı tamamen kapatıp yeniden açın.", label];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"User-Agent"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (BOOL)handleSuiteURL:(NSURL *)url {
    if (url != nil && [[[url scheme] lowercaseString] isEqualToString:@"ipad1browser"]) {
        NSString *host = [[url host] lowercaseString];

        if ([host isEqualToString:@"debug"]) {
            [self showDiagnostics];
            return YES;
        }

        if ([host isEqualToString:@"setua"]) {
            NSString *mode = [self localQueryValueForKey:@"mode" URL:url];
            if ([mode length] > 0) {
                [self setUserAgentMode:mode];
            }
            return YES;
        }

        if ([host isEqualToString:@"home"]) {
            [self loadHome];
            return YES;
        }

        if ([host isEqualToString:@"bookmarks"]) {
            [self showBookmarksPage];
            return YES;
        }

        if ([host isEqualToString:@"history"]) {
            [self showHistoryPage];
            return YES;
        }

        if ([host isEqualToString:@"addbookmark"]) {
            [self addCurrentBookmark];
            return YES;
        }

        if ([host isEqualToString:@"clearhistory"]) {
            [self clearHistory];
            return YES;
        }

        if ([host isEqualToString:@"removebookmark"]) {
            NSString *target = [self localQueryValueForKey:@"url" URL:url];
            [self removeBookmarkURL:target];
            return YES;
        }
    }

    return [super handleSuiteURL:url];
}

- (void)dealloc {
    [_requestedURL release];
    [_lastSuccessfulURL release];
    [_lastLoadError release];
    [_lastDiagnosticURL release];
    [_lastDiagnosticTitle release];
    [_lastDiagnosticUserAgent release];
    [super dealloc];
}

@end
