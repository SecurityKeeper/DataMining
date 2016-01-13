//
//  GetHealthDatasWorker.m
//  TestSpeed
//
//  Created by liuxu on 16/1/13.
//  Copyright (c) 2016年 liuxu. All rights reserved.
//

#import "HealthDatasWorker.h"

#define HKVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

@interface HealthDatasWorker()

@property (nonatomic,strong) HKHealthStore *healthStore;

@end

@implementation HealthDatasWorker

+ (HealthDatasWorker*)shareInstance {
    static HealthDatasWorker* work = nil;
    dispatch_once_t token_t;
    dispatch_once(&token_t, ^{
        if (!work) {
            work = [[HealthDatasWorker alloc]init];
        }
    });
    
    return work;
}

- (void)getPermissions {
    if (HKVersion >= 8.0)
    {
        if ([HKHealthStore isHealthDataAvailable]) {
            if(self.healthStore == nil)
                self.healthStore = [[HKHealthStore alloc] init];
            
            /*组装需要读写的数据类型*/
            NSSet *writeDataTypes = [self dataTypesToWrite];
            NSSet *readDataTypes = [self dataTypesRead];
            
            /*注册需要读写的数据类型，也可以在“健康”APP中重新修改*/
            [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"%@\n\n%@",error, [error userInfo]);
                    return;
                }
            }];
        }
    }
}

- (NSSet *)dataTypesToWrite {
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType, weightType,activeEnergyType,nil];
}

- (NSSet *)dataTypesRead {
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, activeEnergyType,nil];
}

- (void)getRealTimeStepCountCompletionHandler:(void(^)(double value, NSError *error))handler {
    if (HKVersion < 8.0)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:CustomHealthErrorDomain code:0 userInfo:userInfo];
        handler(0,aError);
    }
    else {
        HKSampleType *sampleType =
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        HKObserverQuery *query =
        [[HKObserverQuery alloc]
         initWithSampleType:sampleType
         predicate:nil
         updateHandler:^(HKObserverQuery *query,
                         HKObserverQueryCompletionHandler completionHandler,
                         NSError *error) {
             if (error) {
                 NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***",
                          error.localizedDescription);
                 handler(0,error);
                 abort();
             }
             [self getStepCount:[HealthManager predicateForSamplesToday] completionHandler:^(double value, NSError *error) {
                 handler(value,error);
             }];
         }];
        [self.healthStore executeQuery:query];
    }
}

- (void)getStepCount:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler
{
    if (HKVersion < 8.0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:CustomHealthErrorDomain code:0 userInfo:userInfo];
        handler(0,aError);
    }
    else {
        HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        [self.healthStore aapl_mostRecentQuantitySampleOfType:stepType predicate:predicate completion:^(NSArray *results, NSError *error) {
            if (error) {
                handler(0,error);
            }
            else {
                NSInteger totleSteps = 0;
                for(HKQuantitySample *quantitySample in results)
                {
                    HKQuantity *quantity = quantitySample.quantity;
                    HKUnit *heightUnit = [HKUnit countUnit];
                    double usersHeight = [quantity doubleValueForUnit:heightUnit];
                    totleSteps += usersHeight;
                }
                NSLog(@"当天行走步数 = %ld",totleSteps);
                handler(totleSteps,error);
            }
        }];
    }
}


+ (NSPredicate *)predicateForSamplesToday {
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

- (void)getKilocalorieUnit:(NSPredicate *)predicate quantityType:(HKQuantityType*)quantityType completionHandler:(void(^)(double value, NSError *error))handlerb {
    if (HKVersion < 8.0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:CustomHealthErrorDomain code:0 userInfo:userInfo];
        handler(0,aError);
    }
    else {
        HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
            HKQuantity *sum = [result sumQuantity];
            
            double value = [sum doubleValueForUnit:[HKUnit kilocalorieUnit]];
            NSLog(@"%@卡路里 ---> %.2lf",quantityType.identifier,value);
            if(handler)
            {
                handler(value,error);
            }
        }];
        [self.healthStore executeQuery:query];
    }
}

@end
