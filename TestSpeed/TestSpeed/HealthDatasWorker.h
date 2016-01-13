//
//  GetHealthDatasWorker.h
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthDatasWorker : NSObject

+ (HealthDatasWorker*)shareInstance;

/*获取当天实时步数*/
- (void)getRealTimeStepCountCompletionHandler:(void(^)(double value, NSError *error))handler;

/*获取一定时间段步数*/
- (void)getStepCount:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler;

/*获取卡路里
 *  @param predicate    时间段
 *  @param quantityType 样本类型
 *  @param handler      回调
 */
- (void)getKilocalorieUnit:(NSPredicate *)predicate quantityType:(HKQuantityType*)quantityType completionHandler:(void(^)(double value, NSError *error))handler;

+ (NSPredicate *)predicateForSamplesToday;

@end
