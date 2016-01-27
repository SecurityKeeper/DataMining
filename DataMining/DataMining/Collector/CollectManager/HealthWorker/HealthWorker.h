//
//  HealthManager.h
//  zoubao
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthWorker : NSObject

@property (nonatomic,strong) HKHealthStore *healthStore;

+ (id)shareInstance;

/*检查当前设备版本是否支持健康数据获取 8.0以上才支持*/
- (BOOL)checkDevice;

/*获取当天实时步数、行走距离*/
- (void)getRealTimeStepCountCompletionHandler:(void(^)(double stepValue, NSError *error))stepHandler
                                     distance:(void(^)(double distanceValue, NSError *error))distanceHandler;
/*获取卡路里 predicate  时间段 quantityType 样本类型*/
- (void)getKilocalorieUnit:(NSPredicate *)predicate quantityType:(HKQuantityType*)quantityType completionHandler:(void(^)(double value, NSError *error))handler;
/*当天时间段*/
+ (NSPredicate *)predicateForSamplesToday;

@end
