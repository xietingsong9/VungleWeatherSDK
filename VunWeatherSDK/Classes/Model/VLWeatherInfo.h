//
//  VLWeatherInfo.h
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLWeatherInfo : NSObject

@property (nonatomic , copy) NSString *cityName;//city name
@property (nonatomic , copy) NSString *temp;//current temperature,
@property (nonatomic , copy) NSString *minTemp;//min temperature,
@property (nonatomic , copy) NSString *maxTemp;//max temperature,
@property (nonatomic , copy) NSString *gotTime;//fetched data time

@end


NS_ASSUME_NONNULL_END
