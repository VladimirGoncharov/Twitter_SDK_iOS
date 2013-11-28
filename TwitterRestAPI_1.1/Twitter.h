#import <Foundation/Foundation.h>

#pragma mark - TUser

@class TTweet;

extern NSString *const TUserWillUpdateData;
extern NSString *const TUserDidUpdateData;

extern NSString *const TUserWillUpdateTimeline;
extern NSString *const TUserDidUpdateTimeline;

extern NSString *const TUserWillUpdateFollowers;
extern NSString *const TUserDidUpdateFollowers;

@interface TUser : NSObject <NSCoding>

/*!
 @discussion Класс пользователя.
 */

- (id)initWithUserId:(NSNumber *)userId;


/*!
 @property
 дата создания
 //Например: Sat Nov 09 11:38:48 +0000 2012
 */
@property (nonatomic, strong, readonly) NSDate *created_at;
/*!
 @property
 общее кол-во friends
 */
@property (nonatomic, strong, readonly) NSNumber *friends_count;
/*!
 @property
 имя пользователя
 */
@property (nonatomic, strong, readonly) NSString *name;
/*!
 @property
 ссылка на аватар пользователя.
 //Например: http://a2.twimg.com/profile_images/1438634086/avatar_normal.png
 */
@property (nonatomic, strong, readonly) NSURL *profile_image_url;
@property (nonatomic, strong, readonly) NSURL *profile_image_url_https;
/*!
 @property
 отображение местоположения, указанного в настройках
 //Например: San Francisco, CA
 */
@property (nonatomic, strong, readonly) TTweet *last_status;
/*!
 @property
 отображение местоположения, указанного в настройках
 //Например: San Francisco, CA
 */
@property (nonatomic, strong, readonly) NSString *location;
/*!
 @property
 Ник, указатель или псевдоним, с каким уникальным именем идентифицирует себя пользователь, но может быть изменен.
 //Например: noratio
 */
@property (nonatomic, strong, readonly) NSString *screen_name;
/*!
 @property
 общее количество статусов
 //Например: 9
 */
@property (nonatomic, strong, readonly) NSNumber *statuses_count;
/*!
 @property
 уникальный идентификатор для пользователя.
 //Например: 12345
 */
@property (nonatomic, strong, readonly) NSNumber *user_id;


/*!
 @property
 происходит ли в данный момент обновление данных пользователя
 */
@property (nonatomic, assign, readonly) BOOL isUpdateData;
/*!
 @method
 обновляет список данных пользователя
 */
- (void)updateDataAsync:(void(^)(NSError *error))finish;
- (void)updateDataSyncWithError:(NSError **)error;


/*!
 @property
 происходит ли в данный момент обновление timelines
 */
@property (nonatomic, assign, readonly) BOOL isUpdateTimelines;
/*!
 @property
 список home timelines
 */
@property (nonatomic, strong, readonly) NSArray *timelines;
/*!
 @method
 обновление списка timelines с более поздними твитами
 @warning
 максимальное count = 3200
 */
- (void)updateTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                       count:(NSUInteger)count;
/*!
 @method
 обновление списка timelines с более ранними твитами
 @warning
 максимальное count = 3200
 */
- (void)updateNewTimelinesAsync:(void(^)(NSArray *tweets, NSError *error))finish
                              count:(NSUInteger)count;


/*!
 @property
 происходит ли в данный момент обновление followers
 */
@property (nonatomic, assign, readonly) BOOL isUpdateFollowers;
/*!
 @property
 можно ли еще обновить список новыми followers
 */
@property (nonatomic, assign, readonly) BOOL isAvailableUpdateNextPartFollowers;
/*!
 @property
 список followers
 */
@property (nonatomic, strong, readonly) NSArray *followers;
/*!
 @property
 общее кол-во followers
 */
@property (nonatomic, strong, readonly) NSNumber *followers_count;
/*!
 @method
 обновление списка followers
 @warning
 максимальное count = 5000
 */
- (void)updateFollowersAsync:(void(^)(NSError *error))finish
                       count:(NSUInteger)count;

@end

@interface TUser (Unavailable)

- (id)init __attribute__((unavailable("init not available! Use initWithUserId:")));
+ (id)new __attribute__((unavailable("new not available! Use initWithUserId:")));

@end



#pragma mark - TUSerMain

extern NSString *const TUserMainWillPostTweet;
extern NSString *const TUserMainDidPostTweet;

typedef NS_ENUM(NSUInteger, TUserMainAuthResult)
{
    TUserMainAuthResultComplete  = 1 << 0,
    TUserMainAuthResultCancel    = 1 << 1,
    TUserMainAuthResultError     = 1 << 2
};

@interface TUserMain : TUser

/*!
 @discussion Класс текущего пользователя.
 */

/*!
 @method
 доступ к пользователю
 */
+ (TUserMain *)shared;

/*!
 @property
 авторизован пользователь или нет
 */
@property (nonatomic, assign, readonly) BOOL isAutorize;
/*!
 @method
 авторизация пользователя
 */
- (void)autorize:(void(^)(TUserMainAuthResult result, NSError *error))finish
presentViewController:(UIViewController *)presentViewController;
/*!
 @method
 деавторизация пользователя
 */
- (void)logout;

/*!
 @method
 сохранение id, screen name, token и secret token пользователя.
 */
- (void)cachUser;
/*!
 @method
 удаление сохраненых id, screen name, token и secret token пользователя, очистка куки.
 */
- (void)clearCachUser;


/*!
 @method
 написание текстового твита с изображением
 @warning
 отправиться только одно первое изображение (массив добавлен на будующее, если добавят функцию), запакованное, как NSData.
 */
- (TTweet *)postTweetWithStatusSync:(NSString *)status
                              media:(NSArray *)media
                              error:(NSError **)error;

@end

@interface TUserMain (Unavailable)

- (id)initWithUserId __attribute__((unavailable("initWithUserId: not available! Use shared")));

@end



#pragma mark - TTweet

@interface TTweet : NSObject

/*!
 @discussion Класс твита(статуса).
 @warning
 Если retweeted = true, то данный твит содержит метаданные ретвита и за данными к настоящему твиту обращаться к полю retweeted_status.
 */

- (id)initWithTweetId:(NSNumber *)tweetId;


/*!
 @property
 дата создания
 //Например: Sat Nov 09 11:38:48 +0000 2012
 */
@property (nonatomic, strong, readonly) NSDate *created_at;
/*!
 @property
 ссылка на аватар пользователя.
 //Например: текст моего твита!
 */
@property (nonatomic, strong, readonly) NSString *text;
/*!
 @property
 если твит более 140 символов, то оно обрезается. Обрезанно данное сообщение или нет.
 //Например: true
 */
@property (nonatomic, strong, readonly) NSNumber *truncated;
/*!
 @property
 уникальный идентификатор для твита.
 //Например: 12345
 */
@property (nonatomic, strong, readonly) NSNumber *tweet_id;
/*!
 @property
 отображение местоположения, указанного в настройках
 //Например: San Francisco, CA
 */
@property (nonatomic, strong, readonly) NSNumber *retweet_count;
/*!
 @property
 является ли данный твит ретвитом
 //Например: false
 */
@property (nonatomic, strong, readonly) NSNumber *retweeted;
/*!
 @property
 содержит настоящий твит, если данный твит является ретвитом
 */
@property (nonatomic, strong, readonly) TTweet *retweeted_status;
/*!
 @property
 пользователь, создавший твит
 */
@property (nonatomic, strong, readonly) TUser *user;

@end

@interface TTweet (Unavailable)

- (id)init __attribute__((unavailable("init not available! Use initWithTweetId:")));
+ (id)new __attribute__((unavailable("new not available! Use initWithTweetId:")));

@end