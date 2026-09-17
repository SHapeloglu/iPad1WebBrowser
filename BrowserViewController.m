#import "BrowserViewController.h"

static NSString * const IP1HomeURLString = @"https://www.google.com/";
static NSString * const IP1DownloaderScheme = @"ipad1downloader";
static NSString * const IP1LegacyGatewayDefaultsKey = @"IP1LegacyGatewayBaseURL";
static NSInteger const IP1LegacyGatewayAlertTag = 3001;

@interface BrowserViewController ()
- (void)loadHome;
- (void)loadAddressText:(NSString *)text;
- (NSURL *)URLForUserText:(NSString *)text;
- (void)updateNavigationState;
- (BOOL)isExternalSchemeURL:(NSURL *)url;
- (BOOL)isLikelyDownloadURL:(NSURL *)url;
- (BOOL)tryHandoffDownloadURL:(NSURL *)url;
- (NSString *)queryValueForKey:(NSString *)key URL:(NSURL *)url;
- (NSString *)percentEscapeQueryValue:(NSString *)value;
- (NSString *)HTMLSafeString:(NSString *)value;
- (NSString *)legacyGatewayBaseURLString;
- (void)openThroughLegacyGateway:(NSString *)target;
- (void)promptForLegacyGatewayWithTarget:(NSString *)target;
@end

@implementation BrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    CGRect bounds = self.view.bounds;

    _addressBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, 44.0f)];
    _addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _addressBar.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
    [self.view addSubview:_addressBar];

    _addressField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 7.0f, bounds.size.width - 16.0f, 30.0f)];
    _addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _addressField.borderStyle = UITextBorderStyleRoundedRect;
    _addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _addressField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _addressField.autocorrectionType = UITextAutocorrectionTypeNo;
    _addressField.keyboardType = UIKeyboardTypeURL;
    _addressField.returnKeyType = UIReturnKeyGo;
    _addressField.delegate = self;
    _addressField.placeholder = @"Adres veya arama";
    [_addressBar addSubview:_addressField];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f,
                                                           44.0f,
                                                           bounds.size.width,
                                                           bounds.size.height - 88.0f)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:_webView];

    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                           bounds.size.height - 44.0f,
                                                           bounds.size.width,
                                                           44.0f)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    _backButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
                                                   style:UIBarButtonItemStylePlain
                                                  target:_webView
                                                  action:@selector(goBack)];
    _forwardButton = [[UIBarButtonItem alloc] initWithTitle:@">"
                                                      style:UIBarButtonItemStylePlain
                                                     target:_webView
                                                     action:@selector(goForward)];
    _reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                  target:_webView
                                                                  action:@selector(reload)];
    _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                target:_webView
                                                                action:@selector(stopLoading)];
    _homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(loadHome)];

    UIBarButtonItem *space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil] autorelease];
    UIBarButtonItem *space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil] autorelease];
    UIBarButtonItem *space3 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil] autorelease];
    UIBarButtonItem *space4 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil] autorelease];

    _toolbar.items = [NSArray arrayWithObjects:_backButton, space1,
                       _forwardButton, space2,
                       _reloadButton, space3,
                       _stopButton, space4,
                       _homeButton, nil];
    [self.view addSubview:_toolbar];

    [self updateNavigationState];

    if (!_initialPageLoaded) {
        _initialPageLoaded = YES;
        [self loadHome];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)loadHome {
    [self loadAddressText:IP1HomeURLString];
}

- (void)loadAddressText:(NSString *)text {
    NSURL *url = [self URLForUserText:text];
    if (url == nil) {
        return;
    }

    if ([self isLikelyDownloadURL:url] && [self tryHandoffDownloadURL:url]) {
        return;
    }

    _addressField.text = [url absoluteString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    [_webView loadRequest:request];
}

- (NSURL *)URLForUserText:(NSString *)text {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] == 0) {
        return nil;
    }

    NSRange schemeRange = [trimmed rangeOfString:@"://"];
    if (schemeRange.location != NSNotFound) {
        return [NSURL URLWithString:[trimmed stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    BOOL hasWhitespace = ([trimmed rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound);
    BOOL looksLikeHost = ([trimmed rangeOfString:@"."].location != NSNotFound ||
                          [trimmed hasPrefix:@"localhost"] ||
                          [trimmed hasPrefix:@"192.168."] ||
                          [trimmed hasPrefix:@"10."] ||
                          [trimmed hasPrefix:@"172."]);

    if (!hasWhitespace && looksLikeHost) {
        NSString *urlString = [@"http://" stringByAppendingString:trimmed];
        return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *escaped = [self percentEscapeQueryValue:trimmed];
    NSString *searchURL = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", escaped];
    return [NSURL URLWithString:searchURL];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loadAddressText:textField.text];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)isExternalSchemeURL:(NSURL *)url {
    NSString *scheme = [[url scheme] lowercaseString];
    if (scheme == nil) {
        return NO;
    }

    return !([scheme isEqualToString:@"http"] ||
             [scheme isEqualToString:@"https"] ||
             [scheme isEqualToString:@"file"] ||
             [scheme isEqualToString:@"about"] ||
             [scheme isEqualToString:@"data"] ||
             [scheme isEqualToString:@"ipad1browser"]);
}

- (BOOL)isLikelyDownloadURL:(NSURL *)url {
    NSString *scheme = [[url scheme] lowercaseString];
    if (!([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        return NO;
    }

    NSString *extension = [[[url path] pathExtension] lowercaseString];
    if ([extension length] == 0) {
        return NO;
    }

    static NSArray *downloadExtensions = nil;
    if (downloadExtensions == nil) {
        downloadExtensions = [[NSArray alloc] initWithObjects:
            @"pdf", @"zip", @"rar", @"7z", @"tar", @"gz", @"bz2",
            @"mkv", @"mp4", @"m4v", @"mov", @"avi", @"mp3", @"aac", @"m4a", @"wav",
            @"ipa", @"deb", @"dmg", @"exe", @"msi",
            @"doc", @"docx", @"xls", @"xlsx", @"ppt", @"pptx",
            @"csv", @"json", @"xml", @"sql", @"txt", @"log",
            nil];
    }

    return [downloadExtensions containsObject:extension];
}

- (BOOL)tryHandoffDownloadURL:(NSURL *)url {
    NSString *absolute = [url absoluteString];
    NSString *escaped = [self percentEscapeQueryValue:absolute];
    NSString *handoffString = [NSString stringWithFormat:@"%@://download?url=%@", IP1DownloaderScheme, escaped];
    NSURL *handoffURL = [NSURL URLWithString:handoffString];

    UIApplication *application = [UIApplication sharedApplication];
    if (handoffURL != nil && [application canOpenURL:handoffURL]) {
        return [application openURL:handoffURL];
    }

    return NO;
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if (url == nil) {
        return YES;
    }

    if ([[[url scheme] lowercaseString] isEqualToString:@"ipad1browser"]) {
        [self handleSuiteURL:url];
        return NO;
    }

    if ([self isExternalSchemeURL:url]) {
        UIApplication *application = [UIApplication sharedApplication];
        if ([application canOpenURL:url]) {
            [application openURL:url];
        }
        return NO;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked &&
        [self isLikelyDownloadURL:url] &&
        [self tryHandoffDownloadURL:url]) {
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateNavigationState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *url = [[[webView request] URL] retain];
    if (url != nil) {
        NSString *scheme = [[url scheme] lowercaseString];
        if (!([scheme isEqualToString:@"about"] && [_addressField.text length] > 0)) {
            _addressField.text = [url absoluteString];
        }
    }
    [url release];
    [self updateNavigationState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] == NSURLErrorCancelled) {
        return;
    }

    [self updateNavigationState];

    NSURL *failedURL = [[webView request] URL];
    NSString *target = [failedURL absoluteString];
    if ([target length] == 0 || [[failedURL scheme] isEqualToString:@"about"]) {
        target = _addressField.text;
    }
    if ([target length] > 0) {
        _addressField.text = target;
    }

    NSString *escapedDescription = [self HTMLSafeString:[error localizedDescription]];
    NSString *gatewayBlock = @"";
    NSURL *targetURL = [NSURL URLWithString:target];
    NSString *targetScheme = [[targetURL scheme] lowercaseString];
    if ([target length] > 0 && ([targetScheme isEqualToString:@"http"] || [targetScheme isEqualToString:@"https"])) {
        NSString *escapedTarget = [self percentEscapeQueryValue:target];
        gatewayBlock = [NSString stringWithFormat:
            @"<p><a style='display:inline-block;padding:10px 14px;background:#ddd;border:1px solid #aaa;text-decoration:none;color:#111' href='ipad1browser://legacy?url=%@'>Legacy Gateway ile Aç</a></p>"
             "<p><a href='ipad1browser://gatewaySettings'>Gateway adresini ayarla/değiştir</a></p>", escapedTarget];
    }

    NSString *html = [NSString stringWithFormat:
        @"<html><head><meta name='viewport' content='width=device-width'/></head>"
         "<body style='font-family:Helvetica;padding:24px'>"
         "<h2>Sayfa açılamadı</h2><p>%@</p>"
         "<p><small>Hata kodu: %ld. iOS 5.1.1 bazı modern TLS, sertifika ve JavaScript yapılarını desteklemez.</small></p>"
         "%@"
         "<p><small>Legacy Gateway yalnızca halka açık/read-only sayfalar için önerilir. Giriş, parola veya hassas veri kullanmayın.</small></p>"
         "</body></html>", escapedDescription, (long)[error code], gatewayBlock];
    [webView loadHTMLString:html baseURL:nil];
}

- (void)updateNavigationState {
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
    _stopButton.enabled = [_webView isLoading];
}

- (NSString *)percentEscapeQueryValue:(NSString *)value {
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

- (NSString *)HTMLSafeString:(NSString *)value {
    if (value == nil) {
        return @"";
    }

    NSString *result = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return result;
}

- (NSString *)queryValueForKey:(NSString *)key URL:(NSURL *)url {
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

- (NSString *)legacyGatewayBaseURLString {
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:IP1LegacyGatewayDefaultsKey];
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)openThroughLegacyGateway:(NSString *)target {
    if ([target length] == 0) {
        return;
    }

    NSString *base = [self legacyGatewayBaseURLString];
    if ([base length] == 0) {
        [self promptForLegacyGatewayWithTarget:target];
        return;
    }

    NSString *separator = @"?";
    if ([base rangeOfString:@"?"].location != NSNotFound) {
        if ([base hasSuffix:@"?"] || [base hasSuffix:@"&"]) {
            separator = @"";
        } else {
            separator = @"&";
        }
    }

    NSString *escapedTarget = [self percentEscapeQueryValue:target];
    NSString *gatewayURLString = [NSString stringWithFormat:@"%@%@url=%@", base, separator, escapedTarget];
    NSURL *gatewayURL = [NSURL URLWithString:gatewayURLString];
    if (gatewayURL == nil) {
        return;
    }

    _addressField.text = target;
    NSURLRequest *request = [NSURLRequest requestWithURL:gatewayURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:45.0];
    [_webView loadRequest:request];
}

- (void)promptForLegacyGatewayWithTarget:(NSString *)target {
    [_pendingLegacyURL release];
    _pendingLegacyURL = [target copy];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Legacy Gateway"
                                                    message:@"Contabo gateway adresini girin. Örnek: http://SUNUCU_IP:8091/proxy?token=...\n\nHTTP şifreli değildir; yalnızca halka açık sayfalarda kullanın."
                                                   delegate:self
                                          cancelButtonTitle:@"Vazgeç"
                                          otherButtonTitles:@"Kaydet", nil] autorelease];
    alert.tag = IP1LegacyGatewayAlertTag;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [alert textFieldAtIndex:0];
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.keyboardType = UIKeyboardTypeURL;
    NSString *existing = [self legacyGatewayBaseURLString];
    if ([existing length] > 0) {
        field.text = existing;
    } else {
        field.placeholder = @"http://SUNUCU_IP:8091/proxy?token=...";
    }
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != IP1LegacyGatewayAlertTag || buttonIndex == alertView.cancelButtonIndex) {
        return;
    }

    NSString *value = [[[alertView textFieldAtIndex:0] text]
                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![value hasPrefix:@"http://"]) {
        UIAlertView *warning = [[[UIAlertView alloc] initWithTitle:@"Geçersiz Gateway"
                                                          message:@"Legacy Gateway adresi http:// ile başlamalıdır. iOS 5'in modern HTTPS/TLS sorunu nedeniyle gateway bağlantısı özellikle HTTP olarak tasarlanmıştır."
                                                         delegate:nil
                                                cancelButtonTitle:@"Tamam"
                                                otherButtonTitles:nil] autorelease];
        [warning show];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:value forKey:IP1LegacyGatewayDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *target = [[_pendingLegacyURL retain] autorelease];
    [_pendingLegacyURL release];
    _pendingLegacyURL = nil;
    if ([target length] > 0) {
        [self openThroughLegacyGateway:target];
    }
}

- (BOOL)handleSuiteURL:(NSURL *)url {
    if (url == nil || ![[[url scheme] lowercaseString] isEqualToString:@"ipad1browser"]) {
        return NO;
    }

    NSString *host = [[url host] lowercaseString];
    if ([host isEqualToString:@"open"]) {
        NSString *target = [self queryValueForKey:@"url" URL:url];
        if ([target length] == 0) {
            return NO;
        }

        _initialPageLoaded = YES;
        if ([self isViewLoaded]) {
            [self loadAddressText:target];
        } else {
            [self view];
            [self loadAddressText:target];
        }
        return YES;
    }

    if ([host isEqualToString:@"legacy"]) {
        NSString *target = [self queryValueForKey:@"url" URL:url];
        if ([target length] == 0) {
            return NO;
        }
        [self openThroughLegacyGateway:target];
        return YES;
    }

    if ([host isEqualToString:@"gatewaysettings"]) {
        [self promptForLegacyGatewayWithTarget:nil];
        return YES;
    }

    return NO;
}

- (void)releaseMemoryIfPossible {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)viewDidUnload {
    _webView.delegate = nil;
    _addressField.delegate = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    _webView.delegate = nil;
    _addressField.delegate = nil;

    [_pendingLegacyURL release];
    [_homeButton release];
    [_stopButton release];
    [_reloadButton release];
    [_forwardButton release];
    [_backButton release];

    [_toolbar release];
    [_webView release];
    [_addressField release];
    [_addressBar release];

    [super dealloc];
}

@end
