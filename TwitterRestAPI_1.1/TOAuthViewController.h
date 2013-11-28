#import <UIKit/UIKit.h>

/*!
 @discussion 
 Контроллер авторизации пользователя. В контроллер передается временный токен, полученный методом TRequestToken, пользователь проходит авторизацию и получает постоянный токен и verifier, который нужно подтвердить методом TAccessToken.
 */

extern NSString *const kOAuthVerifier;

typedef NS_ENUM(NSUInteger, TOAuthViewControllerState)
{
    TOAuthViewControllerStateComlete  = 1 << 0,
    TOAuthViewControllerStateCancel   = 1 << 1
};

typedef void(^TOAuthViewControllerDidFinishVerifierHandler)(TOAuthViewControllerState state, NSDictionary *params);


@interface TOAuthViewController : UIViewController

@property (nonatomic, copy) TOAuthViewControllerDidFinishVerifierHandler didFinishAuthHandler;

@property (nonatomic, strong, readonly) NSString *accessToken;

- (id)initWithAccessToken:(NSString *)token;

@end


@interface TOAuthViewController (Unavailable)

- (id)init __attribute__((unavailable("init not available! Use initWithAccessToken:")));
+ (id)new __attribute__((unavailable("new not available! Use initWithAccessToken:")));
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil __attribute__((unavailable("initWithNibName:bundle: not available! Use initWithAccessToken:")));

@end
