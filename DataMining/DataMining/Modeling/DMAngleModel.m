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

- (float)getMontionAnalyzeData:(NSDictionary*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance] getDataType:entitiesType_DeviceMontion WithCount:0 dataFrom:dataSrcType_reliableStorage];

    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dbData) {
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
        float pitch = [[dic objectForKey:@"pitch"] floatValue];
        float roll = [[dic objectForKey:@"roll"] floatValue];
        float yaw = [[dic objectForKey:@"yaw"] floatValue];
        [tmpDic setObject:@(pitch) forKey:@"pitch"];
        [tmpDic setObject:@(roll) forKey:@"roll"];
        [tmpDic setObject:@(yaw) forKey:@"yaw"];
        [dataSet addObject:tmpDic];
    }
    if (dataSet.count == 0||data == nil) {
        return 0;
    }
    return [[DAClustering sharedInstance] checkData:data set:dataSet];
}


- (float)getAccelerometerAnalyzeData:(NSDictionary*)data {
    
    NSArray *dbData = [[DataStorageManager shareInstance] getDataType:entitiesType_Accelerometer WithCount:0 dataFrom:dataSrcType_reliableStorage];

    NSMutableArray *dataSet = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dbData) {
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc]init];
        float x = [[dic objectForKey:@"x"] floatValue];
        float y = [[dic objectForKey:@"y"] floatValue];
        float z = [[dic objectForKey:@"z"] floatValue];
        [tmpDic setObject:@(x) forKey:@"x"];
        [tmpDic setObject:@(y) forKey:@"y"];
        [tmpDic setObject:@(z) forKey:@"z"];
        [dataSet addObject:tmpDic];
    }
    if (dataSet.count == 0||data == nil) {
        return 0;
    }
    return [[DAClustering sharedInstance] checkData:data set:dataSet];
}


@end
