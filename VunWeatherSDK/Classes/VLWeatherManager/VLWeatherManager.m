//
//  VLWeatherManager.m
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/25.
//

#import "VLWeatherManager.h"
#import "VLWeatherManagerConstants.h"
#import "VLHttpSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface VLWeatherManager ()<CLLocationManagerDelegate>

@property (nonatomic , weak) id <VLWeatherDelegate> delegate;
@property (nonatomic , strong) CLLocationManager *locManager;
@property (nonatomic , copy) WeatherInfoBlock completeBlock;

@end

@implementation VLWeatherManager

+ (VLWeatherManager *)sharedManager
{
    static VLWeatherManager *weatherManager;
    if (!weatherManager) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            weatherManager = [[VLWeatherManager alloc] init];
        });
    }
    return weatherManager;
}

- (BOOL)start:(NSString *)key weatherDelegate:(id <VLWeatherDelegate>)delegate
{
    _delegate = delegate;
    if (key == nil || [key isEqualToString:@""]) {
        if (delegate != nil && [delegate respondsToSelector:@selector(onLocationServiceState:)]) {
            [self.delegate onLocationServiceState:VL_WEATHER_KEY_ERROR];
        }
        return NO;
    }
    [VLHttpSessionManager sharedManager].appid = key;
    return YES;
}

- (void)setTemperatureDisplayMode:(VLWeatherTemperatureDisplayMode)mode
{
    [VLHttpSessionManager sharedManager].tempDisplayMode = mode;
}

- (void)weatherForCityName:(NSString*)cityName completeBlock:(WeatherInfoBlock)completeBlock {
    if (!completeBlock) {
        NSLog(@"block is nil");
        return;
    }
    if (!cityName || cityName.length <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil , nil , VL_WEATHER_CITYNAME_ERROR);
        });
        return;
    }
    
    [[VLHttpSessionManager sharedManager] requestWeatherWithPath:@"/data/2.5/weather" params:@{@"q":cityName} completeBlock:completeBlock];
}

- (void)weatherForZipCode:(NSString*)zipCode completeBlock:(WeatherInfoBlock)completeBlock {
    if (!completeBlock) {
        NSLog(@"block is nil");
        return;
    }
    if (!zipCode || zipCode.length > 0) {
        [[VLHttpSessionManager sharedManager] requestWeatherWithPath:@"/data/2.5/weather" params:@{@"zip":zipCode} completeBlock:completeBlock];
    }
    else {
        _completeBlock = completeBlock;
        //启用定位服务
        [self setLocationService];
    }
}

- (void)weatherForCoorWithLon:(double)lon lat:(double)lat completeBlock:(WeatherInfoBlock)completeBlock {
    if (!completeBlock) {
        NSLog(@"block is nil");
        return;
    }
    [[VLHttpSessionManager sharedManager] requestWeatherWithPath:@"/data/2.5/weather" params:@{@"lon":[NSNumber numberWithDouble:lon],@"lat":[NSNumber numberWithDouble:lat]} completeBlock:completeBlock];
}

#pragma -
#pragma -- location service logic --
/**
 Confirm geographic location permissions and request location
 */
- (void)setLocationService
{
    __weak typeof(self)weakSelf = self;
    //判断是否打开了定位服务判断权限
    if (![CLLocationManager locationServicesEnabled]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completeBlock(nil , nil , VL_WEATHER_LOCATION_SERVICES_DISENABLED);
        });
        return;
    }
    self.locManager = [[CLLocationManager alloc] init];
    [self.locManager requestWhenInUseAuthorization];
    self.locManager.delegate = self;
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completeBlock(nil , nil , VL_WEATHER_LOCATION_SERVICES_DISENABLED);
        });
    }else{
        [self.locManager requestLocation];
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.completeBlock(nil , nil , VL_WEATHER_LOCATION_SERVICES_DISENABLED);
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    if (locations.count) {
        //When Receive location information, stop positioning, and request weather information
        [self.locManager stopUpdatingLocation];
        CLLocation *location = locations.firstObject;
        [self weatherForCoorWithLon:location.coordinate.longitude lat:location.coordinate.latitude completeBlock:_completeBlock];
    }
}


@end
