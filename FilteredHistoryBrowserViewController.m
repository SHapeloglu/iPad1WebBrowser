#import "FilteredHistoryBrowserViewController.h"

static NSString * const IP1FilteredHistoryDefaultsKey = @"IP1History";

@interface LegacyBrowserViewController (FilteredHistoryHooks)
- (void)loadHome;
- (void)showHistoryPage;
@end

@interface FilteredHistoryBrowserViewController ()
- (BOOL)isTransientHistoryTitle:(NSString *)title;
- (void)cleanupTransientHistory;
@end

@implementation FilteredHistoryBrowserViewController

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

- (void)cleanupTransientHistory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stored = [defaults arrayForKey:IP1FilteredHistoryDefaultsKey];
    if ([stored count] == 0) {
        return;
    }

    NSMutableArray *cleaned = [NSMutableArray arrayWithCapacity:[stored count]];
    NSMutableSet *seenURLs = [NSMutableSet set];
    BOOL changed = NO;

    NSEnumerator *enumerator = [stored objectEnumerator];
    NSDictionary *entry = nil;
    while ((entry = [enumerator nextObject]) != nil) {
        NSString *url = [entry objectForKey:@"url"];
        NSString *title = [entry objectForKey:@"title"];

        if ([self isTransientHistoryTitle:title]) {
            changed = YES;
            continue;
        }

        if ([url length] > 0) {
            if ([seenURLs containsObject:url]) {
                changed = YES;
                continue;
            }
            [seenURLs addObject:url];
        }

        [cleaned addObject:entry];
    }

    if (changed) {
        [defaults setObject:cleaned forKey:IP1FilteredHistoryDefaultsKey];
        [defaults synchronize];
    }
}

- (void)viewDidLoad {
    [self cleanupTransientHistory];
    [super viewDidLoad];
}

- (void)loadHome {
    [self cleanupTransientHistory];
    [super loadHome];
}

- (void)showHistoryPage {
    [self cleanupTransientHistory];
    [super showHistoryPage];
}

@end
