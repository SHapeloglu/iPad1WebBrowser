#import "LegacyBrowserViewController.h"

static NSString * const IP1UserAgentModeDefaultsKey = @"IP1UserAgentMode";
static NSString * const IP1LegacyGatewayDefaultsKeyAlpha4 = @"IP1LegacyGatewayBaseURL";

@interface LegacyBrowserViewController ()
- (void)loadHome;
- (void)showDiagnostics;
- (void)captureDiagnosticsForWebView:(UIWebView *)webView;
- (void)setUserAgentMode:(NSString *)mode;
@end

@implementation LegacyBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil] autorelease];
    UIBarButtonItem *info = [[[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showDiagnostics)] autorelease];

    NSMutableArray *items = [NSMutableArray arrayWithArray:_toolbar.items];
    [items addObject:space];
    [items addObject:info];
    _toolbar.items = items;
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
         "<p><a href='ipad1browser://debug'>Son sayfanın debug bilgisini göster</a></p>"
         "<p><a href='ipad1browser://setUA?mode=system'>Sistem / iPad User-Agent kullan</a><br/>"
         "<a href='ipad1browser://setUA?mode=desktop'>Masaüstü Safari User-Agent kullan</a></p>"
         "<p><a href='http://neverssl.com/'>HTTP test sayfasını aç</a></p>"
         "<p><a href='ipad1browser://gatewaySettings'>Legacy Gateway ayarları</a></p>"
         "<hr/>"
         "<p><small>Adres çubuğuna doğrudan URL yazabilirsiniz. Modern HTTPS/TLS veya JavaScript kullanan siteler iOS 5.1.1 sınırlarına takılabilir.</small></p>"
         "</body></html>", uaLabel, gatewayState];

    [_webView loadHTMLString:html baseURL:nil];
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    [self captureDiagnosticsForWebView:webView];
}

- (void)showDiagnostics {
    [self captureDiagnosticsForWebView:_webView];

    NSString *url = ([_lastDiagnosticURL length] > 0) ? _lastDiagnosticURL : @"(yok)";
    NSString *title = ([_lastDiagnosticTitle length] > 0) ? _lastDiagnosticTitle : @"(boş)";
    NSString *ua = ([_lastDiagnosticUserAgent length] > 0) ? _lastDiagnosticUserAgent : @"(alınamadı)";

    if ([ua length] > 280) {
        ua = [ua substringToIndex:280];
    }

    NSString *message = [NSString stringWithFormat:
        @"URL: %@\n\nTitle: %@\n\nHTML: %ld karakter\nBody: %ld karakter\n\nUser-Agent:\n%@",
        url,
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
            NSString *query = [url query];
            NSArray *pairs = [query componentsSeparatedByString:@"&"];
            NSEnumerator *enumerator = [pairs objectEnumerator];
            NSString *pair = nil;
            while ((pair = [enumerator nextObject]) != nil) {
                NSArray *parts = [pair componentsSeparatedByString:@"="];
                if ([parts count] == 2 && [[parts objectAtIndex:0] isEqualToString:@"mode"]) {
                    NSString *mode = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [self setUserAgentMode:mode];
                    return YES;
                }
            }
            return YES;
        }

        if ([host isEqualToString:@"home"]) {
            [self loadHome];
            return YES;
        }
    }

    return [super handleSuiteURL:url];
}

- (void)dealloc {
    [_lastDiagnosticURL release];
    [_lastDiagnosticTitle release];
    [_lastDiagnosticUserAgent release];
    [super dealloc];
}

@end
