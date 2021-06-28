//
//  VLWeatherManagerConstants.h
//  VLWeatherSDK
//
//  
//  Created by xietingsong on 2021/6/25.
//

#ifndef VLWeatherManagerConstants_h
#define VLWeatherManagerConstants_h

#import <VLWeatherSDK/VLWeatherInfo.h>

/**
 Display unit of temperature
 Default unit is Kelvin.
 */
typedef NS_ENUM(NSUInteger, VLWeatherTemperatureDisplayMode) {
    VLTemperatureDisplayModeDefault,
    VLTemperatureDisplayModeCelsius,
};

//status code
typedef enum{
    VL_WEATHER_NO_ERROR = 0,///ok
    VL_WEATHER_KEY_ERROR,///api key error
    VL_WEATHER_NETWOKR_ERROR,///network error
    VL_WEATHER_NETWOKR_TIMEOUT,///network timeout
    VL_WEATHER_NETWOKR_CANNEL,///network cannel
    VL_WEATHER_NETWOKR_UNKNOW,///network unknow
    VL_WEATHER_CITYNAME_ERROR,///city name param is nil
    VL_WEATHER_LOCATION_SERVICES_DISENABLED,///location services disenabled
    VL_WEATHER_LOCATION_SERVICES_ERROR,///location service error
}VLWeatherErrorCode;

/**
 fetched data block
 weatherInfo is some info which want to display
 extraInfo is all of the responsData
 errorCode is Status Code
 */
typedef void(^WeatherInfoBlock)(VLWeatherInfo * _Nullable weatherInfo , NSDictionary * _Nullable extraInfo , VLWeatherErrorCode errorCode);

#endif /* VLWeatherManagerConstants_h */
