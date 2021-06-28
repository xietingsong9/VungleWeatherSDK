//
//  VLHttpSessionManager.h
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/25.
//

#import <Foundation/Foundation.h>

#import "VLWeatherRequest.h"
#import "VLWeatherManagerConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WeatherRequestBlock)(VLWeatherRequest *request);

@interface VLHttpSessionManager : NSObject

@property (nonatomic , strong) NSDictionary *defaultHeaders;//default header
@property (nonatomic , strong) NSString *appid;// api key
@property (nonatomic , assign) VLWeatherTemperatureDisplayMode tempDisplayMode;//the temperature display unit
/**
 * Returns the singleton instance.
 */
+ (instancetype)sharedManager;
/**
 * The entrance method of initiating the request of obtaining weather information.
 * @param path request path.
 * @param params request params，It may include latitude, longitude, city name and zip code.
 */
- (void)requestWeatherWithPath:(NSString*)path params:(NSDictionary*)params completeBlock:(WeatherInfoBlock)completeBlock;

@end

NS_ASSUME_NONNULL_END
