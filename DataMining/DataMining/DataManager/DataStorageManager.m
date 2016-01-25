//
//  DataStorageManager.m
//  DataMining
//
//  Created by liuxu on 16/1/25.
//  Copyright (c) 2016年 SecurityKeeper. All rights reserved.
//

#import "DataStorageManager.h"

@interface DataStorageManager()

@property (atomic, strong)NSMutableArray* deviceMotionArray;
@property (atomic, strong)NSMutableArray* healthArray;
@property (atomic, strong)NSMutableArray* locationArray;
@property (atomic, strong)NSMutableArray* touchArray;
@property (atomic, strong)NSMutableArray* accelerometerArray;

@end

@implementation DataStorageManager

+ (DataStorageManager*)shareInstance {
    static DataStorageManager* data = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        data = [[DataStorageManager alloc]init];
        [data initData];
    });
    
    return data;
}

- (void)initData {
    self.deviceMotionArray = [NSMutableArray array];
    self.healthArray = [NSMutableArray array];
    self.locationArray = [NSMutableArray array];
    self.touchArray = [NSMutableArray array];
    self.accelerometerArray = [NSMutableArray array];
}

- (void)dealloc {
    [self releaseArray];
}

- (void)releaseArray {
    @synchronized(self) {
        self.deviceMotionArray = nil;
        self.healthArray = nil;
        self.locationArray = nil;
        self.touchArray = nil;
        self.accelerometerArray = nil;
    }
}

- (NSArray*)getDataType:(entitiesType)type WithCount:(int)count {
    //内存＋临时＋可信数据库
    
    return nil;
}

- (void)removeAllTempStorageData {
    @synchronized(self) {
        NSArray* typeArray = @[@0, @1, @2, @3, @4];
        for (NSNumber* num in typeArray) {
            entitiesType type = num.intValue;
            [[CoreDataManager shareInstance] deleteEntities_Temp:type];
        }
    }
}

- (void)saveType:(entitiesType)type WithData:(NSDictionary*)dict {
    //存入内存
    @synchronized(self) {
        switch (type) {
            case entitiesType_DeviceMontion:
                [self.deviceMotionArray addObject:dict];
                break;
            case entitiesType_Location:
                [self.locationArray addObject:dict];
                break;
            case entitiesType_Touch:
                [self.touchArray addObject:dict];
                break;
            case entitiesType_Accelerometer:
                [self.accelerometerArray addObject:dict];
                break;
            case entitiesType_Health:
                [self.healthArray addObject:dict];
                break;
        }
    }
}

- (void)saveDataToTempStorage {
    //将数据从内存存入临时数据库
    @synchronized(self) {
        for (NSDictionary* dict in self.deviceMotionArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_DeviceMontion WithData:dict];
        }
        for (NSDictionary* dict in self.locationArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Location WithData:dict];
        }
        for (NSDictionary* dict in self.touchArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Touch WithData:dict];
        }
        for (NSDictionary* dict in self.accelerometerArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Accelerometer WithData:dict];
        }
        for (NSDictionary* dict in self.healthArray) {
            [[CoreDataManager shareInstance]addEntities_Temp:entitiesType_Health WithData:dict];
        }
        [self releaseArray];
    }
}

- (void)moveTempToReliableStorage {
    //将临时数据库中数据搬入可信数据库中
    @synchronized(self) {
        NSArray* typeArray = @[@0, @1, @2, @3, @4];
        for (NSNumber* num in typeArray) {
            entitiesType type = num.intValue;
            NSArray* array = [[CoreDataManager shareInstance]getEntitiesData_Temp:type];
            for (NSDictionary* dict in array) {
                [[CoreDataManager shareInstance]addEntities:type WithData:dict];
            }
            [[CoreDataManager shareInstance] deleteEntities_Temp:type];
        }
    }
}

@end
