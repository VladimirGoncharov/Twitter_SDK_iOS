#import "Twitter.h"

#import "TwitterRequests.h"

static NSString *accessTokenApp        = nil;
static NSString *accessSecretTokenApp  = nil;

static inline NSError *generateError(NSDictionary *dict)
{
    NSError *error = [NSError errorWithDomain:[dict objectForKey:@"message"]
                                         code:[[dict objectForKey:@"code"] integerValue]
                                     userInfo:nil];
    
    [[[UIAlertView alloc] initWithTitle:@"Error!"
                               message:error.domain
                              delegate:nil
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil] show];
    
    return error;
}

static inline NSDate *dateFromTwitterStrDate(NSString *created_at_str)
{
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss Z yyyy"];
    return [dateFormatter dateFromString:created_at_str];
}

static NSString *const kCoderAccessToken                = @"__kCoderAccessToken__";
static NSString *const kCoderAccessTokenSecret          = @"__kCoderAccessTokenSecret__";
static NSString *const kCoderUserId                     = @"__kCoderUserId__";
static NSString *const kCoderScreenName                 = @"__kCoderScreenName__";

#pragma mark - TUser

NSString *const TUserWillUpdateData             = @"__TUserWillUpdateData__";
NSString *const TUserDidUpdateData              = @"__TUserDidUpdateData__";

NSString *const TUserWillUpdateFollowers        = @"__TUserWillUpdateFollowers__";
NSString *const TUserDidUpdateFollowers         = @"__TUserDidUpdateFollowers__";

NSString *const TUserWillUpdateTimeline         = @"__TUserWillUpdateTimeline__";
NSString *const TUserDidUpdateTimeline          = @"__TUserDidUpdateTimeline__";

@interface TUser()

@property (nonatomic, strong) NSNumber *nextCursorForFollowers;

- (void)setUser_id:(NSNumber *)user_id;
- (void)setScreen_name:(NSString *)screen_name;

+ (void)updateUser:(TUser *)user
          dataDict:(NSDictionary *)dataDict;

@end



@interface TTweet ()

+ (void)updateTweet:(TTweet *)tweet
           dataDict:(NSDictionary *)dataDict;

@end



@implementation TUser

#pragma mark - init

- (id)initWithUserId:(NSNumber *)userId
{
    self = [super init];
    if (self)
    {
        _user_id = userId;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        accessTokenApp = [aDecoder decodeObjectForKey:kCoderAccessToken];
        accessSecretTokenApp = [aDecoder decodeObjectForKey:kCoderAccessTokenSecret];
        _user_id = [aDecoder decodeObjectForKey:kCoderUserId];
        _screen_name = [aDecoder decodeObjectForKey:kCoderScreenName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:accessTokenApp forKey:kCoderAccessToken];
    [aCoder encodeObject:accessSecretTokenApp forKey:kCoderAccessTokenSecret];
    [aCoder encodeObject:self.user_id forKey:kCoderUserId];
    [aCoder encodeObject:self.screen_name forKey:kCoderScreenName];
}

#pragma mark - update

- (void)updateDataAsync:(void(^)(NSError *error))finish
{
    if (self.isUpdateData)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserWillUpdateData
                                                        object:self];
    _isUpdateData   = YES;
    
    TRequestUsersShow *request = [[TRequestUsersShow alloc] initWithAccessToken:accessTokenApp
                                                              accessSecretToken:accessSecretTokenApp
                                                                         idUser:self.user_id];
    [request prepareRequest];
    
    __weak TUser *wself = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *dataConnection, NSError *errorConnection) {
                               
                               __strong TUser *sself = wself;
                               if (!sself)
                               {
                                   return;
                               }
                               
                               id result =
                               [NSJSONSerialization JSONObjectWithData:dataConnection
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
                               NSArray *errors = [result valueForKey:@"errors"];
                               
                               if (!errors)
                               {
                                   [[self class] updateUser:self
                                                   dataDict:result];
                                   
                                   if (finish)
                                   {
                                       finish(nil);
                                   }
                               }
                               else
                               {
#if DEBUG
                                   NSLog(@"%s - error: %@", __func__, errors);
#endif
                                   NSDictionary *dict = [errors objectAtIndex:0];
                                   NSError *error = generateError(dict);
                                   if (finish)
                                   {
                                       finish(error);
                                   }
                               }
                               
                               _isUpdateData   = NO;
                               [[NSNotificationCenter defaultCenter] postNotificationName:TUserDidUpdateData
                                                                                   object:self];
                               
                           }];
}

- (void)updateDataSyncWithError:(NSError **)error
{
    if (self.isUpdateData)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserWillUpdateData
                                                        object:self];
    _isUpdateData   = YES;
    
    TRequestUsersShow *request = [[TRequestUsersShow alloc] initWithAccessToken:accessTokenApp
                                                              accessSecretToken:accessSecretTokenApp
                                                                         idUser:self.user_id];
    [request prepareRequest];
    
    NSData *dataConnection =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:nil
                                      error:nil];
    id result  =
    [NSJSONSerialization JSONObjectWithData:dataConnection
                                    options:NSJSONReadingAllowFragments
                                      error:nil];
    
    NSArray *errors = [result valueForKey:@"errors"];
    
    if (!errors)
    {
        [[self class] updateUser:self
                        dataDict:result];
    }
    else
    {
#if DEBUG
        NSLog(@"%s - error: %@", __func__, errors);
#endif
        NSDictionary *dict = [errors objectAtIndex:0];
        *error = generateError(dict);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserDidUpdateData
                                                        object:self];
    
}

#pragma mark - followers

#ifndef MAX_FOLLOWERS_UPDATE
    #define MAX_FOLLOWERS_UPDATE 5000
#endif

- (BOOL)isAvailableUpdateNextPartFollowers
{
    return ([self.nextCursorForFollowers integerValue] > 0);
}

- (void)updateFollowersAsync:(void(^)(NSError *error))finish
                       count:(NSUInteger)count
{
    if (self.isUpdateFollowers)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserWillUpdateFollowers
                                                        object:self];
    _isUpdateFollowers  = YES;
    
    if (count > MAX_FOLLOWERS_UPDATE)
    {
        count = MAX_FOLLOWERS_UPDATE;
    }
    
    TRequestFollowersIds *request = [[TRequestFollowersIds alloc] initWithAccessToken:accessTokenApp
                                                                    accessSecretToken:accessSecretTokenApp
                                                                               idUser:self.user_id];
    request.count = @(count);
    request.cursor = self.nextCursorForFollowers;
    [request prepareRequest];
    
    __weak TUser *wself = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *dataConnection, NSError *errorConnection) {
                               
                               __strong TUser *sself = wself;
                               if (!sself)
                               {
                                   return;
                               }
                               
                               id result =
                               [NSJSONSerialization JSONObjectWithData:dataConnection
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
                               NSArray *errors = [result valueForKey:@"errors"];
                               
                               if (!errors)
                               {
                                   NSArray *arrayIDs = [result objectForKey:@"ids"];
                                   
                                   self.nextCursorForFollowers = @([[result objectForKey:@"next_cursor"] integerValue]);
                                   
                                   NSMutableArray *followers = [[NSMutableArray alloc] initWithArray:_followers];
                                   for (NSNumber *follId in arrayIDs)
                                   {
                                       TUser *follower = [[TUser alloc] initWithUserId:follId];
                                       [followers addObject:follower];
                                   }
                                   _followers = [followers copy];
                                   
                                   if (finish)
                                   {
                                       finish(nil);
                                   }
                               }
                               else
                               {
#if DEBUG
                                   NSLog(@"%s - error: %@", __func__, errors);
#endif
                                   NSDictionary *dict = [errors objectAtIndex:0];
                                   NSError *error = generateError(dict);
                                   
                                   if (finish)
                                   {
                                       finish(error);
                                   }
                               }
                               
                               _isUpdateFollowers  = NO;
                               [[NSNotificationCenter defaultCenter] postNotificationName:TUserDidUpdateFollowers
                                                                                   object:self];
                               
                           }];
}

#pragma mark - home timeline

#ifndef MAX_TIMELINES_UPDATE
    #define MAX_TIMELINES_UPDATE 3200
#endif

- (void)updateTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                       count:(NSUInteger)count
{
    if (self.isUpdateTimelines)
    {
        return;
    }
    
    if (count > MAX_TIMELINES_UPDATE)
    {
        count = MAX_TIMELINES_UPDATE;
    }
    
    TRequestStatusesUserTimeline *request = [[TRequestStatusesUserTimeline alloc] initWithAccessToken:accessTokenApp
                                                                                    accessSecretToken:accessSecretTokenApp
                                                                                               idUser:self.user_id];
    
    if (self.timelines.count > 0)
    {
        TTweet *tweet           = [self.timelines lastObject];
        request.max_id          = tweet.tweet_id;
        count++;
    }
    request.count                       = @(count);
    request.trim_user                   = @(NO);
    request.contributor_details         = @(NO);
    request.include_rts                 = @(NO);
    
    [request prepareRequest];
    
    [self _updateTimelinesAsyncWithRequest:request
                                    finish:finish];
}

- (void)updateNewTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                          count:(NSUInteger)count
{
    if (self.isUpdateTimelines)
    {
        return;
    }
    
    if (count > MAX_TIMELINES_UPDATE)
    {
        count = MAX_TIMELINES_UPDATE;
    }
    
    TRequestStatusesUserTimeline *request = [[TRequestStatusesUserTimeline alloc] initWithAccessToken:accessTokenApp
                                                                                    accessSecretToken:accessSecretTokenApp
                                                                                               idUser:self.user_id];
    
    if (self.timelines.count > 0)
    {
        TTweet *tweet           = [self.timelines firstObject];
        request.since_id        = tweet.tweet_id;
    }
    request.count                       = @(count);
    request.trim_user                   = @(NO);
    request.contributor_details         = @(NO);
    request.include_rts                 = @(NO);
    
    [request prepareRequest];
    
    [self _updateNewTimelinesAsyncWithRequest:request
                                       finish:finish];
}

- (void)_updateTimelinesAsyncWithRequest:(TRequest *)request
                                  finish:(void(^)(NSArray *tweets, NSError *error))finish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserWillUpdateTimeline
                                                        object:nil];
    _isUpdateTimelines  = YES;
    
    __weak TUser *wself = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *dataConnection, NSError *errorConnection) {
                               
                               __strong TUser *sself = wself;
                               if (!sself)
                               {
                                   return;
                               }
                               
                               id result =
                               [NSJSONSerialization JSONObjectWithData:dataConnection
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
                               
                               if ([result isKindOfClass:[NSArray class]])
                               {
                                   NSMutableArray *homeTimelines = [[NSMutableArray alloc] initWithArray:_timelines];
                                   
                                   NSMutableArray *newTweets     = [NSMutableArray new];
                                   for (NSDictionary *tweetCurrent in result)
                                   {
                                       TTweet *tweet        = [[TTweet alloc] initWithTweetId:nil];
                                       [TTweet updateTweet:tweet dataDict:tweetCurrent];
                                       
                                       TTweet *lastTweet    = [_timelines lastObject];
                                       if (lastTweet)
                                       {
                                           if ([lastTweet.tweet_id longLongValue] != [tweet.tweet_id longLongValue])
                                           {
                                               [newTweets addObject:tweet];
                                           }
                                       }
                                       else
                                       {
                                           [newTweets addObject:tweet];
                                       }
                                   }
                                   [homeTimelines addObjectsFromArray:newTweets];
                                   
                                   _timelines = [homeTimelines copy];
                                   
                                   if (finish)
                                   {
                                       finish([newTweets copy], nil);
                                   }
                               }
                               else
                               {
                                   id errors = [result objectForKey:@"errors"];
#if DEBUG
                                   NSLog(@"%s - error: %@", __func__, errors);
#endif
                                   NSDictionary *dict = [errors objectAtIndex:0];
                                   NSError *error = generateError(dict);
                                   
                                   if (finish)
                                   {
                                       finish(nil, error);
                                   }
                               }
                               
                               _isUpdateTimelines  = NO;
                               [[NSNotificationCenter defaultCenter] postNotificationName:TUserDidUpdateTimeline
                                                                                   object:nil];
                           }];
}

- (void)_updateNewTimelinesAsyncWithRequest:(TRequest *)request
                                     finish:(void(^)(NSArray *tweets, NSError *error))finish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserWillUpdateTimeline
                                                        object:nil];
    _isUpdateTimelines  = YES;
    
    __weak TUser *wself = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *dataConnection, NSError *errorConnection) {
                               
                               __strong TUser *sself = wself;
                               if (!sself)
                               {
                                   return;
                               }
                               
                               id result =
                               [NSJSONSerialization JSONObjectWithData:dataConnection
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
                               
                               if ([result isKindOfClass:[NSArray class]])
                               {
                                   NSMutableArray *newTweets     = [NSMutableArray new];
                                   for (NSDictionary *tweetCurrent in result)
                                   {
                                       TTweet *tweet        = [[TTweet alloc] initWithTweetId:nil];
                                       [TTweet updateTweet:tweet dataDict:tweetCurrent];
                                       [newTweets addObject:tweet];
                                   }
                                   NSMutableArray *homeTimelines    = [[NSMutableArray alloc] initWithArray:newTweets];
                                   [homeTimelines addObjectsFromArray:_timelines];
                                   
                                   _timelines = [homeTimelines copy];
                                   
                                   if (finish)
                                   {
                                       finish([newTweets copy], nil);
                                   }
                               }
                               else
                               {
                                   id errors = [result objectForKey:@"errors"];
#if DEBUG
                                   NSLog(@"%s - error: %@", __func__, errors);
#endif
                                   NSDictionary *dict = [errors objectAtIndex:0];
                                   NSError *error = generateError(dict);
                                   
                                   if (finish)
                                   {
                                       finish(nil, error);
                                   }
                               }
                               
                               _isUpdateTimelines  = NO;
                               [[NSNotificationCenter defaultCenter] postNotificationName:TUserDidUpdateTimeline
                                                                                   object:nil];
                           }];
}

#pragma mark - accessor

- (void)setUser_id:(NSNumber *)user_id
{
    _user_id        = user_id;
}

- (void)setScreen_name:(NSString *)screen_name
{
    _screen_name    = screen_name;
}

#pragma mark - helper

+ (void)updateUser:(TUser *)user
          dataDict:(NSDictionary *)dataDict
{
    NSNumber *userId                    = @([[dataDict objectForKey:@"id"] longLongValue]);
    user->_user_id                      = userId;
    
    NSString *screenName                = [dataDict objectForKey:@"screen_name"];
    user->_screen_name                  = screenName;
    
    NSString *profile_image_url         = [dataDict objectForKey:@"profile_image_url"];
    user->_profile_image_url            = [NSURL URLWithString:[profile_image_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *profile_image_url_https   = [dataDict objectForKey:@"profile_image_url_https"];
    user->_profile_image_url_https      = [NSURL URLWithString:[profile_image_url_https stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *location = [dataDict objectForKey:@"location"];
    user->_location                     = location;
    
    NSNumber *followers_count           = @([[dataDict objectForKey:@"followers_count"] integerValue]);
    user->_followers_count              = followers_count;
    
    NSDictionary *status                = [dataDict objectForKey:@"status"];
    if (status)
    {
        TTweet *tweet                       = [[TTweet alloc] initWithTweetId:nil];
        [TTweet updateTweet:tweet dataDict:status];
        user->_last_status                  = tweet;
    }
    
    NSString *name                      = [dataDict objectForKey:@"name"];
    user->_name                         = name;
    
    NSNumber *friends_count             = @([[dataDict objectForKey:@"friends_count"] integerValue]);
    user->_friends_count                = friends_count;
    
    NSString *created_at_str            = [dataDict objectForKey:@"created_at"];
    user->_created_at                   = dateFromTwitterStrDate(created_at_str);
    
    NSNumber *statuses_count            = @([[dataDict objectForKey:@"statuses_count"] integerValue]);
    user->_statuses_count               = statuses_count;
}

@end



#pragma mark - TUserMain

NSString *const TUserMainWillPostTweet                  = @"__TUserMainWillPostTweet__";
NSString *const TUserMainDidPostTweet                   = @"__TUserMainDidPostTweet__";

static inline NSString *getCashPathWithFileName(NSString *fileName)
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    return [[path stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"cashe"];
}

static NSString *const kCoderUserFileName               = @"__userMain";

#ifndef USER_FILE_PATH
    #define USER_FILE_PATH getCashPathWithFileName(kCoderUserFileName)
#endif

#ifndef MAX_HOME_TIMELINES_UPDATE
    #define MAX_HOME_TIMELINES_UPDATE 800
#endif

static TUserMain *mainUser = nil;
static dispatch_once_t onceTokenUserData    = 0;

@implementation TUserMain

+ (TUserMain *)shared
{
    if (!mainUser)
    {
        mainUser = [[self alloc] init];
    }
    return mainUser;
}

- (id)init
{
    dispatch_once(&onceTokenUserData, ^{
        
        mainUser = [[self class] _loadCachUser];
        if (!mainUser)
        {
            mainUser = [super initWithUserId:nil];
        }
        
        NSLog(@"%@", mainUser.user_id);
        
    });
    
    return mainUser;
}

#pragma mark - auth

- (void)autorize:(void(^)(TUserMainAuthResult result, NSError *error))finish
presentViewController:(UIViewController *)presentViewController
{
    __block NSString *token = nil;
    __block NSString *secretToken = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //  Получаем временный токен
    if ([self _implementRequestTokenWithAccessToken:&(token)
                                  accessSecretToken:&(secretToken)])
    {
        //      Шаг с получение временного токена выполнен и переходим к авторизации пользователя
        
        TOAuthViewController *viewController = [[TOAuthViewController alloc] initWithAccessToken:token];
        viewController.didFinishAuthHandler = ^(TOAuthViewControllerState state, NSDictionary *params)
        {
            switch (state)
            {
                case TOAuthViewControllerStateComlete:
                {
                    //                  Шаг с авторизацией пользователя подтвердился и мы получили токен с верификацией. Подтверждаем их получения
                    [presentViewController dismissViewControllerAnimated:YES
                                                              completion:nil];
                    
                    if ([self _implementAccessTokenWithVerifier:[params valueForKey:kOAuthVerifier]
                                                    accessToken:[params valueForKey:kOAuthAccsessToken]])
                    {
                        //                      Все этапы успешно пройдены
                        if (finish)
                        {
                            finish(TUserMainAuthResultComplete, nil);
                        }
                    }
                    else
                    {
                        //                      Токен не подтвержден
                        if (finish)
                        {
                            NSError *error = [NSError errorWithDomain:@"Ошибка верификации токена"
                                                                 code:30102
                                                             userInfo:nil];
                            finish(TUserMainAuthResultError, error);
                        }
                    }
                    
                }; break;
                    
                case TOAuthViewControllerStateCancel:
                {
                    //                  Пользователь отменил авторизацию
                    [presentViewController dismissViewControllerAnimated:YES
                                                              completion:nil];
                    
                    if (finish)
                    {
                        finish(TUserMainAuthResultCancel, nil);
                    }
                    
                }; break;
                    
                default:
                    break;
            }
        };
        
        [presentViewController presentViewController:viewController
                                            animated:YES
                                          completion:nil];
    }
    else
    {
        //      Временный токен не пришел
        if (finish)
        {
            NSError *error = [NSError errorWithDomain:@"Ошибка получения временного токена"
                                                 code:30101
                                             userInfo:nil];
            finish(TUserMainAuthResultError, error);
        }
    }
}

- (BOOL)_implementRequestTokenWithAccessToken:(NSString **)accessToken
                            accessSecretToken:(NSString **)accessSecretToken
{
    TRequestToken *request = [TRequestToken new];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    id data =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    NSString *result =
    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!error)
    {
        NSArray *paramsSeparated = [result componentsSeparatedByString:@"&"];
        if (accessToken)
        {
            *accessToken = [[[paramsSeparated objectAtIndex:0] componentsSeparatedByString:@"="] lastObject];
        }
        if (accessSecretToken)
        {
            *accessSecretToken = [[[paramsSeparated objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
        }
        
        return YES;
    }
    else
    {
#if DEBUG
        NSLog(@"%s - result: %@", __func__, result);
#endif
        return NO;
    }
}

- (BOOL)_implementAccessTokenWithVerifier:(NSString *)verifier
                              accessToken:(NSString *)accessToken
{
    TAccessToken *request = [[TAccessToken alloc] initWithVerifier:verifier
                                                       accessToken:accessToken];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    id data =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    id result =
    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!error)
    {
        NSArray *paramsSeparated = [result componentsSeparatedByString:@"&"];
        accessTokenApp          = [[[paramsSeparated objectAtIndex:0] componentsSeparatedByString:@"="] lastObject];
        accessSecretTokenApp    = [[[paramsSeparated objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
        self.user_id            = @([[[[paramsSeparated objectAtIndex:2] componentsSeparatedByString:@"="] lastObject] integerValue]);
        self.screen_name        = [[[paramsSeparated objectAtIndex:3] componentsSeparatedByString:@"="] lastObject];
        
        return YES;
    }
    else
    {
#if DEBUG
        NSLog(@"%s - result: %@", __func__, result);
#endif
        return NO;
    }
}

#pragma mark - logout

- (void)logout
{
    mainUser                = nil;
    onceTokenUserData       = 0;
    [self clearCachUser];
    
    accessTokenApp          = nil;
    accessSecretTokenApp    = nil;
}

+ (void)_clearCoockies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:@"http://www.twitter.com/"]];
    for (NSHTTPCookie *cookie in cookies)
    {
        [storage deleteCookie:cookie];
    }
}

#pragma mark - accessor

- (BOOL)isAutorize
{
    return (accessTokenApp &&
            accessSecretTokenApp);
}

#pragma mark - cash

+ (TUserMain *)_loadCachUser
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:USER_FILE_PATH];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)cachUser
{
    TUser *user = [[self class] shared];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    [data writeToFile:USER_FILE_PATH atomically:YES];
}

- (void)clearCachUser
{
    [[NSFileManager defaultManager] removeItemAtPath:USER_FILE_PATH error:nil];
    [[self class] _clearCoockies];
}

#pragma mark - timelines overlay

#ifdef MAX_TIMELINES_UPDATE
    #undef MAX_TIMELINES_UPDATE
#endif

#ifndef MAX_HOME_TIMELINES_UPDATE
    #define MAX_HOME_TIMELINES_UPDATE 800
#endif

- (void)updateTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                       count:(NSUInteger)count
{
    if (self.isUpdateTimelines)
    {
        return;
    }
    
    if (count > MAX_HOME_TIMELINES_UPDATE)
    {
        count = MAX_HOME_TIMELINES_UPDATE;
    }
    
    TRequestStatusesHomeTimeline *request = [[TRequestStatusesHomeTimeline alloc] initWithAccessToken:accessTokenApp
                                                                                    accessSecretToken:accessSecretTokenApp];
    
    if (self.timelines.count > 0)
    {
        TTweet *tweet           = [self.timelines lastObject];
        request.max_id          = tweet.tweet_id;
        count++;
    }
    request.count                       = @(count);
    request.trim_user                   = @(NO);
    request.contributor_details         = @(NO);
    request.include_entities            = @(NO);
    
    [request prepareRequest];
    
    [self _updateTimelinesAsyncWithRequest:request
                                    finish:finish];
}

- (void)updateNewTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                          count:(NSUInteger)count
{
    if (self.isUpdateTimelines)
    {
        return;
    }
    
    if (count > MAX_HOME_TIMELINES_UPDATE)
    {
        count = MAX_HOME_TIMELINES_UPDATE;
    }
    
    TRequestStatusesHomeTimeline *request = [[TRequestStatusesHomeTimeline alloc] initWithAccessToken:accessTokenApp
                                                                                    accessSecretToken:accessSecretTokenApp];
    
    if (self.timelines.count > 0)
    {
        TTweet *tweet           = [self.timelines firstObject];
        request.since_id        = tweet.tweet_id;
    }
    
    request.count                       = @(count);
    request.trim_user                   = @(NO);
    request.contributor_details         = @(NO);
    request.include_entities            = @(NO);
    
    [request prepareRequest];
    
    [self _updateNewTimelinesAsyncWithRequest:request
                                    finish:finish];
}

#pragma mark - make tweet

- (TTweet *)_postTweetWithStatusSync:(NSString *)status
                               error:(NSError **)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserMainWillPostTweet
                                                        object:nil];
    
    TRequestStatusesUpdate *request = [[TRequestStatusesUpdate alloc] initWithAccessToken:accessTokenApp
                                                                        accessSecretToken:accessSecretTokenApp
                                                                                   status:status];
    request.trim_user       = @(YES);
    [request prepareRequest];
    
    id data =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:nil
                                      error:nil];
    
    id result =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingAllowFragments
                                      error:nil];
    TTweet *tweet = nil;
    
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSArray *errors = [result objectForKey:@"errors"];
        if (errors)
        {
#if DEBUG
            NSLog(@"%s - error: %@", __func__, errors);
#endif
            NSDictionary *dict = [errors objectAtIndex:0];
            *error = generateError(dict);
        }
        else
        {
            tweet           = [[TTweet alloc] initWithTweetId:nil];
            [TTweet updateTweet:tweet dataDict:result];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TUserMainDidPostTweet
                                                        object:tweet];
    
    return tweet;
}

- (TTweet *)postTweetWithStatusSync:(NSString *)status
                              media:(NSArray *)media
                              error:(NSError **)error
{
    if (media.count == 0)
    {
        return [self _postTweetWithStatusSync:status error:error];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:TUserMainWillPostTweet
                                                            object:nil];
        
        TRequestStatusesUpdateWithMedia *request = [[TRequestStatusesUpdateWithMedia alloc] initWithAccessToken:accessTokenApp
                                                                                              accessSecretToken:accessSecretTokenApp
                                                                                                         status:status
                                                                                                          media:media];
        request.trim_user       = @(YES);
        [request prepareRequest];
        
        id data =
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:nil
                                          error:nil];
        
        id result =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:nil];
        
        TTweet *tweet = nil;
        
        if ([result isKindOfClass:[NSDictionary class]])
        {
            NSArray *errors = [result objectForKey:@"errors"];
            if (errors)
            {
#if DEBUG
                NSLog(@"%s - error: %@", __func__, errors);
#endif
                NSDictionary *dict = [errors objectAtIndex:0];
                *error = generateError(dict);
            }
            else
            {
                tweet           = [[TTweet alloc] initWithTweetId:nil];
                [TTweet updateTweet:tweet dataDict:result];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TUserMainDidPostTweet
                                                            object:tweet];
        
        return tweet;
    }
}

@end



@implementation TTweet

- (id)initWithTweetId:(NSNumber *)tweetId
{
    self = [super init];
    if (self)
    {
        _tweet_id  = tweetId;
    }
    return self;
}

#pragma mark - helper

+ (void)updateTweet:(TTweet *)tweet
           dataDict:(NSDictionary *)dataDict
{
    NSNumber *tweet_id              = @([[dataDict objectForKey:@"id"] longLongValue]);
    tweet->_tweet_id                = tweet_id;
    
    NSString *created_at_str = [dataDict objectForKey:@"created_at"];
    tweet->_created_at              = dateFromTwitterStrDate(created_at_str);
    
    NSString *text = [dataDict objectForKey:@"text"];
    tweet->_text                    = text;
    
    NSNumber *truncated             = @([[dataDict objectForKey:@"truncated"] boolValue]);
    tweet->_truncated               = truncated;
    
    NSNumber *retweet_count         = @([[dataDict objectForKey:@"retweet_count"] integerValue]);
    tweet->_retweet_count = retweet_count;
    
    NSNumber *retweeted             = @([[dataDict objectForKey:@"retweeted"] boolValue]);
    tweet->_retweeted               = retweeted;
    
    NSDictionary *retweeted_status  = [dataDict objectForKey:@"retweeted_status"];
    if (retweeted_status)
    {
        TTweet *tweet_retweeted_status      = [[TTweet alloc] initWithTweetId:nil];
        [self updateTweet:tweet_retweeted_status dataDict:retweeted_status];
        tweet->_retweeted_status   = tweet_retweeted_status;
    }
    
    NSDictionary *user_data              = [dataDict objectForKey:@"user"];
    if (user_data)
    {
        TUser *user                          = [[TUser alloc] initWithUserId:nil];
        [TUser updateUser:user dataDict:user_data];
        tweet->_user                         = user;
    }
}

@end

