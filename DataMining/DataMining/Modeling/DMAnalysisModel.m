//
//  DMAnalysisModel.m
//  DataMining
//
//  Created by Jiao Liu on 5/10/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMAnalysisModel.h"
#import "DataStorageManager.h"

@implementation DMAnalysisModel

static DMAnalysisModel *analysisModel = nil;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analysisModel = [[DMAnalysisModel alloc] init];
    });
    return analysisModel;
}

+ (void)destroyInstance
{
    analysisModel = nil;
}

- (NSMutableDictionary *)startAnalysis
{
    NSMutableDictionary *retDic = [NSMutableDictionary dictionary];
    NSArray *tempAnalysisData = [[DataStorageManager shareInstance] getDataType:entitiesType_AnalysisData WithCount:0 dataFrom:dataSrcType_reliableStorage];
    BOOL tryLogic = false;
    NSMutableArray *reliableArray = [NSMutableArray array];
    for (NSDictionary *value in tempAnalysisData) {
        if (![[value objectForKey:kAnalysisOut] boolValue]) {
            tryLogic = true;
            break;
        }
    }
    
    
    if (tryLogic) {
        for (NSDictionary *value in tempAnalysisData) {
            NSDictionary *checkDic = [NSDictionary dictionary];
            [checkDic setValue:[value objectForKey:kAngle] forKey:kAngle];
            [checkDic setValue:[value objectForKey:kEuler] forKey:kEuler];
            [checkDic setValue:[value objectForKey:kPlace] forKey:kPlace];
            [checkDic setValue:[value objectForKey:kStepLength] forKey:kStepLength];
            [checkDic setValue:[value objectForKey:kTouchForce] forKey:kTouchForce];
            [checkDic setValue:[value objectForKey:kTouchMove] forKey:kTouchMove];
            [checkDic setValue:[value objectForKey:kAnalysisOut] forKey:kAnalysisOut];
            [reliableArray addObject:checkDic];
        }
        
        return retDic;
    }
    
    for (NSDictionary *value in tempAnalysisData) {
        NSDictionary *checkDic = [NSDictionary dictionary];
        [checkDic setValue:[value objectForKey:kAngle] forKey:kAngle];
        [checkDic setValue:[value objectForKey:kEuler] forKey:kEuler];
        [checkDic setValue:[value objectForKey:kPlace] forKey:kPlace];
        [checkDic setValue:[value objectForKey:kStepLength] forKey:kStepLength];
        [checkDic setValue:[value objectForKey:kTouchForce] forKey:kTouchForce];
        [checkDic setValue:[value objectForKey:kTouchMove] forKey:kTouchMove];
        [reliableArray addObject:checkDic];
    }
    
    NSArray *tempHealth = [[DataStorageManager shareInstance] getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_memory];
    if (tempHealth.count == 0) {
        tempHealth = [[DataStorageManager shareInstance] getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    NSArray *tempTouch = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_memory];
    if (tempTouch == 0) {
        tempHealth = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    NSArray *tempLocation = [[DataStorageManager shareInstance] getDataType:entitiesType_Location WithCount:0 dataFrom:dataSrcType_memory];
    if (tempLocation == 0) {
        tempLocation = [[DataStorageManager shareInstance] getDataType:entitiesType_Location WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    NSArray *tempAccelerometer = [[DataStorageManager shareInstance] getDataType:entitiesType_Accelerometer WithCount:0 dataFrom:dataSrcType_memory];
    if (tempAccelerometer == 0) {
        tempAccelerometer = [[DataStorageManager shareInstance] getDataType:entitiesType_Accelerometer WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    NSArray *tempDeviceMontion = [[DataStorageManager shareInstance] getDataType:entitiesType_DeviceMontion WithCount:0 dataFrom:dataSrcType_memory];
    if (tempDeviceMontion == 0) {
        tempDeviceMontion = [[DataStorageManager shareInstance] getDataType:entitiesType_DeviceMontion WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    return retDic;
}

@end
