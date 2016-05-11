//
//  DMAnalysisModel.m
//  DataMining
//
//  Created by Jiao Liu on 5/10/16.
//  Copyright © 2016 SecurityKeeper. All rights reserved.
//

#import "DMAnalysisModel.h"
#import "DataStorageManager.h"
#import "HealthModel.h"
#import "DMTouchTimeModel.h"
#import "DMTouchDistanceModel.h"
#import "DMLocationModel.h"
#import "DMAngleModel.h"
#import "DAClustering.h"
#import "LogRegression.h"

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
    
    NSArray *tempHealth = [[DataStorageManager shareInstance] getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_memory];
    if (tempHealth.count == 0) {
        tempHealth = [[DataStorageManager shareInstance] getDataType:entitiesType_Health WithCount:0 dataFrom:dataSrcType_tempStorage];
    }
    
    NSArray *tempTouch = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_memory];
    if (tempTouch == 0) {
        tempTouch = [[DataStorageManager shareInstance] getDataType:entitiesType_Touch WithCount:0 dataFrom:dataSrcType_tempStorage];
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
    
    float newStepLength = [[HealthModel shareInstance] getAnalyzeData:tempHealth];
    float newTouchForce = [[DMTouchTimeModel defaultInstance] getProbability:tempTouch];
    float newTouchMove = [[DMTouchDistanceModel defaultInstance] getProbability:tempTouch];
    float newPlace = [[DMLocationModel sharedInstance] getWeight:tempLocation];
    float newAngle = [[DMAngleModel sharedInstance] getAccelerometerAnalyzeData:tempAccelerometer];
    float newEuler = [[DMAngleModel sharedInstance] getMontionAnalyzeData:tempDeviceMontion];
    
    if (newStepLength == 0 && newTouchForce == 0 && newTouchMove == 0 && newPlace == 0 && newAngle == 0 && newEuler == 0) {
        return nil;
    }
    
    [retDic setValue:[NSNumber numberWithFloat:newStepLength] forKey:kStepLength];
    [retDic setValue:[NSNumber numberWithFloat:newTouchForce] forKey:kTouchForce];
    [retDic setValue:[NSNumber numberWithFloat:newTouchMove] forKey:kTouchMove];
    [retDic setValue:[NSNumber numberWithFloat:newPlace] forKey:kPlace];
    [retDic setValue:[NSNumber numberWithFloat:newAngle] forKey:kAngle];
    [retDic setValue:[NSNumber numberWithFloat:newEuler] forKey:kEuler];
    
    if (tryLogic) { // logistic analysis
        for (NSDictionary *value in tempAnalysisData) {
            NSMutableArray *checkArray = [NSMutableArray array];
            [checkArray addObject:[value objectForKey:kAngle]];
            [checkArray addObject:[value objectForKey:kEuler]];
            [checkArray addObject:[value objectForKey:kPlace]];
            [checkArray addObject:[value objectForKey:kStepLength]];
            [checkArray addObject:[value objectForKey:kTouchForce]];
            [checkArray addObject:[value objectForKey:kTouchMove]];
            [checkArray addObject:[value objectForKey:kAnalysisOut]];
            [reliableArray addObject:checkArray];
        }
        if (likelyHoodRatioCheck(reliableArray)) {
            NSMutableArray *newArray = [NSMutableArray array];
            [newArray addObject:@(newAngle)];
            [newArray addObject:@(newEuler)];
            [newArray addObject:@(newPlace)];
            [newArray addObject:@(newStepLength)];
            [newArray addObject:@(newTouchForce)];
            [newArray addObject:@(newTouchMove)];
            float newOut = checkData(newArray);
            if (newOut >= 0.5) {
                [retDic setValue:[NSNumber numberWithBool:true] forKey:kAnalysisOut];
            }
            else
            {
                [retDic setValue:[NSNumber numberWithBool:false] forKey:kAnalysisOut];
            }
            [retDic setValue:[self getTimeTamp] forKey:kTimesTamp];
            return retDic;
        }
    }
    [reliableArray removeAllObjects];
    
    // clustering analysis
    for (NSDictionary *value in tempAnalysisData) {
        NSMutableDictionary *checkDic = [NSMutableDictionary dictionary];
        [checkDic setValue:[value objectForKey:kAngle] forKey:kAngle];
        [checkDic setValue:[value objectForKey:kEuler] forKey:kEuler];
        [checkDic setValue:[value objectForKey:kPlace] forKey:kPlace];
        [checkDic setValue:[value objectForKey:kStepLength] forKey:kStepLength];
        [checkDic setValue:[value objectForKey:kTouchForce] forKey:kTouchForce];
        [checkDic setValue:[value objectForKey:kTouchMove] forKey:kTouchMove];
        [reliableArray addObject:checkDic];
    }
    
    float newOut = [[DAClustering sharedInstance] checkData:retDic set:reliableArray];
    if (newOut >= 0.5) {
        [retDic setValue:[NSNumber numberWithBool:true] forKey:kAnalysisOut];
    }
    else
    {
        [retDic setValue:[NSNumber numberWithBool:false] forKey:kAnalysisOut];
    }
    [retDic setValue:[self getTimeTamp] forKey:kTimesTamp];
    
    return retDic;
}

- (NSNumber *)getTimeTamp {
    double timesTamp = [[NSDate date] timeIntervalSince1970];
    NSNumber* numTamp = [NSNumber numberWithDouble:timesTamp];
    return numTamp;
}

@end
