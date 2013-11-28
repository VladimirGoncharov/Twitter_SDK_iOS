#import "TwitterRequests.h"

NSString *const TURLRequestHTTPMethodGET                    = @"GET";
NSString *const TURLRequestHTTPMethodPOST                   = @"POST";

NSString *const TContentTypeApplication_XWWWFormURLEncoden  = @"application/x-www-form-urlencoded";
NSString *const TContentTypeMultipart_FormData              = @"multipart/form-data";

NSString *const kOAuthAuthorization                         = @"Authorization";
NSString *const kOAuthCallback                              = @"oauth_callback";
NSString *const kOAuthConsumerKey                           = @"oauth_consumer_key";
NSString *const kOAuthNonce                                 = @"oauth_nonce";
NSString *const kOAuthSignature                             = @"oauth_signature";
NSString *const kOAuthSignatureMethod                       = @"oauth_signature_method";
NSString *const kOAuthTimestamp                             = @"oauth_timestamp";
NSString *const kOAuthAccsessToken                          = @"oauth_token";
NSString *const kOAuthAccsessTokenSecret                    = @"oauth_access_token_secret";
NSString *const kOAuthVersion                               = @"oauth_version";

NSString *const oauth_callback                              = @"twrestapp://callback.ru";

static NSString *const oauth_consumer_key                   = @"US0b0QyFSXjKXSvzpZ4OQw";
static NSString *const oauth_consumer_secret                = @"EU8i4NjIDM3JEF5yv4sQMGP2qeYLGsRiNiFsrBE2pRQ";
static NSString *const oauth_signature_method               = @"HMAC-SHA1";
static NSString *const oauth_version                        = @"1.0";

static inline NSString *timestamp()
{
    return [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
}

static inline NSString *nonce()
{
    NSString *uniqueString = [[[NSProcessInfo processInfo] globallyUniqueString] substringToIndex:32];
    uniqueString = [[uniqueString base64EncodedString] substringToIndex:32];
    return uniqueString;
}

static inline id prepareParam(id param)
{
    if ([param isMemberOfClass:[NSString class]] ||
        [param isKindOfClass:[NSString class]])
    {
        param = [param stringByAddingPercentEscapes];
    }
    
    return param;
}

#pragma mark - NSMutableURLRequest+Params

@interface NSMutableURLRequest (Params)

- (void)setInRequestParams:(NSDictionary *)params;

@end

@implementation NSMutableURLRequest (Params)

- (void)setInRequestParams:(NSDictionary *)params
{
    if ([params count] > 0)
    {
        if ([self.HTTPMethod isEqualToString:TURLRequestHTTPMethodPOST])
        {
            if ([[[self allHTTPHeaderFields] objectForKey:@"Content-Type"] isEqualToString:TContentTypeApplication_XWWWFormURLEncoden])
            {
                NSMutableString *valueParams = [NSMutableString new];
                
                for (NSString *key in params)
                {
                    id value = [params valueForKey:key];
                    value = prepareParam(value);
                    
                    [valueParams appendFormat:@"%@=%@&", key, value];
                }
                
                [valueParams replaceCharactersInRange:NSMakeRange([valueParams length] - 1, 1) withString:@""];
                
                NSData *body = [valueParams dataUsingEncoding:NSASCIIStringEncoding];
                
                [self setValue:[NSString stringWithFormat:@"%d",[body length]] forHTTPHeaderField:@"Content-Length"];
                
                [self setHTTPBody:body];
            }
            else if ([[[self allHTTPHeaderFields] objectForKey:@"Content-Type"] isEqualToString:TContentTypeMultipart_FormData])
            {                
                NSMutableData *postData = [NSMutableData data];
                
                NSString *boundary = @"---------------------------14737809831466499882746641449";
                
                for (NSString *key in params)
                {
                    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    id postValue = [params valueForKey:key];
                    
                    if ([postValue isMemberOfClass:[NSString class]] ||
                        [postValue isKindOfClass:[NSString class]])
                    {
                        [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name= \"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                        [postData appendData:[postValue dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    else
                        if ([postValue isMemberOfClass:[NSNumber class]] ||
                            [postValue isKindOfClass:[NSNumber class]] )
                        {
                            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name= \"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                            [postData appendData:[[postValue stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
                        }
                }
                
                if ([self conformsToProtocol:@protocol(TImagesProtocol)])
                {
                    TRequest <TImagesProtocol>*request_t_p = (TRequest <TImagesProtocol>*)self;
                    NSArray *imagesArray = request_t_p.media;
                    NSString *fieldName = request_t_p.nameFieldImages;

                    for (UIImage *image in imagesArray)
                    {
                        NSString *uniqueFileName = [[NSProcessInfo processInfo] globallyUniqueString] ;

                        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

                        [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",
                                               fieldName,
                                               uniqueFileName] dataUsingEncoding:NSUTF8StringEncoding]];
                        [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [postData appendData:UIImageJPEGRepresentation(image, 1.0)];
                    }
                }
                
                [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

                [self setValue:[NSString stringWithFormat:@"%@; boundary=%@",TContentTypeMultipart_FormData, boundary]
                  forHTTPHeaderField:@"Content-Type"];
                [self setHTTPBody:postData];        
            }
        }
        else if ([self.HTTPMethod isEqualToString:TURLRequestHTTPMethodGET])
        {
            NSMutableString *url_str = [[self.URL absoluteString] mutableCopy];
            
            if ([params count] > 0)
            {
                [url_str appendString:@"?"];
                
                for (NSString *key in params)
                {
                    id value = [params valueForKey:key];
                    value = prepareParam(value);
                    
                    [url_str appendFormat:@"%@=%@&", key, value];
                }
                
                [url_str replaceCharactersInRange:NSMakeRange([url_str length] - 1, 1) withString:@""];
                
                [self setURL:[NSURL URLWithString:[[url_str copy] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
            }
        }
    }
}

@end

#pragma mark - TRequestToken

@implementation TRequestToken

- (id)init
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/oauth/request_token" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                  cachePolicy:NSURLCacheStorageNotAllowed
              timeoutInterval:TIMEOUT_INTERVAL];
    if (self)
    {
        [self setHTTPMethod:TURLRequestHTTPMethodPOST];
        [self setValue:TContentTypeApplication_XWWWFormURLEncoden forHTTPHeaderField:@"Content-Type"];
        [self _prepareHeader];
    }
    return self;
}

- (void)_prepareHeader
{
    _timestamp = timestamp();
    _nonce = nonce();
    _signature = [self _signature];
    NSString *authHeader = [self _authHeader];
    [self addValue:authHeader forHTTPHeaderField:kOAuthAuthorization];
}

- (NSString *)_signature
{
    NSString *method_type = [self HTTPMethod];
    NSString *method_address = [[self.URL absoluteString] stringByAddingPercentEscapes];
    NSString *method_params =
    [[NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
      kOAuthCallback,
      [oauth_callback stringByAddingPercentEscapes],
      kOAuthConsumerKey,
      oauth_consumer_key,
      kOAuthNonce,
      self.nonce,
      kOAuthSignatureMethod,
      oauth_signature_method,
      kOAuthTimestamp,
      self.timestamp,
      kOAuthVersion,
      oauth_version] stringByAddingPercentEscapes];
    
    NSString *secretKey = [NSString stringWithFormat:@"%@&", oauth_consumer_secret];
    
    NSString *signature = [NSString stringWithFormat:@"%@&%@&%@", method_type, method_address, method_params];
    signature = [[signature HMAC_SHA1_x64:secretKey] stringByAddingPercentEscapes];
    
    return signature;
}

- (NSString *)_authHeader
{
    NSString *authHeader = [NSString stringWithFormat:@"OAuth %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\"",
                            kOAuthCallback,
                            [oauth_callback stringByAddingPercentEscapes],
                            kOAuthConsumerKey,
                            oauth_consumer_key,
                            kOAuthSignatureMethod,
                            oauth_signature_method,
                            kOAuthSignature,
                            self.signature,
                            kOAuthTimestamp,
                            self.timestamp,
                            kOAuthNonce,
                            self.nonce,
                            kOAuthVersion,
                            oauth_version];
    return authHeader;
}

@end

#pragma mark - TAccessToken

@implementation TAccessToken

- (id)initWithVerifier:(NSString *)verifier
           accessToken:(NSString *)accessToken
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/oauth/access_token" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                  cachePolicy:NSURLCacheStorageNotAllowed
              timeoutInterval:TIMEOUT_INTERVAL];
    if (self)
    {
        [self setHTTPMethod:TURLRequestHTTPMethodPOST];
        [self setValue:TContentTypeApplication_XWWWFormURLEncoden forHTTPHeaderField:@"Content-Type"];
        
        _verifier = verifier;
        _accessToken = accessToken;
        
        [self _prepareHeader];
        
        NSDictionary *params = @{kOAuthVerifier: verifier};
        [self setInRequestParams:params];
    }
    return self;
}

- (void)_prepareHeader
{
    _timestamp = timestamp();
    _nonce = nonce();
    _signature = [self _signature];
    NSString *authHeader = [self _authHeader];
    [self addValue:authHeader forHTTPHeaderField:kOAuthAuthorization];
}

- (NSString *)_signature
{
    NSString *method_type = [self HTTPMethod];
    NSString *method_address = [[self.URL absoluteString] stringByAddingPercentEscapes];
    NSString *method_params =
    [[NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
      kOAuthConsumerKey,
      oauth_consumer_key,
      kOAuthNonce,
      self.nonce,
      kOAuthSignatureMethod,
      oauth_signature_method,
      kOAuthTimestamp,
      self.timestamp,
      kOAuthAccsessToken,
      self.accessToken,
      kOAuthVerifier,
      self.verifier,
      kOAuthVersion,
      oauth_version] stringByAddingPercentEscapes];
    
    NSString *secretKey = [NSString stringWithFormat:@"%@&", oauth_consumer_secret];
    
    NSString *signature = [NSString stringWithFormat:@"%@&%@&%@", method_type, method_address, method_params];
    signature = [[signature HMAC_SHA1_x64:secretKey] stringByAddingPercentEscapes];
    
    return signature;
}

- (NSString *)_authHeader
{
    NSString *authHeader = [NSString stringWithFormat:@"OAuth %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\"",
                            kOAuthConsumerKey,
                            oauth_consumer_key,
                            kOAuthNonce,
                            self.nonce,
                            kOAuthSignatureMethod,
                            oauth_signature_method,
                            kOAuthTimestamp,
                            self.timestamp,
                            kOAuthSignature,
                            self.signature,
                            kOAuthAccsessToken,
                            self.accessToken,
                            kOAuthVersion,
                            oauth_version];
    return authHeader;
}

@end

#pragma mark - TRequest

@interface TRequest()

@property (nonatomic, strong) NSMutableDictionary *params;

@property (nonatomic, strong) NSString *signature;

@end

@implementation TRequest

- (id)initWithURL:(NSURL *)URL
       httpMethod:(NSString *)httpMethod
      contentType:(NSString *)contentType
{
    self = [super initWithURL:URL
                  cachePolicy:NSURLCacheStorageNotAllowed
              timeoutInterval:TIMEOUT_INTERVAL];
    if (self)
    {
        [self setHTTPMethod:httpMethod];
        [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        self.params = [NSMutableDictionary new];
    }
    return self;
}

- (void)prepareRequest
{
    [self _prepareHeader];
    
    [self setInRequestParams:self.params];
}

- (void)_prepareHeader
{
    _timestamp = timestamp();
    _nonce = nonce();
    self.signature = [self _signature];
    NSString *authHeader = [self _authHeader];
    [self addValue:authHeader forHTTPHeaderField:kOAuthAuthorization];
}

- (NSString *)_signature
{        
    NSString *method_type = [self HTTPMethod];
    NSString *method_address = [[self.URL absoluteString] stringByAddingPercentEscapes];
    
    NSMutableDictionary *method_params = [NSMutableDictionary new];
    
    if ([[[self allHTTPHeaderFields] objectForKey:@"Content-Type"] isEqualToString:TContentTypeApplication_XWWWFormURLEncoden])
    {
        for (NSString *key in self.params)
        {
            id value = [self.params objectForKey:key];
            value = prepareParam(value);
            
            [method_params setValue:value
                             forKey:key];
        }
    }
    
    [method_params setValue:oauth_consumer_key forKey:kOAuthConsumerKey];
    [method_params setValue:self.nonce forKey:kOAuthNonce];
    [method_params setValue:oauth_signature_method forKey:kOAuthSignatureMethod];
    [method_params setValue:self.timestamp forKey:kOAuthTimestamp];
    [method_params setValue:self.accessToken forKey:kOAuthAccsessToken];
    [method_params setValue:oauth_version forKey:kOAuthVersion];
       
    NSArray *sortedKeys = [[method_params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString *method_params_str = [NSMutableString new];
    for (NSString *key in sortedKeys)
    {
        NSString *value = [method_params objectForKey:key];
        [method_params_str appendFormat:@"%@=%@&", key, value];
    }
        
    [method_params_str replaceCharactersInRange:NSMakeRange([method_params_str length] - 1, 1) withString:@""];
    
    method_params_str = [[method_params_str stringByAddingPercentEscapes] mutableCopy];
    
    NSString *secretKey = [NSString stringWithFormat:@"%@&%@", oauth_consumer_secret, self.accessSecretToken];
    
    NSString *signature = [NSString stringWithFormat:@"%@&%@&%@", method_type, method_address, method_params_str];
    signature = [[signature HMAC_SHA1_x64:secretKey] stringByAddingPercentEscapes];
    
    return signature;
}

- (NSString *)_authHeader
{    
    NSString *authHeader = [NSString stringWithFormat:@"OAuth %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\", %@=\"%@\"",
                            kOAuthConsumerKey,
                            oauth_consumer_key,
                            kOAuthNonce,
                            self.nonce,
                            kOAuthSignature,
                            self.signature,
                            kOAuthSignatureMethod,
                            oauth_signature_method,
                            kOAuthTimestamp,
                            self.timestamp,
                            kOAuthAccsessToken,
                            self.accessToken,
                            kOAuthVersion,
                            oauth_version];
    return authHeader;
}

@end

#pragma mark - TRequestStatusesUpdate

@implementation TRequestStatusesUpdate

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   status:(NSString *)status
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/statuses/update.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodPOST
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.status = status;
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
    }
    return self;
}

- (void)setStatus:(NSString *)status
{
    _status = status;
    [self.params setValue:status forKey:@"status"];
}

- (void)setInReplyToStatusId:(NSNumber *)inReplyToStatusId
{
    _inReplyToStatusId = inReplyToStatusId;
    [self.params setValue:inReplyToStatusId forKey:@"in_reply_to_status_id"];
}

- (void)setLatitude:(NSNumber *)latitude
{
    _latitude = latitude;
    [self.params setValue:latitude forKey:@"lat"];
}

- (void)setLongitude:(NSNumber *)longitude
{
    _longitude = longitude;
    [self.params setValue:longitude forKey:@"long"];
}

- (void)setPlaceId:(NSString *)placeId
{
    _placeId = placeId;
    [self.params setValue:placeId forKey:@"place_id"];
}

- (void)setDisplayCoordinates:(NSNumber *)displayCoordinates
{
    _displayCoordinates = displayCoordinates;
    [self.params setValue:displayCoordinates forKey:@"display_coordinates"];
}

- (void)setTrim_user:(NSNumber *)trim_user
{
    _trim_user = trim_user;
    [self.params setValue:trim_user forKey:@"trim_user"];
}

@end

#pragma mark - TRequestStatusesUpdateWithMedia

@implementation TRequestStatusesUpdateWithMedia

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   status:(NSString *)status
                    media:(NSArray *)media
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/statuses/update_with_media.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithAccessToken:accessToken
                    accessSecretToken:accessSecretToken
                               status:status];
    if (self)
    {
        [self setURL:url];
        [self setValue:TContentTypeMultipart_FormData forHTTPHeaderField:@"Content-Type"];
        [self setHTTPShouldHandleCookies:NO];
        
        self.status = status;
        self.media = media;
        self.nameFieldImages = @"media[]";
    }
    return self;
}

- (void)setPossiblySensitive:(NSNumber *)possiblySensitive
{
    _possiblySensitive = possiblySensitive;
    [self.params setValue:possiblySensitive forKey:@"possibly_sensitive"];
}

@end

#pragma mark - TRequestStatusesUserTimeline

@implementation TRequestStatusesUserTimeline

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/statuses/user_timeline.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.userId = idUser;
    }
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSString *)screenName
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/statuses/user_timeline.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.screenName = screenName;
    }
    return self;
}

- (void)setUserId:(NSNumber *)userId
{
    _userId = userId;
    [self.params setValue:userId forKey:@"user_id"];
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    [self.params setValue:screenName forKey:@"screen_name"];
}

- (void)setCount:(NSNumber *)count
{
    _count = count;
    [self.params setValue:count forKey:@"count"];
}

- (void)setSince_id:(NSNumber *)since_id
{
    _since_id = since_id;
    [self.params setValue:since_id forKey:@"since_id"];
}

- (void)setMax_id:(NSNumber *)max_id
{
    _max_id = max_id;
    [self.params setValue:max_id forKey:@"max_id"];
}

- (void)setExclude_replies:(NSNumber *)exclude_replies
{
    _exclude_replies = exclude_replies;
    [self.params setValue:exclude_replies forKey:@"exclude_replies"];
}

- (void)setTrim_user:(NSNumber *)trim_user
{
    _trim_user = trim_user;
    [self.params setValue:trim_user forKey:@"trim_user"];
}

- (void)setContributor_details:(NSNumber *)contributor_details
{
    _contributor_details = contributor_details;
    [self.params setValue:contributor_details forKey:@"contributor_details"];
}

- (void)setInclude_rts:(NSNumber *)include_rts
{
    _include_rts = include_rts;
    [self.params setValue:include_rts forKey:@"include_rts"];
}

@end

#pragma mark - TRequestStatusesHomeTimeline

@implementation TRequestStatusesHomeTimeline

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/statuses/home_timeline.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
    }
    return self;
}

- (void)setCount:(NSNumber *)count
{
    _count = count;
    [self.params setValue:count forKey:@"count"];
}

- (void)setSince_id:(NSNumber *)since_id
{
    _since_id = since_id;
    [self.params setValue:since_id forKey:@"since_id"];
}

- (void)setMax_id:(NSNumber *)max_id
{
    _max_id = max_id;
    [self.params setValue:max_id forKey:@"max_id"];
}

- (void)setExclude_replies:(NSNumber *)exclude_replies
{
    _exclude_replies = exclude_replies;
    [self.params setValue:exclude_replies forKey:@"exclude_replies"];
}

- (void)setTrim_user:(NSNumber *)trim_user
{
    _trim_user = trim_user;
    [self.params setValue:trim_user forKey:@"trim_user"];
}

- (void)setContributor_details:(NSNumber *)contributor_details
{
    _contributor_details = contributor_details;
    [self.params setValue:contributor_details forKey:@"contributor_details"];
}

- (void)setInclude_entities:(NSNumber *)include_entities
{
    _include_entities = include_entities;
    [self.params setValue:include_entities forKey:@"include_entities"];
}

@end

#pragma mark - TRequestFollowersIds

@implementation TRequestFollowersIds

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/followers/ids.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.userId = idUser;
    }
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSString *)screenName
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/followers/ids.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.screenName = screenName;
    }
    return self;
}

- (void)setUserId:(NSNumber *)userId
{
    _userId = userId;
    [self.params setValue:userId forKey:@"user_id"];
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    [self.params setValue:screenName forKey:@"screen_name"];
}

- (void)setCursor:(NSNumber *)cursor
{
    _cursor = cursor;
    [self.params setValue:cursor forKey:@"cursor"];
}

- (void)setStringifyIds:(NSNumber *)stringifyIds
{
    _stringifyIds = stringifyIds;
    [self.params setValue:stringifyIds forKey:@"stringify_ids"];
}

- (void)setCount:(NSNumber *)count
{
    _count = count;
    [self.params setValue:count forKey:@"count"];
}

@end

#pragma mark - TRequestUsersShow

@implementation TRequestUsersShow

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/users/show.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.userId = idUser;
    }
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSString *)screenName
{
    NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/1.1/users/show.json" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self = [super initWithURL:url
                   httpMethod:TURLRequestHTTPMethodGET
                  contentType:TContentTypeApplication_XWWWFormURLEncoden];
    if (self)
    {
        self.accessToken = accessToken;
        self.accessSecretToken = accessSecretToken;
        self.screenName = screenName;
    }
    return self;
}

- (void)setUserId:(NSNumber *)userId
{
    _userId = userId;
    [self.params setValue:userId forKey:@"user_id"];
}

- (void)setScreenName:(NSString *)screenName
{
    _screenName = screenName;
    [self.params setValue:screenName forKey:@"screen_name"];
}

- (void)setIncludeEntities:(NSNumber *)includeEntities
{
    _includeEntities = includeEntities;
    [self.params setValue:includeEntities forKey:@"include_entities"];
}

@end