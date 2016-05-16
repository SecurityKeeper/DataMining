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
    long time = dbData.count/ 500;
    long remain = dbData.count % 500;
    if (time > 0) {
        for (int i = 0; i < 500; i++) {
            long index = i * time;
            long loop = i == 499 ? (i + 1) * time + remain  : (i + 1) * time;
            double pitch;
            double roll;
            double yaw;
            int num = 0;
            NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
            while (index < loop) {
                NSDictionary *dic = [dbData objectAtIndex:index];
                pitch += [[dic objectForKey:kPitch] floatValue];
                roll += [[dic objectForKey:kRoll] floatValue];
                yaw += [[dic objectForKey:kYaw] floatValue];
                num++;
                index++;
            }
            [tmpDic setObject:@(pitch / num) forKey:kPitch];
            [tmpDic setObject:@(roll / num) forKey:kRoll];
            [tmpDic setObject:@(yaw / num) forKey:kYaw];
            [dataSet addObject:tmpDic];
        }
    }
    else
    {
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
    }

    if (dataSet.count == 0||data.count == 0) {
        return 0;
    }
    
    double average = 0;
    double pitch = 0;
    double roll = 0;
    double yaw = 0;
    for (NSDictionary *valueDic in data) {
        pitch += [[valueDic objectForKey:kPitch] doubleValue] / data.count;
        roll += [[valueDic objectForKey:kRoll] doubleValue] / data.count;
        yaw += [[valueDic objectForKey:kYaw] doubleValue] / data.count;
    }
    
    NSMutableDictionary *checkDic = [NSMutableDictionary dictionary];
    [checkDic setValue:[NSNumber numberWithDouble:pitch] forKey:kPitch];
    [checkDic setValue:[NSNumber numberWithDouble:roll] forKey:kRoll];
    [checkDic setValue:[NSNumber numberWithDouble:yaw] forKey:kYaw];
    average += [[DAClustering sharedInstance] checkData:checkDic set:dataSet] / data.count;
    
    return average;
}


- (float)getAccelerometerAnalyzeData:(NSArray*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance] getDataType:entitiesType_Accelerometer WithCount:0 dataFrom:dataSrcType_reliableStorage];

    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    long time = dbData.count/ 500;
    long remain = dbData.count % 500;
    if (time > 0) {
        for (int i = 0; i < 500; i++) {
            long index = i * time;
            long loop = i == 499 ? (i + 1) * time + remain  : (i + 1) * time;
            double x;
            double y;
            double z;
            int num = 0;
            NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
            while (index < loop) {
                NSDictionary *dic = [dbData objectAtIndex:index];
                x += [[dic objectForKey:kX] floatValue];
                y += [[dic objectForKey:kY] floatValue];
                z += [[dic objectForKey:kZ] floatValue];
                num++;
                index++;
            }
            [tmpDic setObject:@(x / num) forKey:kX];
            [tmpDic setObject:@(y / num) forKey:kY];
            [tmpDic setObject:@(z / num) forKey:kZ];
            [dataSet addObject:tmpDic];
        }
    }
    else
    {
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

    }
    
    if (dataSet.count == 0||data.count == 0) {
        return 0;
    }
    
    double average = 0;
    double x = 0;
    double y = 0;
    double z = 0;
    for (NSDictionary *valueDic in data) {
        x += [[valueDic objectForKey:kX] doubleValue] / data.count;
        y += [[valueDic objectForKey:kY] doubleValue] / data.count;
        z += [[valueDic objectForKey:kZ] doubleValue] / data.count;
    }
    NSMutableDictionary *checkDic = [NSMutableDictionary dictionary];
    [checkDic setValue:@(x) forKey:kX];
    [checkDic setValue:@(y) forKey:kY];
    [checkDic setValue:@(z) forKey:kZ];
    average += [[DAClustering sharedInstance] checkData:checkDic set:dataSet] / data.count;
    
    return average;
}


@end
