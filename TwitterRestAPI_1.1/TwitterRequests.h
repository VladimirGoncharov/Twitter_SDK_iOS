#import <Foundation/Foundation.h>

#import "TOAuthViewController.h"

#ifndef TIMEOUT_INTERVAL
    #define TIMEOUT_INTERVAL 15.0f
#endif

extern NSString *const TURLRequestHTTPMethodGET;
extern NSString *const TURLRequestHTTPMethodPOST;

extern NSString *const TContentTypeApplication_XWWWFormURLEncoden;
extern NSString *const TContentTypeMultipart_FormData;

extern NSString *const kOAuthAuthorization;
extern NSString *const kOAuthCallback;
extern NSString *const kOAuthConsumerKey;
extern NSString *const kOAuthNonce;
extern NSString *const kOAuthSignature;
extern NSString *const kOAuthSignatureMethod;
extern NSString *const kOAuthTimestamp;
extern NSString *const kOAuthAccsessToken;
extern NSString *const kOAuthAccsessTokenSecret;
extern NSString *const kOAuthVersion;

extern NSString *const oauth_callback;

#pragma mark - auth request's



@interface TRequestToken : NSMutableURLRequest

/*!
 @discussion получение временного токена и секрета токена
 */

/*!
 @property
 время для запроса
 */
@property (nonatomic, strong, readonly) NSString *timestamp;
/*!
 @property
 случайно сгенерированная строка для запроса
 */
@property (nonatomic, strong, readonly) NSString *nonce;
/*!
 @property
 сигнатура
 */
@property (nonatomic, strong, readonly) NSString *signature;

- (id)init;

@end

@interface TRequestToken (Unavailable)

- (id)initWithURL:(NSURL *)URL __attribute__((unavailable("initWithURL: not available! Use init")));

- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval __attribute__((unavailable("initWithURL:cachePolicy:timeoutInterval: not available! Use init")));

@end




@interface TAccessToken : NSMutableURLRequest

/*!
 @discussion получение реального и постояного токена и секрета токена
 */

/*!
 @property
 verifier токен
 */
@property (nonatomic, strong, readonly) NSString *verifier;

/*!
 @property
 временный токен
 */
@property (nonatomic, strong, readonly) NSString *accessToken;

/*!
 @property
 время для запроса
 */
@property (nonatomic, strong, readonly) NSString *timestamp;
/*!
 @property
 случайно сгенерированная строка для запроса
 */
@property (nonatomic, strong, readonly) NSString *nonce;
/*!
 @property
 сигнатура
 */
@property (nonatomic, strong, readonly) NSString *signature;

- (id)initWithVerifier:(NSString *)verifier
           accessToken:(NSString *)accessToken;

@end

@interface TAccessToken (Unavailable)

- (id)init __attribute__((unavailable("init: not available! Use initWithVerifier:accessToken:")));
+ (id)new __attribute__((unavailable("new not available! Use initWithVerifier:accessToken:")));

- (id)initWithURL:(NSURL *)URL __attribute__((unavailable("initWithURL: not available! Use initWithVerifier:accessToken:")));

- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval __attribute__((unavailable("initWithURL:cachePolicy:timeoutInterval: not available! Use initWithVerifier:accessToken:")));

@end

#pragma mark - request's

@protocol TImagesProtocol <NSObject>
@required

/*!
 @property
 массив UIImage
 */
@property (nonatomic, strong) NSArray *media;
/*!
 @property
 наименование 
 */
@property (nonatomic, strong) NSString *nameFieldImages;

@end




@interface TRequest : NSMutableURLRequest

/*!
 @discussion
    данный запрос генерирует сигнатуру и header. 
 */

/*!
 @property
 токен, полученый после авторизации
 */
@property (nonatomic, strong) NSString *accessToken;
/*!
 @property
 секретный токен, полученый после авторизации
 */
@property (nonatomic, strong) NSString *accessSecretToken;

/*!
 @property
 время для запроса
 */
@property (nonatomic, strong, readonly) NSString *timestamp;
/*!
 @property
 случайно сгенерированная строка для запроса
 */
@property (nonatomic, strong, readonly) NSString *nonce;

- (id)initWithURL:(NSURL *)URL
       httpMethod:(NSString *)httpMethod
      contentType:(NSString *)contentType;
/*!
 @method
    после передачи всех параметров запрос необходимо подготовить
 */
- (void)prepareRequest;

@end

@interface TRequest (Unavailable)

- (id)init __attribute__((unavailable("init: not available! Use initWithURL:httpMethod:contentType:")));
+ (id)new __attribute__((unavailable("new not available! Use initWithURL:httpMethod:contentType:")));

- (id)initWithURL:(NSURL *)URL __attribute__((unavailable("initWithURL: not available! Use initWithURL:httpMethod:contentType:")));

- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval __attribute__((unavailable("initWithURL:cachePolicy:timeoutInterval: not available! Use initWithURL:httpMethod:contentType:")));

@end




@interface TRequestStatusesUpdate : TRequest

/*!
 @discussion Написание твита
 */

/*!
 @property
 обязательный Текст твита. Не должен превышать 140 символов. Все длинные ссылки будут сокращены.
 Например: Maybe he'll finally find his keys. #peterfalk
 */
@property (nonatomic, strong) NSString *status;
/*!
 @property
 необязательный. Цифровой ID существующего твита. Используйте этот параметр, когда нужно отправить ответ на какой-либо твит.
 Например: 12345
 */
@property (nonatomic, strong) NSNumber *inReplyToStatusId;
/*!
 @property
 необязательный. Широта пользователя, отправляющего твит. Будет проигнорировано, если значение будет выходить за пределы -90...+90.
 //Например: 56.23123131
 */
@property (nonatomic, strong) NSNumber *latitude;
/*!
 @property
 необязательный. Долгота пользователя, отправляющего твит. Будет проигнорировано, если значение будет выходить за пределы -180...+180.
 //Например: -92.26127133
 */
@property (nonatomic, strong) NSNumber *longitude;
/*!
 @property
 необязательный. Место в мире (так называемый, geocode). Может быть получено из GET geo/reverse_geocode.
 //Например: df51dec6f4ee2b2c
 */
@property (nonatomic, strong) NSString *placeId;
/*!
 @property
 необязательный. Позволяет поставить "булавку" на карту в том месте, откуда сделан твит.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *displayCoordinates;
/*!
 @property
 необязательный. Если установлено значение true, t или 1, то для пользователя твита будет отправлено только id, иначе полное описание.
 Например: true
 */
@property (nonatomic, strong) NSNumber *trim_user;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   status:(NSString *)status;

@end

@interface TRequestStatusesUpdate (Unavailable)

- (id)initWithURL:(NSURL *)URL
httpMethod:(NSString *)httpMethod
contentType:(NSString *)contentType __attribute__((unavailable("initWithURL:httpMethod:contentType: not available! Use initWithAccessToken:accessSecretToken:status:")));

@end




@interface TRequestStatusesUpdateWithMedia : TRequestStatusesUpdate <TImagesProtocol>

/*!
 @discussion Написание твита с изображениями.
 */

/*!
 @property
 обязательный. Добавляет прикреплённому к твиту файлу статус multipart/form-data. Поддерживаемые форматы изображений: PNG, JPG и GIF (анимированные GIF - не поддерживаются).
 */
@property (nonatomic, strong) NSArray *media;                       //массив UIImage
@property (nonatomic, strong) NSString *nameFieldImages;            //Имя поля при post запросе
/*!
 @property
 необязательный. Если выбрано true, то будет считаться что твит содержит изображение "не для всех" (т.е. с возрастным ограничением).
 Например: false
 */
@property (nonatomic, strong) NSNumber *possiblySensitive;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   status:(NSString *)status
                    media:(NSArray *)media;

@end

@interface TRequestStatusesUpdateWithMedia (Unavailable)

- (id)initWithAccessToken:(NSString *)accessToken
accessSecretToken:(NSString *)accessSecretToken
status:(NSString *)status __attribute__((unavailable("initWithAccessToken:accessSecretToken:status: not available! Use initWithAccessToken:accessSecretToken:status:media:")));

@end




@interface TRequestFollowersIds : TRequest

/*!
 @discussion Получение списка followers. 
 @warning  Должен содержать id или screen_name пользователя.
 */

/*!
 @property
 обязательный. Идентификатор пользователя, для которого вернуть результаты.
 Например: 123456
 */
@property (nonatomic, strong) NSNumber *userId;
/*!
 @property
 обязательный. Имя пользователя, для которого вернуть результаты.
 Например: noratio
 */
@property (nonatomic, strong) NSString *screenName;
/*!
 @property
 необязательный. Курсор, типо оффсета для запроса порциями
 //Например: 4564216546
 */
@property (nonatomic, strong) NSNumber *cursor;
/*!
 @property
 необязательный. Возвращение строкой
 //Например: true
 */
@property (nonatomic, strong) NSNumber *stringifyIds;
/*!
 @property
 необязательный. Количество объектов, которых необходимо вернуть
 //Например: 2048
 */
@property (nonatomic, strong) NSNumber *count;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser;
- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSString *)screenName;

@end

@interface TRequestFollowersIds (Unavailable)

- (id)initWithURL:(NSURL *)URL
httpMethod:(NSString *)httpMethod
contentType:(NSString *)contentType __attribute__((unavailable("initWithURL:httpMethod:contentType: not available! Use initWithAccessToken:accessSecretToken:idUser: or initWithAccessToken:accessSecretToken:screenName:")));

@end



@interface TRequestStatusesUserTimeline : TRequest

/*!
 @discussion Возвращает коллекцию новых твитов и ретвитов, опубликованных авторизированным пользователем и пользователями, которые читают его.
 @warning
 Должен содержать id или screen_name пользователя.
 */

/*!
@property
обязательный. Идентификатор пользователя, для которого вернуть результаты.
Например: 123456
*/
@property (nonatomic, strong) NSNumber *userId;
/*!
 @property
 обязательный. Имя пользователя, для которого вернуть результаты.
 Например: noratio
 */
@property (nonatomic, strong) NSString *screenName;
/*!
 @property
 необязательный. Курсор, типо оффсета для запроса порциями
 //Например: 4564216546
 */
/*!
 @property
 необязательный. Определяет (ограничивает) общее число твитов.
 //Например: 5
 */
@property (nonatomic, strong) NSNumber *count;
/*!
 @property
 необязательный. Возвращает результаты с ID больше (то есть, более поздние), чем указанный идентификатор.
 //Например: 12345
 */
@property (nonatomic, strong) NSNumber *since_id;
/*!
 @property
 необязательный. Возвращает результаты с ID меньше (то есть, более ранние или равные), чем указанный идентификатор.
 //Например: 54321
 */
@property (nonatomic, strong) NSNumber *max_id;
/*!
 @property
 необязательный. Этот параметр будет препятствовать тому, чтобы ответы появились в возвращенном timeline.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *exclude_replies;
/*!
 @property
 необязательный. Если установлено значение true, t или 1, то для пользователя твита будет отправлено только id, иначе полное описание.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *trim_user;
/*!
 @property
 необязательный. Дополнительно отображает screen_name упомянувшего пользователя. Стандартно отображается только user_id.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *contributor_details;
/*!
 @property
 необязательный. Когда установлено в false, в timeline не будут учитываться  любые ретвиты пользователя (хотя они всё равно будут учитываться при максимальной длине timeline и параметром count).
 @warning
 Если Вы будете использовать параметр trim_user вместе с include_rts, то ретвиты будут все еще содержать полный пользовательский объект.
 */
@property (nonatomic, strong) NSNumber *include_rts;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSNumber *)screenName;

@end

@interface TRequestStatusesUserTimeline (Unavailable)

- (id)initWithURL:(NSURL *)URL
       httpMethod:(NSString *)httpMethod
      contentType:(NSString *)contentType __attribute__((unavailable("initWithURL:httpMethod:contentType: not available! Use initWithAccessToken:accessSecretToken:idUser: or initWithAccessToken:accessSecretToken:screenName:")));

@end



@interface TRequestStatusesHomeTimeline : TRequest

/*!
 @discussion Возвращает коллекцию новых твитов и ретвитов, опубликованных авторизированным пользователем и пользователями, которые читают его.
 @warning  
 Должен содержать id или screen_name пользователя.
 */

/*!
 @property
 необязательный. Определяет (ограничивает) общее число твитов.
 //Например: 5
 */
@property (nonatomic, strong) NSNumber *count;
/*!
 @property
 необязательный. Возвращает результаты с ID больше (то есть, более поздние), чем указанный идентификатор.
 //Например: 12345
 */
@property (nonatomic, strong) NSNumber *since_id;
/*!
 @property
 необязательный. Возвращает результаты с ID меньше (то есть, более ранние или равные), чем указанный идентификатор.
 //Например: 54321
 */
@property (nonatomic, strong) NSNumber *max_id;
/*!
 @property
 необязательный. Этот параметр будет препятствовать тому, чтобы ответы появились в возвращенном timeline.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *exclude_replies;
/*!
 @property
 необязательный. Если установлено значение true, t или 1, то для пользователя твита будет отправлено только id, иначе полное описание.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *trim_user;
/*!
 @property
 необязательный. Дополнительно отображает screen_name упомянувшего пользователя. Стандартно отображается только user_id.
 //Например: true
 */
@property (nonatomic, strong) NSNumber *contributor_details;
/*!
 @property
 необязательный. Этот параметр позволяет включить добавление сущности (entities node).
 //Например: false
 */
@property (nonatomic, strong) NSNumber *include_entities;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken;

@end

@interface TRequestStatusesHomeTimeline (Unavailable)

- (id)initWithURL:(NSURL *)URL
       httpMethod:(NSString *)httpMethod
      contentType:(NSString *)contentType __attribute__((unavailable("initWithURL:httpMethod:contentType: not available! Use initWithAccessToken:accessSecretToken:")));

@end



@interface TRequestUsersShow : TRequest

/*!
 @discussion Получение описания пользователя. 
 @warning Должен содержать id или screen_name пользователя.
 */

/*!
 @property
 обязательный. Идентификатор пользователя, для которого вернуть результаты.
 Например: 123456
 */
@property (nonatomic, strong) NSNumber *userId;
/*!
 @property
 обязательный. Имя пользователя, для которого вернуть результаты.
 Например: noratio
 */
@property (nonatomic, strong) NSString *screenName;
/*!
 @property
 необязательный. Этот параметр позволяет включить добавление сущности (entities node).
 //Например: false
 */
@property (nonatomic, strong) NSNumber *includeEntities;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
                   idUser:(NSNumber *)idUser;

- (id)initWithAccessToken:(NSString *)accessToken
        accessSecretToken:(NSString *)accessSecretToken
               screenName:(NSNumber *)screenName;

@end

@interface TRequestUsersShow (Unavailable)

- (id)initWithURL:(NSURL *)URL
httpMethod:(NSString *)httpMethod
contentType:(NSString *)contentType __attribute__((unavailable("initWithURL:httpMethod:contentType: not available! Use initWithAccessToken:accessSecretToken:idUser: or initWithAccessToken:accessSecretToken:screenName:")));

@end
