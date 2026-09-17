#import "BrowserViewController.h"

static NSString * const IP1HomeURLString = @"https://www.google.com/";
static NSString * const IP1DownloaderScheme = @"ipad1downloader";

@interface BrowserViewController ()
- (void)loadHome;
- (void)loadAddressText:(NSString *)text;
- (NSURL *)URLForUserText:(NSString *)text;
- (void)updateNavigationState;
- (BOOL)isExternalSchemeURL:(NSURL *)url;
- (BOOL)isLikelyDownloadURL:(NSURL *)url;
- (BOOL)tryHandoffDownloadURL:(NSURL *)url;
- (NSString *)queryValueForKey:(NSString *)key URL:(NSURL *)url;
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

    NSString *escaped = [trimmed stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
             [scheme isEqualToString:@"data"]);
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
    NSString *escaped = [absolute stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        _addressField.text = [url absoluteString];
    }
    [url release];
    [self updateNavigationState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] == NSURLErrorCancelled) {
        return;
    }

    [self updateNavigationState];

    NSString *escapedDescription = [[error localizedDescription]
                                    stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    escapedDescription = [escapedDescription stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    escapedDescription = [escapedDescription stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];

    NSString *html = [NSString stringWithFormat:
        @"<html><head><meta name='viewport' content='width=device-width'/></head>"
         "<body style='font-family:Helvetica;padding:24px'>"
         "<h2>Sayfa açılamadı</h2><p>%@</p>"
         "<p><small>iOS 5.1.1 modern TLS, sertifika ve JavaScript kullanan bazı siteleri açamayabilir.</small></p>"
         "</body></html>", escapedDescription];
    [webView loadHTMLString:html baseURL:nil];
}

- (void)updateNavigationState {
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
    _stopButton.enabled = [_webView isLoading];
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

- (BOOL)handleSuiteURL:(NSURL *)url {
    if (url == nil || ![[[url scheme] lowercaseString] isEqualToString:@"ipad1browser"]) {
        return NO;
    }

    NSString *host = [[url host] lowercaseString];
    if (![host isEqualToString:@"open"]) {
        return NO;
    }

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
