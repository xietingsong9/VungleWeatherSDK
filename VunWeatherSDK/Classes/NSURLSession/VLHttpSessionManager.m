//
//  VLHttpSessionManager.m
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/25.
//

#import "VLHttpSessionManager.h"

NSString *const kVLCacheDirectoryName = @"com.vungle.weather.cache";
NSString *const kbaseUrl = @"http://api.openweathermap.org";

@interface VLHttpSessionManager () <NSURLSessionDelegate>

@property (nonatomic , strong , readonly) NSURLSession *defaultSession;

@property (nonatomic , strong) dispatch_queue_t runningTasksSynchronizingQueue;
@property (nonatomic , strong) NSMutableArray *activeTasks;//Array to store requests


@end

@implementation VLHttpSessionManager

+ (VLHttpSessionManager *)sharedManager
{
    static VLHttpSessionManager *sessionManager;
    if (!sessionManager) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sessionManager = [[VLHttpSessionManager alloc] init];
        });
    }
    return sessionManager;
}

/*
 * Customization of NSURLSession occurs during creation of a new session.
 * If you only need to use the convenience routines with custom
 * configuration options it is not necessary to specify a delegate.
 * If you do specify a delegate, the delegate will be retained until after
 * the delegate has been sent the URLSession:didBecomeInvalidWithError: message.
 */
- (NSURLSession*)defaultSession {
  static dispatch_once_t onceToken;
  static NSURLSessionConfiguration *defaultSessionConfiguration;
  static NSURLSession *defaultSession;
  dispatch_once(&onceToken, ^{
    defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration
                                                   delegate:self
                                              delegateQueue:[[NSOperationQueue alloc] init]];
  });
  
  return defaultSession;
}

- (instancetype)init {
    if((self = [super init])) {
        //Create synchronization queue to manage the tasks
        self.runningTasksSynchronizingQueue = dispatch_queue_create("com.vungle.weather.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(self.runningTasksSynchronizingQueue, ^{
            self.activeTasks = [NSMutableArray array];
        });
    }
    return self;
}

- (void)requestWeatherWithPath:(NSString*)path params:(NSDictionary*)params completeBlock:(WeatherInfoBlock)completeBlock
{
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setObject:self.appid forKey:@"appid"];
    [mutableParams setObject:_tempDisplayMode == VLTemperatureDisplayModeDefault ? @"standard" : @"metric"  forKey:@"units"];

    //create request
    VLWeatherRequest *request = [self requestWithUrl:path parameters:mutableParams httpMethod:@"GET"];
    __weak typeof(self) weakSelf = self;
    [self startRequest:request completeBlock:^(VLWeatherRequest * _Nonnull request ) {
        switch (request.state) {
            case VLWeatherRequestStateError:
            case VLWeatherRequestStateStarted:
            case VLWeatherRequestStateCancelled:
            {
                VLWeatherErrorCode errorCode = [weakSelf transFormErrorCode:request.error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nil , nil , errorCode);
                });
            }
                break;
            case VLWeatherRequestStateCompleted:
            {
               id responsJson = [request responseAsJSON];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock([weakSelf transformInfoData:responsJson] , responsJson , VL_WEATHER_NO_ERROR);
                });
            }
                break;
                
            default:
                break;
        }
    }];
}

- (nullable VLWeatherRequest *)requestWithUrl:(NSString *)URLString
                                   parameters:(NSDictionary*)parameters
                                   httpMethod:(NSString*) httpMethod {

    if (URLString == nil) {
        NSLog(@"URLString is nil");
        return nil;
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kbaseUrl,URLString];
    VLWeatherRequest *request = [[VLWeatherRequest alloc] initWithURLString:requestUrl params:parameters httpMethod:@"GET"];
    [request addHeaders:self.defaultHeaders];
    
    return request;
}

/**
 * Start request
 * The results will be returned through WeatherRequestBlock
 * @param request custom request
 */
- (void)startRequest:(VLWeatherRequest*)request completeBlock:(WeatherRequestBlock)block {
  
    if(!request || !request.request) {
        NSLog(@"request is nil");
        if (block) {
            block(request);
        }
        return;
    }
    NSURLSession *sessionToUse = self.defaultSession;
    NSURLSessionDataTask *task = [sessionToUse dataTaskWithRequest:request.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(request.state == VLWeatherRequestStateCancelled) {

            request.response = (NSHTTPURLResponse*) response;
            if(error) {
                request.error = error;
            }
            if(data) {
                request.responseData = data;
            }
            if (block) {
                block(request);
            }
            return;
        }
        if(!response) {

            request.response = (NSHTTPURLResponse*) response;
            request.error = error;
            request.responseData = data;
            request.state = VLWeatherRequestStateError;
            if (block) {
                block(request);
            }
            return;
        }

        request.response = (NSHTTPURLResponse*) response;

        if(request.response.statusCode >= 200 && request.response.statusCode < 300) {
          //have new resources
          request.responseData = data;
          request.error = error;
          
        } else if(request.response.statusCode >= 400) {
            //There were some errors
            request.responseData = data;
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if(response)
                userInfo[@"response"] = response;
            if(error)
                userInfo[@"error"] = error;
            
            NSError *httpError = [NSError errorWithDomain:@"com.weather.error.domain" code:request.response.statusCode userInfo:userInfo];
            request.error = httpError;
        }

        if(!request.error) {

            dispatch_sync(self.runningTasksSynchronizingQueue, ^{
              [self.activeTasks removeObject:request];
            });
            
            request.state = VLWeatherRequestStateCompleted;
        } else {

            dispatch_sync(self.runningTasksSynchronizingQueue, ^{
              [self.activeTasks removeObject:request];
            });
            request.state = VLWeatherRequestStateError;
        }
        if (block) {
            block(request);
        }
    }];
    request.task = task;
    //Compare the new request with the request in the request array, and cannel the request if it is the same
    dispatch_sync(self.runningTasksSynchronizingQueue, ^{
        __block VLWeatherRequest *matchingRequest = nil;
        [self.activeTasks enumerateObjectsUsingBlock:^(VLWeatherRequest *vlrequest, NSUInteger idx, BOOL *stop) {
            if([vlrequest.task isEqual:task] && vlrequest.state == VLWeatherRequestStateStarted) {
                [vlrequest cancel];
                matchingRequest = vlrequest;
              *stop = YES;
            }
        }];
        if (matchingRequest) {
            [self.activeTasks removeObject:matchingRequest];
        }
        [self.activeTasks addObject:request];
    });

    request.state = VLWeatherRequestStateStarted;
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
}

/**
 *Format the returned data as required
 */
- (VLWeatherInfo*)transformInfoData:(id)obj
{
    NSMutableDictionary *mainInfoDic = [NSMutableDictionary dictionary];

    //这里不需要遍历结果，只需要取出所需字段即可
    VLWeatherInfo *weatherInfo = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *result = obj;
        [mainInfoDic setValue:result[@"name"] forKey:@"cityName"];
        [mainInfoDic setValue:[NSString stringWithFormat:@"%@",result[@"dt"]] forKey:@"gotTime"];
        NSDictionary *tempDic = result[@"main"];
        if (tempDic) {
            [mainInfoDic setValue:[NSString stringWithFormat:@"%@",tempDic[@"temp"]]  forKey:@"temp"];
            [mainInfoDic setValue:[NSString stringWithFormat:@"%@",tempDic[@"temp_min"]] forKey:@"minTemp"];
            [mainInfoDic setValue:[NSString stringWithFormat:@"%@",tempDic[@"temp_max"]] forKey:@"maxTemp"];
        }
        if (mainInfoDic.allKeys.count > 0) {
            weatherInfo = [[VLWeatherInfo alloc] init];
            [weatherInfo setValuesForKeysWithDictionary:mainInfoDic];;
        }
    }
    return weatherInfo;
}

/**
 *NSError code transform custom error code
 */
- (VLWeatherErrorCode)transFormErrorCode:(NSError*)error
{
    if (error) {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            return VL_WEATHER_NETWOKR_ERROR;
        }
        if (error.code == NSURLErrorTimedOut) {
            return VL_WEATHER_NETWOKR_TIMEOUT;
        }
        if (error.code == NSURLErrorCancelled) {
            return VL_WEATHER_NETWOKR_CANNEL;
        }
    }
    return VL_WEATHER_NETWOKR_UNKNOW;
}


@end
