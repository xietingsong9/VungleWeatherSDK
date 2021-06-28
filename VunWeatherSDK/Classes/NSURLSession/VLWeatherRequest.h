
//
//  VLWeatherRequest.h
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *request state
 */
typedef enum {
    VLWeatherRequestStateReady = 0,
    VLWeatherRequestStateStarted,
    VLWeatherRequestStateCancelled,
    VLWeatherRequestStateCompleted,
    VLWeatherRequestStateError
} VLWeatherRequestState;

@interface VLWeatherRequest : NSObject

@property (readonly) NSMutableURLRequest *request;
@property (nonatomic , assign) VLWeatherRequestState state;

@property NSString *httpMethod;//http method , default GET

@property (nonatomic , strong) NSHTTPURLResponse *response;
@property (nonatomic , strong) NSData *responseData;
@property (nonatomic , strong) NSError *error;
@property (nonatomic , strong) NSURLSessionTask *task;

/**
 *Initialize request
 *@param aURLString Request path to be spliced.
 */
- (instancetype)initWithURLString:(NSString *)aURLString
                           params:(NSDictionary *)params
                       httpMethod:(NSString *)method;
/**
 *Set custom http headers field.
 */
- (void)addHeaders:(NSDictionary*)headersDictionary;
/**
 *Return request data, Class type is NSDictionary
 */
- (id)responseAsJSON;
/**
 *Cannel task
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
