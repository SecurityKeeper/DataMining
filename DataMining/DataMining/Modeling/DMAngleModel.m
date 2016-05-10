//
//  DMAngleModel.m
//  DataMining
//
//  Created by zhaoxiaoyun on 16/4/1.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DMAngleModel.h"

@implementation DMAngleModel

+ (DMAngleModel *)sharedInstance {
    static dispatch_once_t token;
    static DMAngleModel * model = nil;
    dispatch_once(&token, ^{
        model = [[DMAngleModel alloc] init];
    });
    return model;
}

- (float)getMontionAnalyzeData:(NSArray*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance] getDataType:entitiesType_DeviceMontion WithCount:0 dataFrom:dataSrcType_reliableStorage];

    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dbData) {
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
        float pitch = [[dic objectForKey:kPitch] floatValue];
        float roll = [[dic objectForKey:kRoll] floatValue];
        float yaw = [[dic objectForKey:kYaw] floatValue];
        [tmpDic setObject:@(pitch) forKey:kPitch];
        [tmpDic setObject:@(roll) forKey:kRoll];
        [tmpDic setObject:@(yaw) forKey:kYaw];
        [dataSet addObject:tmpDic];
    }
    if (dataSet.count == 0||data.count == 0) {
        return 0;
    }
    
    double average = 0;
    for (NSDictionary *valueDic in data) {
        NSDictionary *checkDic = [NSDictionary dictionary];
        [checkDic setValue:[valueDic objectForKey:kPitch] forKey:kPitch];
        [checkDic setValue:[valueDic objectForKey:kRoll] forKey:kRoll];
        [checkDic setValue:[valueDic objectForKey:kYaw] forKey:kYaw];
        average += [[DAClustering sharedInstance]checkData:checkDic set:dataSet] / data.count;
    }
    
    return average;
}


- (float)getAccelerometerAnalyzeData:(NSArray*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance] getDataType:entitiesType_Accelerometer WithCount:0 dataFrom:dataSrcType_reliableStorage];

    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dbData) {
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
        float x = [[dic objectForKey:kX] floatValue];
        float y = [[dic objectForKey:kY] floatValue];
        float z = [[dic objectForKey:kZ] floatValue];
        [tmpDic setObject:@(x) forKey:kX];
        [tmpDic setObject:@(y) forKey:kY];
        [tmpDic setObject:@(z) forKey:kZ];
        [dataSet addObject:tmpDic];
    }
    if (dataSet.count == 0||data.count == 0) {
        return 0;
    }
    
    double average = 0;
    for (NSDictionary *valueDic in data) {
        NSDictionary *checkDic = [NSDictionary dictionary];
        [checkDic setValue:[valueDic objectForKey:kX] forKey:kX];
        [checkDic setValue:[valueDic objectForKey:kY] forKey:kY];
        [checkDic setValue:[valueDic objectForKey:kZ] forKey:kZ];
        average += [[DAClustering sharedInstance]checkData:checkDic set:dataSet] / data.count;
    }
    
    return average;
}


@end
