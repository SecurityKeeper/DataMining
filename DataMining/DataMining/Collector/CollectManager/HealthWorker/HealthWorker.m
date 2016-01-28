//
//  HealthManager.m
//  zoubao
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "HealthWorker.h"
#import <UIKit/UIDevice.h>
#import "HKHealthStore+AAPLExtensions.h"

#define HKVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

@implementation HealthWorker

+ (id)shareInstance {
    static HealthWorker* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

+ (NSPredicate *)predicateForSamplesToday {
    if (HKVersion >= 8.0) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        [components setHour:0];
        [components setMinute:0];
        [components setSecond: 0];
        
        NSDate *startDate = [calendar dateFromComponents:components];
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
        
        return predicate;
    }
    
    return nil;
}

- (BOOL)checkDevice {
    if (HKVersion >= 8.0) {
        return YES;
    }
    return NO;
}

- (void)getPermissions:(void(^)(BOOL success))Handle {
    if (HKVersion >= 8.0) {
        if ([HKHealthStore isHealthDataAvailable]) {
            if (self.healthStore == nil) {
                self.healthStore = [[HKHealthStore alloc] init];
            }

            NSSet *writeDataTypes = [self dataTypesToWrite];
            NSSet *readDataTypes = [self dataTypesRead];
            /*注册需要读写的数据类型，也可以在“健康”APP中重新修改*/
            [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"%@\n\n%@",error, [error userInfo]);
                    Handle(NO);
                    return;
                }
                else {
                    Handle(YES);
                }
            }];
        }
    }
}

- (NSSet *)dataTypesToWrite {
    return [NSSet setWithObjects:nil];
}

- (NSSet *)dataTypesRead {
//    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
//    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *DistanceType = [HKObjectType quantityTypeForIdentifier:     HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:
        HKQuantityTypeIdentifierStepCount];

    return [NSSet setWithObjects:stepCountType, DistanceType, nil];
}

- (void)getRealTimeStepCountCompletionHandler:(void(^)(double stepValue, NSError *error))stepHandler
                                     distance:(void(^)(double distanceValue, NSError *error))distanceHandler {
    if (HKVersion < 8.0) {
        [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
    }
    else {
        [self getPermissions:^(BOOL success) {
            if (success) {
                HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                HKObserverQuery *query = [[HKObserverQuery alloc]
                 initWithSampleType:sampleType predicate:nil
                 updateHandler:^(HKObserverQuery *query,
                                 HKObserverQueryCompletionHandler completionHandler,
                                 NSError *error) {
                     if (error) {
                         NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***",
                                  error.localizedDescription);
                         //stepHandler(0,error);
                     }
                     [self getStepCount:[HealthWorker predicateForSamplesToday] completionHandler:^(double value, NSError *error) {
                         stepHandler(value,error);
                     }];
                     [self getDistanceCount:[HealthWorker predicateForSamplesToday] completionHandler:^(double value, NSError *error) {
                         distanceHandler(value,error);
                     }];
                 }];
                [self.healthStore executeQuery:query];
            }
        }];
    }
}

- (void)getDistanceCount:(NSPredicate *)predicate
       completionHandler:(void(^)(double value, NSError *error))handler {
    if (HKVersion < 8.0) {
        [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        return;
    }
    else {
        [self getPermissions:^(BOOL success) {
            if (success) {
                HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                [self.healthStore aapl_mostRecentQuantitySampleOfType:distanceType predicate:predicate completion:^(NSArray *results, NSError *error) {
                    if (error) {
                        //handler(0,error);
                    }
                    else {
                        NSInteger totleDistance = 0;
                        for (HKQuantitySample *quantitySample in results) {
                            HKQuantity *quantity = quantitySample.quantity;
                            HKUnit *heightUnit = [HKUnit meterUnit];
                            double usersHeight = [quantity doubleValueForUnit:heightUnit];
                            totleDistance += usersHeight;
                        }
                        handler(totleDistance,error);
                    }
                }];
            }
        }];
    }
}

- (void)getStepCount:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler {
    if (HKVersion < 8.0) {
        [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        return;
    }
    else {
        [self getPermissions:^(BOOL success) {
            if (success) {
                HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                [self.healthStore aapl_mostRecentQuantitySampleOfType:stepType predicate:predicate completion:^(NSArray *results, NSError *error) {
                    if (error) {
                        //handler(0,error);
                    }
                    else {
                        NSInteger totleSteps = 0;
                        for (HKQuantitySample *quantitySample in results) {
                            HKQuantity *quantity = quantitySample.quantity;
                            HKUnit *heightUnit = [HKUnit countUnit];
                            double usersHeight = [quantity doubleValueForUnit:heightUnit];
                            totleSteps += usersHeight;
                        }
                        handler(totleSteps,error);
                    }
                }];
            }
        }];
    }
}


- (void)getKilocalorieUnit:(NSPredicate *)predicate quantityType:(HKQuantityType*)quantityType completionHandler:(void(^)(double value, NSError *error))handler {
    if (HKVersion < 8.0) {
        [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        return;
    }
    else {
        [self getPermissions:^(BOOL success) {
            if (success) {
                HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                    NSLog(@"health = %@",result);
                    HKQuantity *sum = [result sumQuantity];
                    double value = [sum doubleValueForUnit:[HKUnit kilocalorieUnit]];
                    NSLog(@"%@卡路里 ---> %.2lf",sum,value);
                    if(handler) {
                        handler(value,error);
                    }
                }];
                [self.healthStore executeQuery:query];
            }
        }];
    }
}

@end
