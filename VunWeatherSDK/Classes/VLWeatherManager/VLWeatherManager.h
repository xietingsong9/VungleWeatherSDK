//
//  VLWeatherManager.h
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/25.
//

#import <Foundation/Foundation.h>
#import "VLWeatherDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface VLWeatherManager : NSObject

/**
 * Create and initialize the engine,
 * Returns the singleton instance.
 */
+ (VLWeatherManager*)sharedManager;

/**
 *Starting the engine is mainly to authenticate and initialize the engine.
 *The authentication result is called back to the developer through the method in VLWeatherDelegate.
 *If the parameter is wrong or the engine is abnormal, no will be returned; If the authentication request is sent successfully, yes is returned.
 *
 */
- (BOOL)start:(NSString *)key weatherDelegate:(id <VLWeatherDelegate>)delegate;

/**
 *According to the set unit, return the corresponding temperature, the default Kelvin
 */
- (void)setTemperatureDisplayMode:(VLWeatherTemperatureDisplayMode)mode;

/**
 * Get the weather information of the city by the name of the city
 *
 * @param cityName The name of city
 * @param completeBlock information for the request
 */
- (void)weatherForCityName:(NSString*)cityName completeBlock:(WeatherInfoBlock)completeBlock;
/**
 * Get the weather information of the city by the zip code of the city

 * @param zipCode The zip code of city,If zipCode is nil,Weather information will be obtained based on current geographical location.
 * @param completeBlock Response information for the request
 */
- (void)weatherForZipCode:(NSString*)zipCode completeBlock:(WeatherInfoBlock)completeBlock;
/**
 * Get the weather information of the city by latitude and longitude
 * @param lat The latitude of city
 * @param lon The longitude of city
 * @param completeBlock information for the request
 */
- (void)weatherForCoorWithLon:(double)lon lat:(double)lat completeBlock:(WeatherInfoBlock)completeBlock;


@end

NS_ASSUME_NONNULL_END
