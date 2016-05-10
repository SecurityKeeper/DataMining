//
//  HealthModel.m
//  DataMining
//
//  Created by liuxu on 16/2/19.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "HealthModel.h"
#import "DataStorageManager.h"
#import "DAAverageCalculate.h"

@interface HealthModel()

@end

@implementation HealthModel

+ (HealthModel*)shareInstance {
    static HealthModel* model = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        model = [[HealthModel alloc]init];
    });
    
    return model;
}

- (long double)getAnalyzeData:(NSArray *)newValue {
    //可信数据库获得数据
    NSArray* datas = [[DataStorageManager shareInstance]getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_reliableStorage];
    return [self doAnalyze:datas newValue:[self calculateAverage:newValue]];
}

- (long double)calculateAverage:(NSArray *)healthArray
{
    if (healthArray.count < 2) {
        return 0;
    }
    long double preDistance = 0, preStepCount = 0;
    double preTimesTamp = 0.0;
    NSMutableArray* tempArray = [NSMutableArray array];
    for (int i=0; i<healthArray.count; i++) {
        NSDictionary* dict = healthArray[i];
        if (!dict)
            continue;
        if (i == 0) {
            preDistance  = ((NSNumber*)[dict objectForKey:kDistance]).intValue;
            preStepCount = ((NSNumber*)[dict objectForKey:kStepCount]).intValue;
            preTimesTamp = ((NSNumber*)[dict objectForKey:kTimesTamp]).doubleValue;
            continue;
        }
        
        long double distance = ((NSNumber*)[dict objectForKey:kDistance]).intValue;
        long double stepCount = ((NSNumber*)[dict objectForKey:kStepCount]).intValue;
        long double timesTamp = ((NSNumber*)[dict objectForKey:kTimesTamp]).doubleValue;
        
        //进行原始计算
        long double perStepDistance = (distance - preDistance) / (stepCount - preStepCount);
        
        if (perStepDistance != 0) {
            NSNumber* perStepDistanceNum = [NSNumber numberWithFloat:perStepDistance];
            [tempArray addObject:perStepDistanceNum];
        }
        
        preDistance  = distance;
        preStepCount = stepCount;
        preTimesTamp = timesTamp;
    }
    
    long double average = 0;
    for (NSNumber *value in tempArray) {
        average += [value doubleValue] / tempArray.count;
    }
    return average;
}

/*- (long double)getCurrentAnalyzeData {
    //内存中获得数据
    NSArray* datas = [[DataStorageManager shareInstance]getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_memory];
    if (datas.count < 2) {
        return 0;
    }
    
    return [self doAnalyze:datas];
}*/

- (long double)doAnalyze:(NSArray*)datas newValue:(long double)newValue{
    long double preDistance = 0, preStepCount = 0;
    double preTimesTamp = 0.0;
    //long double newValue = 0;
    NSMutableArray* tempArray = [NSMutableArray array];
    for (int i=0; i<datas.count; i++) {
        NSDictionary* dict = datas[i];
        if (!dict)
            continue;
        if (i == 0) {
            preDistance  = ((NSNumber*)[dict objectForKey:kDistance]).intValue;
            preStepCount = ((NSNumber*)[dict objectForKey:kStepCount]).intValue;
            preTimesTamp = ((NSNumber*)[dict objectForKey:kTimesTamp]).doubleValue;
            continue;
        }
        
        long double distance = ((NSNumber*)[dict objectForKey:kDistance]).intValue;
        long double stepCount = ((NSNumber*)[dict objectForKey:kStepCount]).intValue;
        long double timesTamp = ((NSNumber*)[dict objectForKey:kTimesTamp]).doubleValue;
        
        //进行原始计算
        long double perStepDistance = (distance - preDistance) / (stepCount - preStepCount);
//        if (i == datas.count-1) {
//            newValue = perStepDistance;
//        }
        
        NSNumber* perStepDistanceNum = [NSNumber numberWithFloat:perStepDistance];
        [tempArray addObject:perStepDistanceNum];
        
        preDistance  = distance;
        preStepCount = stepCount;
        preTimesTamp = timesTamp;
    }
    
    //调用分析模块的接口
    if (tempArray.count == 0) {
        return 0;
    }
    
    return [[DAAverageCalculate defaultInstance] probabilityCalculate:tempArray newValue:newValue];
}

@end
