#import "TOAuthViewController.h"

#import "TwitterRequests.h"

NSString *const kOAuthVerifier = @"oauth_verifier";

@interface TOAuthViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TOAuthViewController

- (id)initWithAccessToken:(NSString *)token
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:self
                                        options:nil] lastObject];
    if (self)
    {
        _accessToken = token;
        
        NSString *urlStr = [[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url
                                                   cachePolicy:NSURLCacheStorageNotAllowed
                                               timeoutInterval:TIMEOUT_INTERVAL]];
    }
    return self;
}

#pragma mark - cancel

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.didFinishAuthHandler)
    {
        self.didFinishAuthHandler(TOAuthViewControllerStateCancel, nil);
    }
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType;
{    
    NSString *urlStr = [request.URL absoluteString];
    if ([urlStr hasPrefix:@"twrestapp"])
    {        
        NSString *prefix = [NSString stringWithFormat:@"%@?", oauth_callback];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:prefix withString:@""];
        
        NSArray *paramsSeparated = [urlStr componentsSeparatedByString:@"&"];
        
        NSString *accsessToken = [[[paramsSeparated objectAtIndex:0] componentsSeparatedByString:@"="] lastObject];
        NSString *verifier = [[[paramsSeparated objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
        
        NSDictionary *params = @{kOAuthAccsessToken : accsessToken,
                                 kOAuthVerifier     : verifier};
        if (self.didFinishAuthHandler)
        {
            self.didFinishAuthHandler(TOAuthViewControllerStateComlete, params);
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
