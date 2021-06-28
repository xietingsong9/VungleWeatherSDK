//
//  VLWeatherDelegate.h
//  VLWeatherSDK
//
//  Created by xietingsong on 2021/6/25.
//

#import <Foundation/Foundation.h>
#import "VLWeatherManagerConstants.h"

///Delegate
@protocol VLWeatherDelegate <NSObject>
@optional
/**
 *返回位置服务状态错误码错误号 : 为0时验证通过，具体参加VLWeatherManagerConstants
 *@param iError 错误号
 */
- (void)onLocationServiceState:(VLWeatherErrorCode)iError;

@end
